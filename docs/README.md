![hpr-logo](_media/icon.png)

# ḫpr

![Status](https://img.shields.io/badge/status-WIP-yellow.svg)
![Language](https://img.shields.io/badge/language-crystal-776791.svg)
[![License](https://img.shields.io/github/license/icyleaf/hpr.svg)](https://github.com/icyleaf/hpr/blob/master/LICENSE)

Mirror git repositories to self-host gitlab services. It's best choice for any repository can not access in China.

> The project name and logo is source from [Scarab in ancient Egypt](https://en.wikipedia.org/wiki/Dung_beetle#Scarab_in_ancient_Egypt)

## Usage

hpr will serve two ways to manage mirror git repositories:

- [Web API](#web-api) (recommand)
- [Cli tool](#cli-tool)

**Notice**: hpr was depended [faktory](http://contribsys.com/faktory/) service, run it at first:

```bash
$ faktory
Faktory 0.7.0
Copyright © 2018 Contributed Systems LLC
Licensed under the GNU Public License 3.0
I 2018-03-21T09:33:24.506Z Initializing storage at /Users/wiiseer/.faktory/db
I 2018-03-21T09:33:24.541Z PID 53301 listening at localhost:7419, press Ctrl-C to stop
I 2018-03-21T09:33:24.542Z Web server now listening on port 7420
```

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

## Install

Install [Crystal](https://crystal-lang.org/docs/installation/index.html) and [faktory](http://contribsys.com/faktory/), then:

```bash
$ shards build
$ ./bin/hpr --help
Usage: hpr <action> [--name=<name>] <url>

 Actions:

    -s, --server                     Run a web api server (default)
    -l, --list                       List mirrored repositories
    -c, --create                     Create a mirror repository
    -u, --update                     Updated a mirrored repository
    -d, --delete                     Delete a mirrored repository

Option in create action:

    --mirror-only                    Only mirror the repository without clone in create action

Option in create/update/delete action:

    --name NAME                      The name of mirror repository

Global options:

    -v, --version                    Show version
    -h, --help                       Show this help

hpr v0.1.0 in Crystal v0.24.2
I, [2018-03-21 15:52:56 +08:00 #43713]  INFO -- hpr: API Server now listening at localhost:8848, press Ctrl-C to stop
    -b HOST, --bind HOST             Host to bind (defaults to 0.0.0.0)
    -p PORT, --port PORT             Port to listen for connections (defaults to 3000)
    -s, --ssl                        Enables SSL
    --ssl-key-file FILE              SSL key file
    --ssl-cert-file FILE             SSL certificate file
    -h, --help                       Shows this help
```

## Configuration

Copy [config/hpr.json.example](config/hpr.json.example) to `config.json` and edit it.

## Deploy (WIP)

> **Problem**: Can not deal with user role with ssh private key.

Packed all dependenices into Docker, easy peasy:

```
$ docker-compose up -d
```

That's all!

## Contributing

1. Fork it ( https://github.com/icyleaf/hpr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [icyleaf](https://github.com/icyleaf) - creator, maintainer
