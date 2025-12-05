# frozen_string_literal: true

require_relative "test_helper"
require File.expand_path("../config/environment", __dir__)
require "rackup"

class ControllerTest < Test
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def sign_in
    set_cookie("remember_token=test")
  end

  def sign_in_as(user)
    set_cookie("remember_token=#{user.remember_token}")
  end

  def cookies
    @cookies ||= Cookies.new(rack_mock_session.cookie_jar)
  end

  class Cookies
    def initialize(jar)
      @jar = jar
    end

    def [](name)
      cookie = @jar.get_cookie(name.to_s)
      cookie&.value
    end
  end

  def flash
    Flash.new(last_request)
  end

  class Flash
    def initialize(request)
      @request = request
    end

    def [](key)
      rack_session = @request.env["rack.session"]
      if rack_session.nil?
        return nil
      end

      flash_hash = rack_session.dig("flash", "flashes")
      if flash_hash.nil?
        return nil
      end

      flash_hash[key.to_s]
    end
  end

  def get(path, params = {}, headers = {})
    super
    last_response
  end

  def post(path, params = {}, headers = {})
    super
    last_response
  end

  private def teardown
    clear_cookies
    header "Ajax-Referer", nil
    super
  end
end
