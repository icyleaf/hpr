# 安装 hpr

hpr 使用 Crystal 编写的工具可以被安装在 macOS、Linux、树莓派等非 Windows 系统的机器。

> 虽然使用 Crystal 编写但你可以不用安装依赖环境，可以直接下载编译好的二进制包，虽然目前还为准备好。

## Homebrew

> TODO

## 源码安装

### 依赖环境

- [Git](https://git-scm.com/)
- [Crystal](https://github.com/crystal-lang/crystal) (下载最新版本)

### macOS 环境

首先安装 [homebrew](http://brew.sh/)

```ruby
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

安装依赖环境：

```bash
$ brew install go crystal-lang
```

### 从 Github 下载源码

```bash
$ git clone https://github.com/icyleaf/hpr.git
$ cd hpr
```

### 编译二进制包

```bash
$ shards build --release --no-debug
```

### 运行

```bash
$ ./bin/hpr --help
Usage: hpr <action> [--name=<name>] [<url>]

Actions:

    -s, --server                     Run a web api server
    -l, --list                       List mirrored repositories
    -c, --create                     Create a mirror repository
    -u, --update                     Updated a mirrored repository
    -d, --delete                     Delete a mirrored repository

Option in server action:

    -P PORT, --port PORT             the port of server (by default is 8848)

Option in create action:

    --mirror-only                    Only mirror the repository without clone in create action

Option in create/update/delete action:

    --name NAME                      The name of mirror repository

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

               $ hpr -c --name "icyleaf-hpr" https://github.com/icyleaf/hpr.git

       o Clone and push a new repository without create gitlab project:

               $ hpr -c --mirror-only --name "icyleaf-hpr" https://github.com/icyleaf/hpr.git

       o Update a repository:

               $ hpr -u --name "icyleaf-hpr"

       o Delete a repository:

               $ hpr -d --name "icyleaf-hpr"

       More detail to check: https://icyleaf.github.io/hpr/

hpr v0.4.0 in Crystal v0.24.2
```