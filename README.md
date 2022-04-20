# Elixir GraphQL Boilerplate

### Stack

- Elixir/Phoenix
- Absinthe GraphQL
- PostgreSQL (UUID primary keys)

### Editor

- VSCode with ElixirLS preferred

### Development

- Copy contents of .env.local.example to .env.local
- Set config in .env.local
- source ./setenv.sh or ./run.sh to start app in dev mode

### Deploy ([edeliver](https://github.com/edeliver/edeliver) and [Distillery](https://github.com/bitwalker/distillery))

- `mix edeliver build release production`
- `mix edeliver deploy release production`

### Production

- Standalone app behind nginx proxy.
- Controlled by systemd (sudo systemd stop/start sntx) or using edelivery.
- Systemd service file located in /etc/systemd/system/sntx.service.
- Migrations can be also performed using server side: `~/api/sntx/bin/sntx migrate`.
- Env file is located in `~/api/app.env` and must be imported in `.~/profile` or `~/.bashrc`.

### Production: config

Create env file in and paste .env.local content. Add file to your ~/.profile or ~/.zshrc or ~/.bashrc:

```
set -o allexport
source ~/path-to-api/app.env
set +o allexport
```

### Other

- GlitchTip/Sentry error tracking in production builds
- Phoenix Dashboard: `localhost:3000/dashboard`

### Directories:

- `lib/sntx` - business logic
- `lib/sntx_graph` - GraphQL logic
- `lib/sntx_web` - REST controllers, channels, plugs, context

### systemd service:

```
[Unit]
Description=SNTX Server
After=network.target

[Service]
Type=forking
User=sntx
Group=sntx
WorkingDirectory=/home/sntx/api/sntx
ExecStart=/home/sntx/api/sntx/bin/sntx start
ExecStop=/home/sntx/api/sntx/bin/sntx stop
Restart=on-failure
RestartSec=5
SyslogIdentifier=sntx
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

```

### nginx config example:

```
server {
  listen 80;
  server_name api.sntx.pl;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl http2;

  ssl_certificate /etc/letsencrypt/live/sntx.pl/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/sntx.pl/privkey.pem;
  ssl_trusted_certificate /etc/letsencrypt/live/sntx.pl/chain.pem;

  include snippets/ssl-params.conf;

  server_name api.sntx.pl;

  location / {
          proxy_pass http://127.0.0.1:4000;
          include snippets/proxy-pass.conf;
  }
}
```
