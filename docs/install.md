# 安装 hpr

hpr 使用 Crystal 编写的工具可以被安装在 macOS、Linux、树莓派等非 Windows 系统的机器，
同时提供 docker 作为最为方便的方式进行分发。

## Docker

hpr 提供基于 alpine 和 ubuntu 镜像，镜像的 [tags](https://hub.docker.com/r/icyleafcn/hpr/tags) 遵循如下规则：

- `latest` 指向基于 alpine 最新版本
- `alpine` 指向基于 alpine 最新版本
- `ubuntu` 指向基于 ubuntu 最新版本
- `x.x.x-alpine` 指向基于 alpine 的指定版本
- `x.x.x-ubuntu` 指向基于 ubuntu 的指定版本

> 提醒: 鉴于 alpine 版本一直没有合并 Crystal v0.27.0 暂时无法更新 alpine，暂时直提供基于 ubuntu 的。

获取最新版本的 hpr:

```bash
$ docker pull icyleafcn/hpr:ubuntu
```

## 源码安装

### 依赖环境

- [Git](https://git-scm.com/)
- [Crystal](https://github.com/crystal-lang/crystal)

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
