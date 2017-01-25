#/usr/bin env ruby

require 'json'
require 'getoptlong'
require 'securerandom'

opts = GetoptLong.new(
  ['--url', '-u', GetoptLong::REQUIRED_ARGUMENT],
  ['--snakes', '-n', GetoptLong::REQUIRED_ARGUMENT]
)

url = nil
snake_count = nil

opts.each do |opt, arg|
  case opt
  when '--url'
    url = arg
  when '--snakes'
    snake_count = arg.to_i
  end
end

snakes = (0..snake_count).map do |i|
  {url: "#{url}/#{SecureRandom.uuid}"}
end

print({
  game_form: {
    width: 100,
    max_food: 10,
    height: 100,
    delay: 100,
    game_mode: :multiplayer,
    snakes: snakes
  }
}.to_json)
