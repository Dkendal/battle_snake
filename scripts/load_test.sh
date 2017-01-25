#!/bin/bash
export SNAKE_URL="localhost:4000"
SNAKES_PER_GAME=5
ROOT=$(realpath $(dirname $(realpath $0))/..)
CREATE_REQUEST="ruby $ROOT/scripts/create_request.rb"
export RUBY_VERSION="ruby 2.3"
export CHRUBY=/usr/local/share/chruby/chruby.sh

. $CHRUBY
chruby $RUBY_VERSION

for i in {1..50}
do
    curl -X POST "localhost:3000/api/game_forms" \
         -H "Content-Type: application/json" \
         --data $($CREATE_REQUEST --url=$SNAKE_URL -n $SNAKES_PER_GAME) | \
        jq '.game_id' | \
        read game_id

    curl -X POST "localhost:3000/api/game_servers" \
         -H "Content-Type: application/json" \
         --data "{\"id\":$game_id}" | \
        cat

    sleep 1
done
