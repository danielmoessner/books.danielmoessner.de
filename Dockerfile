FROM elixir:1.15

RUN apt-get update && apt-get install -y nodejs sqlite3

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix deps.get

RUN mkdir config
COPY config/config.exs config/prod.exs config/

RUN mix deps.compile

COPY lib lib
RUN mix compile

COPY assets assets
RUN mix assets.deploy
RUN mix phx.digest

COPY config/runtime.exs config/
RUN mix release

EXPOSE 4000

CMD ["/app/_build/prod/rel/books/bin/books", "start"]
