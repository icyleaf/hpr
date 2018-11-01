# Quick Start

Packed all dependenices into Docker, first, clone this repository:

```bash
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/docker-compose.yml
```

Download config file of hpr：

```bash
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.json.example.yml
$ mkdir config
$ mv hpr.json.example.yml config/hpr.json
```

Copy [config/hpr.json.example](https://github.com/icyleaf/hpr/blob/master/config/hpr.json.example) to `config/config.json` and edit it.

```json
{
  "schedule_in": "1.day",
  "basic_auth": {
    "enable": false,
    "user": "hpr",
    "password": "p@ssw0rd"
  },
  "gitlab": {
    "ssh_port": 22,
    "endpoint": "http://gitlab.example.com/api/v3",
    "private_token": "abc",

    "group_name": "mirrors",

    "project_public": false,
    "project_issue": false,
    "project_wiki": false,
    "project_merge_request": false,
    "project_snippet": false
  }
}
```

Here has 4 places to change your own.

- `endpoint`: you only change the scheme and host, **DOT NOT** edit tail part.
- `private_token`: visit your account page in account setting
- `group_name`: all mirrored project will be in this group, **MAKE SUER YOU ACCOUNT HAS CREATE GROUP ROLE** (ignore if has admin role)
- `ssh_port`: change it if you use custom ssh port

> About more params check [Configuration](configuration?id=basic_auth-接口认证) page.

1. Create a data directory on a suitable volume on your host system. e.g. **/my/own/hprdir**.
2. Set some optional `ENV` variables if you need in `docker-compose.yml`:

```yaml
version: '2'

services:
  hpr:
    image: icyleafcn/hpr
    ports:
      - 8848:8848
    volumes:
      - ./config:/app/config
      - ./repositories:/app/repositories
    environment:
      REDIS_URL: tcp://redis:6379
      REDIS_PROVIDER: REDIS_URL

      HPR_SSH_HOST: git.example.com
      HPR_SSH_PORT: 22
    depends_on:
      - redis
  redis:
    image: redis:alpine
```

The `HPR_SSH_HOST` and `HPR_SSH_PORT` variables will update your gitlab ssh config, ignore if your gitlab server use 22 port in ssh protocol.

Then run it:

```bash
$ docker-compose up
...
hpr_1      | Generating public/private rsa key pair ...
hpr_1      |
hpr_1      | GENERATED SSH PUBLIC KEY:
hpr_1      | ##################################################################
hpr_1      | ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq8O3HbLn9x8Uy8RUotlpOnxdakrmCyDpZrGBeLARmEbd6BOIBQ+UWm8NUKthQ7UOavmlsq4j8lY4kyFW2eFX2qWcbvI+s2gI+05MXax+mAukSszaNSnpAoTyJCRipilSkqiOV99V8JIJhrHPtTO0o/Ui
9WiyyWsUM4M9lEKHpZ486lDGk3IM2XQW+pxAoMKb0TYzqCsrduHUtjzy0M0BqgMPe9EtVQqCbnTMzDLXmRONoTYyTV51NQ12mMwEQcDaLQ28e5gqouQJKS81JaoRpQWa7pHsOCki6Fk9TB+EQFrGz5nOrmYYM+O1MKnFkzmVHv7Fh50Sz7d2nYzzOKAkR hpr@docker
hpr_1      | ##################################################################
hpr_1      |
hpr_1      | Configuring ssh config ...
hpr_1      | Starting hpr server ...
hpr_1      |   _
hpr_1      |  | |__  _ __  _ __
hpr_1      |  | '_ \| '_ \| '__|
hpr_1      |  | | | | |_) | |
hpr_1      |  |_| |_| .__/|_|
hpr_1      |        |_|
hpr_1      | [12] Salt server starting ...
hpr_1      | [12] * Version 0.4.2 (Crystal 0.26.1)
hpr_1      | [12] * Environment: production
hpr_1      | [12] * Listening on http://0.0.0.0:8848/
hpr_1      | [12] Use Ctrl-C to stop
```

Be attention to copy generated ssh public key in terminal output.
Add ssh public key to your gitlab.

That's all! Check usage part please.

# Usages

- [Web API](/en/api.md) (Recommand)
- [CLI](/en/cli.md)
