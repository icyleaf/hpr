![hpr-logo](../_media/icon.png)

# ḫpr

![Status](https://img.shields.io/badge/status-WIP-yellow.svg)
![Language](https://img.shields.io/badge/language-crystal-776791.svg)
[![License](https://img.shields.io/github/license/icyleaf/hpr.svg)](https://github.com/icyleaf/hpr/blob/master/LICENSE)

Mirror git repositories to self-host gitlab services. It's best choice for any repository can not access in China.

> The project name and logo is source from [Scarab in ancient Egypt](https://en.wikipedia.org/wiki/Dung_beetle#Scarab_in_ancient_Egypt)

## Quick Start

Packed all dependenices into Docker, first, clone this repository:

```
$ git clone https://github.com/icyleaf/hpr.git
$ cd hpr
```

Copy [config/hpr.json.example](config/hpr.json.example) to `config/config.json` and edit it.

```json
{
  "schedule": 3600,
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

Then set some optional `ENV` variables if you need in `docker-compose.yml`:

```yaml
version: '2'

services:
  faktory:
    image: contribsys/faktory
    command: /faktory -b 0.0.0.0:7419 -e production
    ports:
      - 7419:7419
      - 7420:7420
    volumes:
      - faktory-data:/var/lib/faktory
    environment:
      FAKTORY_PASSWORD: "password"
  hpr:
    build: .
    image: icyleafcn/hpr
    ports:
      - 8848:8848
    volumes:
      - ./config:/app/config
      - ./repositories:/app/repositories
    environment:
      FAKTORY_URL: tcp://:password@faktory:7419
      FAKTORY_PROVIDER: FAKTORY_URL
      HPR_SSH_HOST: git.example.com
      HPR_SSH_PORT: 2233
    depends_on:
      - faktory

volumes:
  faktory-data:
```

the `HPR_SSH_HOST` and `HPR_SSH_PORT` variables will update your gitlab ssh config, ignore if your gitlab server use 22 port in ssh protocol.

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
```

Be attention to copy generated ssh public key in terminal output.
Add ssh public key to your gitlab.

That's all! Check usage part please.

## Usage

hpr will serve two ways to manage mirror git repositories:

- [Web API](#web-api) (recommand)
- [Cli tool](#cli-tool)

### Web API

hpr support a web api service (port `8848`) by default, run it:

```bash
$ hpr --server
       _
      | |__  _ __  _ __
      | '_ \| '_ \| '__|
      | | | | |_) | |
      |_| |_| .__/|_|
            |_|
I, [2018-03-21 16:44:50 +08:00 #55483]  INFO -- hpr: API Server now listening at localhost:8848, press Ctrl-C to stop
```

#### List repositories

```
GET /repositores
```

##### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| page | Integer | false | |
| per_page | Integer | false | |

#### Create a new repository

```
POST /repositores
```

##### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| url | String | true | |
| name | String | false | |


#### Update a repository

```
PUT /repositores/:name
```

##### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| name | String | false | |


#### Delete a repository

```
DELETE /repositores/:name
```

##### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| name | String | false | |

### Cli tool

#### List repositories

```bash
$ hpr -l
```

#### Create a new repository

```bash
$ hpr -c --name hpr-mirror https://github.com/icyleaf/hpr.git
```

#### Update a repository

```bash
$ hpr -u --name hpr-mirror
```

#### Delete a repository

```bash
$ hpr -d --name hpr-mirror
```

## Development

Install [Crystal](https://crystal-lang.org/docs/installation/index.html) and [faktory](http://contribsys.com/faktory/), then run `shards install`.

## Contributing

1. Fork it ( https://github.com/icyleaf/hpr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [icyleaf](https://github.com/icyleaf) - creator, maintainer
