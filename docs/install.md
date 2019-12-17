# 安装 hpr

hpr 使用 Ruby 编写的工具可以被安装在 macOS、Linux、树莓派等系统和硬件设备，同时提供 docker 作为最为方便的方式进行分发。

## Docker

hpr 提供基于 alpine 镜像，镜像的 [tags](https://hub.docker.com/r/icyleafcn/hpr/tags) 遵循如下规则：

- `latest` 指向基于 alpine 最新版本
- `x.x.x` 指向基于 alpine 的指定版本

对于通常的情况直接运行如下命令即可安装运行：

```bash
$ docker run --name hpr --restart=unless-stopped \
             -p 8848:8848 \
             -v `pwd`:/app \
             icyleafcn/hpr
```

假若 Gitlab 系统内设置的 SSH 端口号和 Gitlab 服务器开放的 SSH 端口号不一致需要在运行时传递两个环境变量 `HPR_SSH_HOST` 为 Gitlab 服务器域名或 IP 地址，`HPR_SSH_PORT` 为 Gitlab 服务器本身 SSH 端口号：

```bash
$ docker run --name hpr --restart=unless-stopped \
             -p 8848:8848 \
             -e HPR_SSH_HOST={gitlab_server_ip_or_domain} \
             -e HPR_SSH_PORT={gitlab_server_ssh_port} \
             -v `pwd`:/app \
             icyleafcn/hpr
```

## 源码安装

### 依赖环境

- [Git](https://git-scm.com/)
- [Ruby](https://www.ruby-lang.org/)
- [Redis](https://redis.io/)

### macOS 环境

首先安装 [homebrew](http://brew.sh/)

```ruby
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

安装依赖环境：

macOS 本身 Ruby 的版本过老建议安装 brew 的最新版本。

```bash
$ brew install ruby redis
```

### 从 Github 下载源码

```bash
$ git clone https://github.com/icyleaf/hpr.git
$ cd hpr
```

### 安装 Ruby 依赖

```bash
$ bundle install
```

### 初始化数据库

```bash
$ bundle exec rake db:setup
```

### 运行 redis

```bash
$ brew services start redis
==> Successfully started `redis` (label: homebrew.mxcl.redis)
```

### 运行 hpr

```bash
$ bundle exec guard
```
