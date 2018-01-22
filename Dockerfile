FROM elixir:1.6 as builder

ENV MIX_ENV=prod VERBOSE=1

WORKDIR /app

COPY . .

RUN apt-get update && apt-get install -y apt-transport-https \
    && curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y nodejs yarn

RUN mix do local.hex --force, \
    local.rebar, \
    deps.get, \
    deps.compile, \
    compile

RUN yarn install && yarn webpack:production || : && mix phx.digest
run mix release --env=prod --verbose

FROM elixir:1.6
WORKDIR /root
COPY --from=builder /app/_build/ .
ENV HOST=localhost \
    MNESIA_HOST=bs@127.0.0.1 \
    MNESIA_STORAGE_TYPE=ram_copies \
    PORT=3000 \
    SECRET_KEY_BASE=tbFePEIYrMaNfKmTHZZT9IrdebmVbS3FnCTOp/AAWklO9Jxnhua1YlGaMLzYz2yy
EXPOSE 3000
cmd /root/prod/rel/bs/bin/bs foreground
