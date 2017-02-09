#!/usr/bin/env bash
set -e

phoenix_url=$1
snake_url=$2
snakes_per_game=$3
root=$(realpath $(dirname $(realpath $0))/..)
create_request="ruby $root/scripts/create_request.rb"
ruby_version="ruby 2.3"
chruby=/usr/local/share/chruby/chruby.sh

. $chruby
chruby $ruby_version

curl -X POST "$phoenix_url/api/game_forms" \
    -H "Content-Type: application/json" \
    --data $($create_request --url=$snake_url -n $snakes_per_game) | \
    jq '.game_id' | \
    read game_id

echo $game_id
