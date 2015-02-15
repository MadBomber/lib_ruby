module Link16ToSimplejChannel

  def self.status_request(a_header=nil, a_message=nil)
    puts "status_request"
    OkStatusResponse.publish
  end

end
