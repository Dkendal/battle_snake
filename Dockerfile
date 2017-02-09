FROM elixir:1.4.1
WORKDIR /app
ADD . .
RUN apt-get update
RUN apt-get install -y npm nodejs nodejs-legacy inotify-tools
RUN mix local.hex --force
RUN mix deps.get
RUN npm cache clean -f; npm install -g n; n stable
RUN npm install
RUN mix local.rebar --force
RUN mix test
RUN mix compile
RUN mix battle_snake.createdb
EXPOSE 4000
ENV PORT 4000
CMD mix phoenix.server
