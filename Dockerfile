FROM elixir:1.6.0-alpine as builder

ENV MIX_ENV=prod VERBOSE=1

WORKDIR /app

COPY . .

RUN apk update && apk add nodejs git yarn

RUN mix do local.hex --force, \
    local.rebar, \
    deps.get, \
    deps.compile, \
    compile

RUN yarn install && yarn webpack:production || : && mix phx.digest

RUN mix release --env=prod --verbose

FROM elixir:1.6.0-alpine
WORKDIR /root
COPY --from=builder /app/_build/ .
RUN apk update && apk add bash
ENV HOST=localhost \
    MNESIA_HOST=bs@127.0.0.1 \
    MNESIA_STORAGE_TYPE=ram_copies \
    PORT=3000 \
    SECRET_KEY_BASE=tbFePEIYrMaNfKmTHZZT9IrdebmVbS3FnCTOp/AAWklO9Jxnhua1YlGaMLzYz2yy
EXPOSE 3000
cmd /root/prod/rel/bs/bin/bs foreground
