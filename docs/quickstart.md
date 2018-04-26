# 快速上手

鉴于 Docker 的便利性，推荐使用 docker-compose 以最快速的安装使用：

```bash
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/docker-compose.yml
```

获取配置模板：

```bash
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.json.example.yml
$ mkdir config
$ mv hpr.json.example.yml config/hpr.json
```

根据自己的情况修改 `config/config.json` 文件

```json
{
  "schedule_in": "1.day",
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

核心需要修改的参数有如下四项：

- `endpoint`: Gitlab API 的地址，**无需修改后面部分**
- `private_token`: 在个人设置的 Account 页面获得
- `group_name`: 项目镜像的项目都会归属到这个组内，**务必确保你的账户拥有创建组的权限** (如果是管理员请忽略加粗字样)
- `ssh_port`: 如果 SSH 不是 22 端口的话需要根据你的实际情况修改

配置文件修改保存后还需要在 `docker-compose.yml` 文件中配置下：

```yaml
version: '2'

services:
  hpr:
    image: icyleafcn/hpr
    ports:
      - 8848:8848
    volumes:
      - ./config:/app/config
      - ./repositories:/app/repositories
    environment:
      REDIS_URL: tcp://redis:6379
      REDIS_PROVIDER: REDIS_URL

      HPR_SSH_HOST: git.example.com
      HPR_SSH_PORT: 22
    depends_on:
      - redis
  redis:
    image: redis:alpine
```

其中 `HPR_SSH_HOST` 和 `HPR_SSH_PORT` 变量用于设置 Docker 实例中的 SSH 配置。如果 SSH 端口是 22 的可忽略设置这俩参数。

编辑完成后运行下面命令快完成了！

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

最后从执行命令的输出找到生成的 SSH PUBLIC KEY（两个井号中间的部分，以 `ssh-rsa` 开头，`hpr@docker` 结尾），
复制添加到 gitlab 的账户 SSH Keys 页面中。

部署的部分介绍完毕，下面是具体使用方法。

# 用法

hpr 提供两者方法来管理 git 仓库:

- [Web API](#web-api) (推荐)
- [命令行工具](#cli-tool)

## Web API

具体详情参见[API](api.md)

## Cli tool

具体详情参见[命令行工具](cli.md)
