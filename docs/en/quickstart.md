# Quick Start

Packed all dependenices into Docker, first, clone this repository:

At first, We create a hpr on a suitable volume on your host system. named **/my/hpr** and download config file into `config` directory:

```bash
$ mkdir -p /my/hpr/config && cd /my/hpr
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.example.json -o config/hpr.json
```

Here has 4 places to change your own in `config/hpr.json`:

- `endpoint`: you only change the scheme and host, **DOT NOT** edit tail part.
- `private_token`: visit your account page in account setting
- `group_name`: all mirrored project will be in this group, **MAKE SUER YOU ACCOUNT HAS CREATE GROUP ROLE** (ignore if has admin role)
- `ssh_port`: change it if you use custom ssh port

> About more settings check [Configuration](configuration?id=basic_auth-接口认证) page.

This is an example config file:

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

Then run it:

```bash
$ docker run icyleafcn/hpr:0.10.0 -v /my/hpr:/app -p 8848:8848 icyleafcn/hpr
...
[cont-init.d] 10-configure-ssh: executing...
Generating public/private rsa key pair ...

SSH PUBLIC KEY:
##################################################################
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq8O3HbLn9x8Uy8RUotlpOnxdakrmCyDpZrGBeLARmEbd6BOIBQ+UWm8NUKthQ7UOavmlsq4j8lY4kyFW2eFX2qWcbvI+s2gI+05MXax+mAukSszaNSnpAoTyJCRipilSkqiOV99V8JIJhrHPtTO0o/Ui
9WiyyWsUM4M9lEKHpZ486lDGk3IM2XQW+pxAoMKb0TYzqCsrduHUtjzy0M0BqgMPe9EtVQqCbnTMzDLXmRONoTYyTV51NQ12mMwEQcDaLQ28e5gqouQJKS81JaoRpQWa7pHsOCki6Fk9TB+EQFrGz5nOrmYYM+O1MKnFkzmVHv7Fh50Sz7d2nYzzOKAkR hpr@docker
##################################################################
...
[services.d] starting services
** Starting Hpr..
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
Using config: /app/config/hpr.json
[205] Salt server starting ...
[205] * Version 0.4.2 (Crystal 0.26.1)
[205] * Environment: production
[205] * Listening on http://0.0.0.0:8848/
[205] Use Ctrl-C to stop
```

Be attention to copy generated ssh public key in terminal output.
Add ssh public key to your gitlab.

That's all! Check usage part please.

# Usages

- [Web API](/en/api.md) (Recommand)
- [CLI](/en/cli.md)
