require "json"

class RubySnake < Sinatra::Base
  def initialize(*)
    @@i ||= 0
    super
  end

  def move
    @@i = (@@i + 1) % 4
    %w(up left down right)[@@i]
  end

  post "/start" do
    {
      name: "ruby-test-snake",
      color: "#123123"
    }.to_json
  end

  post "/move" do
    {move: move()}.to_json
  end
end
