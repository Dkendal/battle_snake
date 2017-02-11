# Battle Snake Server [![Build Status](https://travis-ci.org/Dkendal/battle_snake.svg?branch=v2.0.0)](https://travis-ci.org/Dkendal/battle_snake) [![Coverage Status](https://coveralls.io/repos/github/Dkendal/battle_snake/badge.svg?branch=v2.0.0)](https://coveralls.io/github/Dkendal/battle_snake?branch=v2.0.0)

![it's just a prank bro](http://imgur.com/Ytvm290.jpg)

## Quicker Start

  * Install [Docker](https://docs.docker.com/engine/installation/)
  * ```docker run -d -p 4000:4000 noelbk/battle_snake_server```
  * Connect to http://localhost:4000


## Quick Start
  * Install OTP 19 (skip if you have OTP)
    * get [kerl](https://github.com/kerl/kerl)
    * `kerl build 19.2 19.2`
    * `kerl install 19.2 /opt/erlang/installs/19.2`
    * `. /opt/erlang/installs/19.2/activate`
  * Install Elixir v1.4 (skip if you have Elixir)
    * get [kiex](https://github.com/taylor/kiex)
    * `kiex install 1.4`
    * `kiex use 1.4`
  * `git clone git@github.com:Dkendal/battle_snake.git`
  * `cd battle_snake`
  * `npm install`
  * `mix do deps.get, compile, battle_snake.createdb`
  * Start the Phoenix endpoint with `PORT=4000 iex --sname battle_snake_dev -S mix phoenix.server`

  I would reccomend naming the node that you run your dev server, as running `mix test` will clobber the default Mnesia database.

## Perquisites
  * Erlang OTP 19
  * Elixir 1.4

  I suggest managing your OTP version with
  [kerl](https://github.com/kerl/kerl) and your elixir version with
  [kiex](https://github.com/taylor/kie://github.com/taylor/kiex)

## Testing
`mix test`
