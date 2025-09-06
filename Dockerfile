FROM elixir:1.15

RUN apt-get update && apt-get install -y nodejs sqlite3

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN mix deps.get

# Copy phoenix-colocated/books/index.js before assets compilation
COPY _build/dev/phoenix-colocated/books/index.js _build/dev/phoenix-colocated/books/index.js

RUN mix deps.get
RUN mix assets.deploy

RUN MIX_ENV=prod mix compile
RUN MIX_ENV=prod mix release

EXPOSE 4000

CMD ["/app/_build/prod/rel/books/bin/books", "start"]