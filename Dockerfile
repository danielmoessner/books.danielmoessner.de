FROM elixir:1.15

RUN apt-get update && apt-get install -y nodejs sqlite3

WORKDIR /app

# SQLite needs to create journal/temp files next to the DB file.
# The app runs as a non-root user in docker-compose, so /app is not writable.
# Store the DB under /data instead and make it writable for gid 33 (www-data).
RUN mkdir -p /data && chown root:33 /data && chmod 2775 /data

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

COPY priv/repo priv/repo
COPY priv/static priv/static

COPY config/runtime.exs config/
RUN mix release

EXPOSE 4000

CMD ["/app/_build/prod/rel/books/bin/books", "start"]
