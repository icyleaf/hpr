![hpr-logo](../_media/icon.png)

# ḫpr

![Status](https://img.shields.io/badge/status-WIP-yellow.svg)
![Language](https://img.shields.io/badge/language-crystal-776791.svg)
[![License](https://img.shields.io/github/license/icyleaf/hpr.svg)](https://github.com/icyleaf/hpr/blob/master/LICENSE)

Hpr 是一个把任意 git 仓库的镜像到 gitlab 服务的同步工具，除了本身定期同步的功能外其主要功能还是用于**境内加速**访问。

本工具可以用到的地方:

- 任意 git 仓库源码的定期同步
- Cocoapods 的境内加速

> 项目名和 Logo 出处来源于[圣甲虫](https://zh.wikipedia.org/wiki/%E8%81%96%E7%94%B2%E8%9F%B2)。

## 用法

hpr 提供两者方法来管理 git 仓库:

- [Web API](#web-api) (推荐)
- [命令行工具](#cli-tool)

**注意** hpr 依赖一个第三方的任务队列 [faktory](http://contribsys.com/faktory/)，所以你需要先开一个终端运行：

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

执行 hpr 可在本地允许一个 Web API 服务（端口号 `8848`)：

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

#### 显示已镜像的仓库列表

```
GET /repositores
```

##### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| page | Integer | false | |
| per_page | Integer | false | |

#### 创建镜像仓库

```
POST /repositores
```

##### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| url | String | true | |
| name | String | false | |


#### 更新镜像仓库

```
PUT /repositores/:name
```

##### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | String | false | |


#### 删除镜像仓库

```
DELETE /repositores/:name
```

##### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | String | false | |


### Cli tool

#### 显示已镜像的仓库列表

```bash
$ hpr -l
```

#### 创建镜像仓库

```bash
$ hpr -c --name hpr-mirror https://github.com/icyleaf/hpr.git
```

#### 更新镜像仓库

```bash
$ hpr -u --name hpr-mirror
```

#### 删除镜像仓库

```bash
$ hpr -d --name hpr-mirror
```

## 安装

首先需要安装 [Crystal](https://crystal-lang.org/docs/installation/index.html) 之后执行：

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

## 配置

复制 [config/hpr.json.example](config/hpr.json.example) 并改名 `config/config.json` 后可修改

## 部署 (尚未完成)

> 部署因为需要宿主机的 ssh 私钥涉及用户和权限的问题暂时没有解决。

```
$ docker-compose up -d
```

## 贡献你的力量

1. Fork it ( https://github.com/icyleaf/hpr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## 维护人员

- [icyleaf](https://github.com/icyleaf) - creator, maintainer
