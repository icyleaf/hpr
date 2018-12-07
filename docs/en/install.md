# Install hpr

Install hpr on macOS, Linux, FreeBSD, and on any machine where the Crystal compiler tool chain can run,
and use docker to deploy.

## Docker

hpr based on both alpine and ubuntu image, tags following the rules:

- `latest` always the latest version based on ubuntu
- `ubuntu` always the latest version based on ubuntu
- `alpine` always the latest version based on alpine
- `x.x.x-alpine` use x.x.x version based on alpine
- `x.x.x-ubuntu` use x.x.x version based on ubuntu

pull the latest version

```bash
$ docker pull icyleafcn/hpr:latest
```

## Source

### Prerequisite Tools

- [Git](https://git-scm.com/)
- [Crystal](https://github.com/crystal-lang/crystal)

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
