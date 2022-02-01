class PayloadPlayer
  POST_HEADERS = { "Content-Type" => "application/json" }.freeze
  GET_ASSESSMENT_REGEX = %r{^/assessments/[0-9a-f-]{36}$}
  POST_ASSESSMENT_REGEX = %r{^/assessments/([0-9a-f-]{36})}
  SERVER_HOST = "http://localhost:4000".freeze

  def self.call
    new.call
  end

  def initialize
    @yaml = YAML.load_file(Rails.root.join("tmp/api_replay.yml"))
    @assessment_id = nil
  end

  def call
    @yaml.each do |request|
      play(request)
    end
  end

private

  def play(request)
    case request[:method]
    when "POST"
      play_post(request)
    when "GET"
      play_get(request)
    else
      raise "Unrecognised http method"
    end
  end

  def play_post(request)
    puts ">>>> playing POST request"
    substitute_assessment_id(request)
    print_request(request)
    response = Faraday.post(url(request), request[:payload], POST_HEADERS)
    @assessment_id = JSON.parse(response.body)["assessment_id"] if request[:path] == "/assessments"
    print_response(response)
    puts "********\n\n"
  end

  def play_get(request)
    puts ">>>> playing GET request"
    substitute_assessment_id(request)
    print_request(request)
    response = Faraday.get(url(request))
    print_response(response)
    puts "********\n\n"
  end

  def url(request)
    "#{SERVER_HOST}#{request[:path]}"
  end

  def substitute_assessment_id(request)
    return if request[:path] == "/assessments"

    request[:path] =~ POST_ASSESSMENT_REGEX
    replaceable_id = Regexp.last_match(1)
    request[:path] = request[:path].sub(replaceable_id, @assessment_id)
  end

  def print_request(request)
    puts "method: #{request[:method]}"
    puts "path: #{request[:path]}"
    puts "payload: #{request[:payload]}"
  end

  def print_response(response)
    puts "response status: #{response.status}"
    puts "response payload:"
    pp JSON.parse(response.body)
  end
end
