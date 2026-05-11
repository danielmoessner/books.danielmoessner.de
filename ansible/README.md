# Ansible (Debian + Nginx)

This folder provisions a Debian server and deploys the app via Docker Compose.

- Nginx serves the domain over HTTPS and reverse-proxies to the container on `127.0.0.1:<app_port>` (default: `8060`).
- The server IP shows the Debian default Nginx page on both HTTP and HTTPS (HTTPS uses Debian's snakeoil cert).
- `books.env` is **manual** (not managed by Ansible) and contains runtime secrets like `SECRET_KEY_BASE`.
- Production SQLite is persisted on the host at `/home/books.danielmoessner.de/books.sqlite3`.

SQLite note:

- The container uses `SQLITE_DB_PATH=/data/prod.sqlite3` (see `docker-compose.yml`).
- SQLite must be able to create/delete journal files next to the DB file; storing the DB under `/data` avoids permission issues when the container runs as a non-root user.

## Prereqs

On your machine:
- `ansible` installed
- SSH access to the server (root or sudo-capable user)

On the server:
- Debian
- Python 3 installed (needed for Ansible modules)

## Configure inventory

Edit `ansible/inventory/production/hosts.ini` and add your host.

## Provision

```bash
ansible-playbook ansible/provision.yml
```

## Manual secrets step

Create the file on the server:

- `{{ app_env_file }}` (default: `/home/books.danielmoessner.de/books.env`)

Required contents:

```bash
SECRET_KEY_BASE=<generate via: mix phx.gen.secret>
```

## Deploy

Deploy the image for the current git SHA (or `GITHUB_SHA` if set):

```bash
ansible-playbook ansible/deploy.yml
```

Deploy a specific image tag:

```bash
ansible-playbook ansible/deploy.yml \
  -e app_image=ghcr.io/<owner>/<repo>:sha-<longsha>
```

## HTTPS

Provision always enables HTTPS for the domain via Let's Encrypt (HTTP-01 + webroot).
Ensure DNS for `app_domain` points to this server and port 80 is reachable.

Let's Encrypt does not issue certificates for bare IP addresses; `https://<ip>` is served by the Debian default site using a self-signed (snakeoil) cert.

Optional aliases (e.g. `www.`) can be set via `app_domain_aliases`.

The deploy playbook will:

- `docker compose pull` the image
- run `Ecto` migrations via `bin/books eval Books.Release.migrate()`
- `docker compose up -d`
