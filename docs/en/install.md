# Install hpr

Install hpr on macOS, Linux, FreeBSD, and on any machine where the Crystal compiler tool chain can run.

> There is lots of talk about “hpr being written in Crystal”, but you don’t need to install Crystal to enjoy hpr. Just grab a precompiled binary! (Not ready for now, sadly)

## Docker Compose

Check [Quick start](/en/quickstart.md)。

## Docker

> Pull [hpr](https://hub.docker.com/r/icyleafcn/hpr) 和 [redis](https://hub.docker.com/_/redis) images first。

Pull specified version of hpr:

```bash
$ docker pull icyleafcn/hpr:0.5.0
```

Or pull the latest version:

```bash
$ docker pull icyleafcn/hpr:latest
```

Pull redis image by use `alpine` tag to speed up download time。

```bash
$ docker pull redis:alpine
```

## Homebrew

If you are on macOS and using Homebrew, you can install hpr with the following:

```
$ brew tap icyleaf/core
$ brew install hpr
[have a cup of tea]
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.json.example.yml
$ mkdir config
$ mv hpr.json.example.yml config/hpr.json
$ hpr --help
```

## Source

### Prerequisite Tools

- [Git](https://git-scm.com/)
- [Crystal](https://github.com/crystal-lang/crystal) (Always download the latest version)

### macOS

Install [homebrew](http://brew.sh/) first.

```ruby
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install prerequisite tools if not install before:

```bash
$ brew install git crystal-lang redis
```

### Clone source from gitlab

```bash
$ git clone https://github.com/icyleaf/hpr.git
$ cd hpr
```

### Compile to binary

```bash
$ shards build --release --no-debug
```

### Run redis

```bash
$ brew services start redis
==> Successfully started `redis` (label: homebrew.mxcl.redis)
```

### Run hpr

```bash
$ ./bin/hpr --help
Usage: hpr <action> [--url=<url>] <name>

Actions:

    -s, --server                     Run a web api server
    -l, --list                       List mirrored repositories
    -c, --create                     Create a mirror repository
    -u, --update                     Updated a mirrored repository
    -d, --delete                     Delete a mirrored repository

Option in server action:

    -P PORT, --port PORT             the port of server (by default is 8848)

Option in create action:

    -U URL, --url URL                The url of mirror repository
    -M, --mirror-only                Only mirror the repository without clone in create action

Global options:

    -v, --version                    Show version
    -h, --help                       Show this help

Examples:

       o Start a API server:

               $ hpr -s

       o List all mirrored repositories:

               $ hpr -l

       o Start a API server with custom port:

               $ hpr -s --port 3001

       o Create a new repository:

               $ hpr -c --url https://github.com/icyleaf/hpr.git icyleaf-hpr

       o Clone and push a new repository without create gitlab project:

               $ hpr -c --mirror-only --url https://github.com/icyleaf/hpr.git icyleaf-hpr

       o Update a repository:

               $ hpr -u icyleaf-hpr

       o Delete a repository:

               $ hpr -d icyleaf-hpr

       More detail to check: https://icyleaf.github.io/hpr/

hpr v0.5.0 in Crystal v0.24.2
```
