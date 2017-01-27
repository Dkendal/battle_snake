require "json"

class RubySnake < Sinatra::Base
  def initialize(*)
    @@moves = Hash.new(0)
    super
  end

  def move(id)
    @@moves[id] = (@@moves[id] + 1) % 4
    %w(up left down right)[@@moves[id]]
  end

  post "/*/start" do
    {
      name: name(params),
      color: "#123123"
    }.to_json
  end

  post "/*/move" do
    {move: move(id(params))}.to_json
  end

  def id(params)
    params['splat']
  end

  def name(params)
    id(params).join("-")
  end
end
