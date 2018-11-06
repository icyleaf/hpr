# 安装 hpr

hpr 使用 Crystal 编写的工具可以被安装在 macOS、Linux、树莓派等非 Windows 系统的机器。

> 虽然使用 Crystal 编写但你可以不用安装依赖环境，可以直接下载编译好的二进制包，虽然目前还为准备好。

## Docker

从 `0.8.0` 版本开始只需要拉取 hpr 这一个镜像即可。

获取指定版本的 hpr:

```bash
$ docker pull icyleafcn/hpr:0.8.0
```

或者获取最新版本的 hpr:

```bash
$ docker pull icyleafcn/hpr:latest
```

## Homebrew

通过 brew 安装也是比较快捷的方式，但目前运行依赖配置文件：

```
$ brew tap icyleaf/core
$ brew install hpr
[have a cup of tea]
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.json.example.yml
$ mkdir config
$ mv hpr.json.example.yml config/hpr.json
$ hpr --help
```

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
$ brew install crystal-lang redis
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

### 运行 redis

```bash
$ brew services start redis
==> Successfully started `redis` (label: homebrew.mxcl.redis)
```

### 运行 hpr

```bash
$ ./bin/hpr --help
```
