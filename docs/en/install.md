# Install hpr

Install hpr on macOS, Linux, FreeBSD, and on any machine where the Crystal compiler tool chain can run.

> There is lots of talk about “hpr being written in Crystal”, but you don’t need to install Crystal to enjoy hpr. Just grab a precompiled binary! (Not ready for now, sadly)

## Docker

```bash
$ docker pull icyleafcn/hpr:0.8.0
```

Or pull the latest version:

```bash
$ docker pull icyleafcn/hpr:latest
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
```
