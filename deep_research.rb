#!/usr/bin/env ruby
# ~/lib/ruby/deep_research.rb
#
# See: https://gist.github.com/schappim/deb6c351cda6bdc29e1ab944c38a2539
#

require 'openai'
require 'json'
require 'net/http'
require 'uri'
require 'timeout'
require 'time'

# --- Module: DeepResearch ---
module DeepResearch
  # --- Rate Limiter ---
  # A simple rate limiter that allows a fixed number of calls per given period.
  class RateLimiter
    def initialize(limit, period)
      @limit = limit        # maximum number of allowed calls
      @period = period      # period in seconds
      @timestamps = []      # record of call times
    end

    # Blocks (sleeps) until a slot is available.
    def wait_for_slot
      now = Time.now
      # Remove timestamps older than the period.
      @timestamps.reject! { |timestamp| timestamp < now - @period }
      if @timestamps.size >= @limit
        sleep_time = @period - (now - @timestamps.first)
        puts "Rate limiter active: sleeping for #{sleep_time.round(2)} seconds..."
        sleep(sleep_time) if sleep_time > 0
        @timestamps.reject! { |timestamp| timestamp < Time.now - @period }
      end
      @timestamps << Time.now
    end
  end

  # Returns the system prompt used for every OpenAI call.
  def self.system_prompt
    now = Time.now.iso8601
    <<~PROMPT
      You are an expert researcher. Today is #{now}. Follow these instructions when responding:
      - You may be asked to research subjects that are after your knowledge cutoff, assume the user is right when presented with news.
      - The user is a highly experienced analyst, no need to simplify it, be as detailed as possible and make sure your response is correct.
      - Be highly organized.
      - Suggest solutions that I didn't think about.
      - Be proactive and anticipate my needs.
      - Treat me as an expert in all subject matter.
      - Mistakes erode my trust, so be accurate and thorough.
      - Provide detailed explanations, I'm comfortable with lots of detail.
      - Value good arguments over authorities, the source is irrelevant.
      - Consider new technologies and contrarian ideas, not just the conventional wisdom.
      - You may use high levels of speculation or prediction, just flag it for me.
    PROMPT
  end

  # --- Text Splitting ---
  #
  # A recursive character text splitter that will break text into chunks below a given size.
  class RecursiveCharacterTextSplitter
    attr_reader :chunk_size, :chunk_overlap, :separators

    def initialize(chunk_size: 1000, chunk_overlap: 200, separators: ["\n\n", "\n", ".", ",", ">", "<", " ", ""])
      @chunk_size   = chunk_size
      @chunk_overlap = chunk_overlap
      @separators   = separators
      if @chunk_overlap >= @chunk_size
        raise "Cannot have chunkOverlap >= chunkSize"
      end
    end

    def split_text(text)
      final_chunks = []

      # Choose an appropriate separator
      separator = @separators.reverse.find { |s| s == "" || text.include?(s) } || ""

      splits = separator.empty? ? text.chars : text.split(separator)

      good_splits = []
      splits.each do |s|
        if s.length < @chunk_size
          good_splits << s
        else
          unless good_splits.empty?
            merged = merge_splits(good_splits, separator)
            final_chunks.concat(merged)
            good_splits = []
          end
          final_chunks.concat(split_text(s))
        end
      end
      unless good_splits.empty?
        merged = merge_splits(good_splits, separator)
        final_chunks.concat(merged)
      end

      final_chunks
    end

    def merge_splits(splits, separator)
      docs = []
      current_doc = []
      total = 0

      splits.each do |d|
        _len = d.length
        if total + _len >= @chunk_size
          if total > @chunk_size
            warn "Created a chunk of size #{total}, which is longer than the specified #{@chunk_size}"
          end
          unless current_doc.empty?
            doc = join_docs(current_doc, separator)
            docs << doc if doc
            while total > @chunk_overlap || (total + _len > @chunk_size && total > 0)
              total -= current_doc.first.length
              current_doc.shift
            end
          end
        end
        current_doc << d
        total += _len
      end

      doc = join_docs(current_doc, separator)
      docs << doc if doc
      docs
    end

    def join_docs(docs, separator)
      text = docs.join(separator).strip
      text.empty? ? nil : text
    end
  end

  # --- OpenAI Provider ---
  module Providers
    def self.openai_client
      @client ||= OpenAI::Client.new(access_token: ENV['OPENAI_KEY'])
    end

    # Use a model that supports Structured Outputs.
    def self.o3_mini_model
      ENV['OPENAI_MODEL'] || 'gpt-4o-2024-08-06'
    end
  end

  # Trim a prompt if it is too long; this implementation uses character count.
  def self.trim_prompt(prompt, context_size = (ENV['CONTEXT_SIZE'] || 128_000).to_i)
    return "" if prompt.nil? || prompt.empty?
    if prompt.length <= context_size
      prompt
    else
      splitter = RecursiveCharacterTextSplitter.new(chunk_size: context_size, chunk_overlap: 0)
      trimmed_prompt = splitter.split_text(prompt).first || ""
      # If the splitter did not shorten the prompt, do a hard cut
      if trimmed_prompt.length >= prompt.length
        prompt[0, context_size]
      else
        trim_prompt(trimmed_prompt, context_size)
      end
    end
  end

  # --- Structured OpenAI Call ---
  #
  # Calls OpenAI with a system message and user prompt then attempts to parse a JSON response.
  # If a json_schema (Ruby hash) is provided, it is passed to the API in the response_format parameter.
  def self.generate_object(model:, system:, prompt:, max_tokens: 1000, timeout_seconds: 60, json_schema: nil)
    messages = [
      { role: "system", content: system },
      { role: "user", content: prompt }
    ]

    # DEBUG logging for the request
    puts "DEBUG: Calling OpenAI with model: #{model}, max_tokens: #{max_tokens}"
    puts "DEBUG: System prompt: #{system}"
    puts "DEBUG: User prompt: #{prompt}"

    parameters = {
      model: model,
      messages: messages,
      max_tokens: max_tokens,
      temperature: 0.7
    }
    # Use structured outputs if a schema is provided.
    parameters[:response_format] = { type: "json_schema", json_schema: json_schema } if json_schema

    begin
      response = Providers.openai_client.chat(parameters: parameters)
    rescue => e
      puts "OpenAI API error: #{e}"
      return nil
    end

    # Log the raw API response
    puts "DEBUG: Raw OpenAI response: #{response.inspect}"

    content = response.dig("choices", 0, "message", "content")
    puts "DEBUG: Extracted response content: #{content.inspect}"

    begin
      parsed = JSON.parse(content)
      puts "DEBUG: Successfully parsed JSON: #{parsed.inspect}"
      return parsed
    rescue JSON::ParserError => e
      puts "JSON parse error: #{e}"
      puts "Failed content: #{content}"
      return nil
    end
  end

  # --- Firecrawl Client ---
  #
  # A simple HTTP client for Firecrawl.
  class FirecrawlClient
    def initialize(api_key: ENV['FIRECRAWL_KEY'], base_url: ENV['FIRECRAWL_BASE_URL'] || 'https://api.firecrawl.com')
      @api_key  = api_key
      @base_url = base_url
    end

    # The search method maps to the /scrape endpoint.
    # Rate limited to 10 calls per minute.
    def search(query, limit: 5, timeout_seconds: 15)
      @scrape_limiter ||= RateLimiter.new(10, 60)
      @scrape_limiter.wait_for_slot

      uri = URI("#{@base_url}/search")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      request = Net::HTTP::Post.new(uri.path, {
        'Content-Type'  => 'application/json',
        'Authorization' => @api_key
      })
      request.body = { query: query, limit: limit, scrapeOptions: { formats: ['markdown'] } }.to_json

      begin
        response = nil
        Timeout.timeout(timeout_seconds) do
          response = http.request(request)
        end
        if response.code.to_i == 200
          JSON.parse(response.body)
        else
          puts "Firecrawl API error: #{response.code} #{response.body}"
          { "data" => [] }
        end
      rescue Timeout::Error
        puts "Firecrawl search timeout for query: #{query}"
        { "data" => [] }
      rescue => e
        puts "Firecrawl search error: #{e}"
        { "data" => [] }
      end
    end

    # New crawl method mapping to the /crawl endpoint.
    # Rate limited to 1 call per minute.
    def crawl(url, timeout_seconds: 15)
      @crawl_limiter ||= RateLimiter.new(1, 60)
      @crawl_limiter.wait_for_slot

      uri = URI("#{@base_url}/crawl")
      # Assuming the crawl endpoint expects a GET request with URL as a query parameter.
      uri.query = URI.encode_www_form(url: url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      request = Net::HTTP::Get.new(uri.request_uri, {
        'Content-Type'  => 'application/json',
        'Authorization' => @api_key
      })

      begin
        response = nil
        Timeout.timeout(timeout_seconds) do
          response = http.request(request)
        end
        if response.code.to_i == 200
          JSON.parse(response.body)
        else
          puts "Firecrawl crawl API error: #{response.code} #{response.body}"
          nil
        end
      rescue Timeout::Error
        puts "Firecrawl crawl timeout for URL: #{url}"
        nil
      rescue => e
        puts "Firecrawl crawl error: #{e}"
        nil
      end
    end
  end

  # --- Research Functions ---

  # Generate follow-up questions to clarify the research direction.
  def self.generate_feedback(query, num_questions = 3)
    schema = {
      "name" => "feedback",
      "schema" => {
        "type" => "object",
        "properties" => {
          "questions" => {
            "type" => "array",
            "items" => { "type" => "string" }
          }
        },
        "required" => ["questions"],
        "additionalProperties" => false
      },
      "strict" => true
    }

    prompt = <<~PROMPT
      Given the following query from the user, return a JSON object with a key "questions" that contains an array of up to #{num_questions} follow-up questions. Do not include any extra text.
      <query>#{query}</query>
    PROMPT

    result = generate_object(
      model: Providers.o3_mini_model,
      system: system_prompt,
      prompt: prompt,
      max_tokens: 500,
      json_schema: schema
    )
    if result && result["questions"].is_a?(Array)
      result["questions"].first(num_questions)
    else
      []
    end
  end

  # Generate a list of SERP queries (each with an associated research goal) based on the user prompt and any previous learnings.
  def self.generate_serp_queries(query, learnings = [], num_queries = 3)
    learnings_text = learnings.any? ? "Here are some learnings from previous research, use them to generate more specific queries: #{learnings.join("\n")}" : ""
    schema = {
      "name" => "serp_queries",
      "schema" => {
        "type" => "object",
        "properties" => {
          "queries" => {
            "type" => "array",
            "items" => {
              "type" => "object",
              "properties" => {
                "query" => { "type" => "string" },
                "researchGoal" => { "type" => "string" }
              },
              "required" => ["query", "researchGoal"],
              "additionalProperties" => false
            }
          }
        },
        "required" => ["queries"],
        "additionalProperties" => false
      },
      "strict" => true
    }

    prompt = <<~PROMPT
      Given the following prompt from the user, generate a list of SERP queries to research the topic. Return a JSON object with a key "queries" that contains an array of up to #{num_queries} unique queries. Each query should be an object with keys "query" and "researchGoal". Do not include any extra text.
      <prompt>#{query}</prompt>
      #{learnings_text}
    PROMPT

    result = generate_object(
      model: Providers.o3_mini_model,
      system: system_prompt,
      prompt: prompt,
      max_tokens: 800,
      json_schema: schema
    )
    if result && result["queries"].is_a?(Array)
      puts "Created #{result['queries'].length} queries: #{result['queries']}"
      result["queries"].first(num_queries)
    else
      []
    end
  end

  # Process the search result from Firecrawl to extract learnings and follow-up questions.
  def self.process_serp_result(query, result, num_learnings: 3, num_follow_up_questions: 3)
    # Extract markdown contents from the result data
    contents = if result["data"]
                 result["data"].map { |item| item["markdown"] }.compact.map { |content| trim_prompt(content, 25_000) }
               else
                 []
               end
    puts "Ran #{query}, found #{contents.length} contents"

    contents_wrapped = contents.map { |content| "<content>\n#{content}\n</content>" }.join("\n")
    schema = {
      "name" => "serp_result",
      "schema" => {
        "type" => "object",
        "properties" => {
          "learnings" => {
            "type" => "array",
            "items" => { "type" => "string" }
          },
          "followUpQuestions" => {
            "type" => "array",
            "items" => { "type" => "string" }
          }
        },
        "required" => ["learnings", "followUpQuestions"],
        "additionalProperties" => false
      },
      "strict" => true
    }

    prompt = <<~PROMPT
      Given the following contents from a SERP search for the query <query>#{query}</query>, return a JSON object with two keys: "learnings" and "followUpQuestions". The "learnings" key should contain an array of up to #{num_learnings} unique learnings derived from the contents, and "followUpQuestions" should contain an array of up to #{num_follow_up_questions} follow-up questions. Do not include any extra text.
      <contents>
      #{contents_wrapped}
      </contents>
    PROMPT

    result_obj = generate_object(
      model: Providers.o3_mini_model,
      system: system_prompt,
      prompt: prompt,
      max_tokens: 800,
      json_schema: schema
    )
    if result_obj
      puts "Created #{result_obj['learnings']&.length.to_i} learnings: #{result_obj['learnings']}"
      result_obj
    else
      { "learnings" => [], "followUpQuestions" => [] }
    end
  end

  # Write a final markdown report using the research prompt, learnings, and visited URLs.
  def self.write_final_report(prompt_text, learnings, visited_urls)
    learnings_wrapped = learnings.map { |learning| "<learning>\n#{learning}\n</learning>" }.join("\n")
    learnings_string = trim_prompt(learnings_wrapped, 150_000)
    schema = {
      "name" => "final_report",
      "schema" => {
        "type" => "object",
        "properties" => {
          "reportMarkdown" => { "type" => "string" }
        },
        "required" => ["reportMarkdown"],
        "additionalProperties" => false
      },
      "strict" => true
    }
    prompt = <<~PROMPT
      Given the following prompt from the user, write a final report on the topic using the learnings from research. Make it as detailed as possible (aim for 3 or more pages) and include ALL the learnings from research.

      <prompt>
      #{prompt_text}
      </prompt>

      Here are all the learnings from previous research:

      <learnings>
      #{learnings_string}
      </learnings>
    PROMPT

    result = generate_object(
      model: Providers.o3_mini_model,
      system: system_prompt,
      prompt: prompt,
      max_tokens: 1500,
      json_schema: schema
    )
    report_markdown = result ? result["reportMarkdown"] : ""
    urls_section = "\n\n## Sources\n\n" + visited_urls.map { |url| "- #{url}" }.join("\n")
    report_markdown + urls_section
  end

  # The main recursive research function.
  def self.deep_research(query:, breadth:, depth:, learnings: [], visited_urls: [])
    serp_queries = generate_serp_queries(query, learnings, breadth)
    firecrawl = FirecrawlClient.new
    all_learnings = learnings.dup
    all_visited_urls = visited_urls.dup

    serp_queries.each do |serp_query|
      begin
        result = firecrawl.search(serp_query["query"], limit: 5, timeout_seconds: 15)
        new_urls = (result["data"] || []).map { |item| item["url"] }.compact
        new_breadth = (breadth / 2.0).ceil
        new_depth = depth - 1

        new_learnings_obj = process_serp_result(serp_query["query"], result,
                                                 num_learnings: new_breadth,
                                                 num_follow_up_questions: new_breadth)
        all_learnings.concat(new_learnings_obj["learnings"] || [])
        all_visited_urls.concat(new_urls)

        if new_depth > 0
          puts "Researching deeper, breadth: #{new_breadth}, depth: #{new_depth}"
          next_query = <<~QUERY
            Previous research goal: #{serp_query["researchGoal"]}
            Follow-up research directions: #{(new_learnings_obj["followUpQuestions"] || []).map { |q| "\n#{q}" }.join}
          QUERY
          deeper_result = deep_research(query: next_query.strip,
                                        breadth: new_breadth,
                                        depth: new_depth,
                                        learnings: all_learnings,
                                        visited_urls: all_visited_urls)
          all_learnings   = deeper_result[:learnings]
          all_visited_urls = deeper_result[:visited_urls]
        end
      rescue => e
        puts "Error running query: #{serp_query['query']}: #{e}"
      end
    end

    { learnings: all_learnings.uniq, visited_urls: all_visited_urls.uniq }
  end
end

# --- Main CLI Application ---
if __FILE__ == $0
  # Get user input from the terminal
  puts "What would you like to research?"
  initial_query = gets.chomp

  puts "Enter research breadth (recommended 2-10, default 4):"
  breadth_input = gets.chomp
  breadth = breadth_input.empty? ? 4 : breadth_input.to_i

  puts "Enter research depth (recommended 1-5, default 2):"
  depth_input = gets.chomp
  depth = depth_input.empty? ? 2 : depth_input.to_i

  puts "\nCreating research plan..."

  # Generate follow-up questions to refine research direction
  follow_up_questions = DeepResearch.generate_feedback(initial_query, 3)
  if follow_up_questions.any?
    puts "\nTo better understand your research needs, please answer these follow-up questions:"
  end

  answers = []
  follow_up_questions.each do |question|
    puts "\n#{question}\nYour answer: "
    answer = gets.chomp
    answers << answer
  end

  combined_query = <<~QUERY
    Initial Query: #{initial_query}
    Follow-up Questions and Answers:
    #{follow_up_questions.each_with_index.map { |q, i| "Q: #{q}\nA: #{answers[i]}" }.join("\n")}
  QUERY

  puts "\nResearching your topic..."
  research_result = DeepResearch.deep_research(query: combined_query,
                                               breadth: breadth,
                                               depth: depth)

  learnings = research_result[:learnings]
  visited_urls = research_result[:visited_urls]

  puts "\n\nLearnings:\n\n#{learnings.join("\n")}"
  puts "\n\nVisited URLs (#{visited_urls.length}):\n\n#{visited_urls.join("\n")}"
  puts "\nWriting final report..."

  report = DeepResearch.write_final_report(combined_query, learnings, visited_urls)

  File.write("output.md", report)
  puts "\n\nFinal Report:\n\n#{report}"
  puts "\nReport has been saved to output.md"
end