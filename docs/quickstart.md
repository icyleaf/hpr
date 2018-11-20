# 快速上手

鉴于 Docker 的便利性，推荐使用 Docker 以最快速的安装使用：

首先需要获取配置模板：

```bash
$ mkdir -p /my/hpr/config && cd /my/hpr/config
$ wget https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.example.json -o hpr.json
```

根据自己的情况修改 `hpr.json` 文件

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

    "project_public": true,
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

> 更多参数详情参见[配置文件](configuration?id=basic_auth-接口认证)。

最后执行如下命令即可运行 hpr：

```bash
$ docker run icyleafcn/hpr:0.9.0 -v /my/hpr:/app -p 8848:8848 icyleafcn/hpr
...
[cont-init.d] 10-configure-ssh: executing...
Generating public/private rsa key pair ...

SSH PUBLIC KEY:
##################################################################
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq8O3HbLn9x8Uy8RUotlpOnxdakrmCyDpZrGBeLARmEbd6BOIBQ+UWm8NUKthQ7UOavmlsq4j8lY4kyFW2eFX2qWcbvI+s2gI+05MXax+mAukSszaNSnpAoTyJCRipilSkqiOV99V8JIJhrHPtTO0o/Ui
9WiyyWsUM4M9lEKHpZ486lDGk3IM2XQW+pxAoMKb0TYzqCsrduHUtjzy0M0BqgMPe9EtVQqCbnTMzDLXmRONoTYyTV51NQ12mMwEQcDaLQ28e5gqouQJKS81JaoRpQWa7pHsOCki6Fk9TB+EQFrGz5nOrmYYM+O1MKnFkzmVHv7Fh50Sz7d2nYzzOKAkR hpr@docker
##################################################################
...
[services.d] starting services
** Starting Hpr..
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
Using config: /app/config/hpr.json
[205] Salt server starting ...
[205] * Version 0.4.2 (Crystal 0.26.1)
[205] * Environment: production
[205] * Listening on http://0.0.0.0:8848/
[205] Use Ctrl-C to stop
```

最后从执行命令的输出找到生成的 SSH PUBLIC KEY（两个井号中间的部分，以 `ssh-rsa` 开头，`hpr@docker` 结尾），
复制添加到 gitlab 的账户 SSH Keys 页面中。

部署的部分介绍完毕，下面是具体使用方法。

# 用法

hpr 提供两者方法来管理 git 仓库:

- [Web API](api.md) (推荐)
- [命令行工具](cli.md)
