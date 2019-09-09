# 快速上手

鉴于 Docker 的便利性，推荐使用 Docker 以最快速的安装使用：

首先需要获取配置模板：

```bash
$ docker pull icyleafcn/hpr
$ curl -fsSL -o hpr.yml https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.example.yml
```

根据自己的情况修改 `hpr.yml` 文件，核心需要修改的参数有如下两项：

- `endpoint`: Gitlab API 的地址，老版本是 v3，新版本是 v4
- `private_token`: 在个人设置的 Account 页面获得 private_token，新版本叫 access_token

> 更多参数详情参见[配置文件](configuration?id=basic_auth-接口认证)。

最后执行如下命令即可运行 hpr：

```bash
$ docker run --name hpr --restart=unless-stopped \
             -p 8848:8848 \
             -v `pwd`/hpr.yml:/app/config/hpr.yml \
             icyleafcn/hpr
...
Generating public/private rsa key pair ... /app/.ssh/id_rsa{.pub}

SSH PUBLIC KEY:
##################################################################
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDq8O3HbLn9x8Uy8RUotlpOnxdakrmCyDpZrGBeLARmEbd6BOIBQ+UWm8NUKthQ7UOavmlsq4j8lY4kyFW2eFX2qWcbvI+s2gI+05MXax+mAukSszaNSnpAoTyJCRipilSkqiOV99V8JIJhrHPtTO0o/Ui
9WiyyWsUM4M9lEKHpZ486lDGk3IM2XQW+pxAoMKb0TYzqCsrduHUtjzy0M0BqgMPe9EtVQqCbnTMzDLXmRONoTYyTV51NQ12mMwEQcDaLQ28e5gqouQJKS81JaoRpQWa7pHsOCki6Fk9TB+EQFrGz5nOrmYYM+O1MKnFkzmVHv7Fh50Sz7d2nYzzOKAkR hpr@docker
##################################################################
...
   _
  | |__  _ __  _ __
  | '_ \| '_ \| '__|
  | | | | |_) | |
  |_| |_| .__/|_|
      |_|         v0.12.0
* Listening on tcp://0.0.0.0:8848
Use Ctrl-C to stop
```

等到看到如上输出的状态就说明系统已经准备完毕，我们还需从实例化 Docker 容器输出日志找到生成的 SSH PUBLIC KEY（两个井号中间的部分，以 `ssh-rsa` 开头，`hpr@docker` 结尾），
复制添加到 Gitlab 对应账户 SSH Keys 页面后就已经准备完毕了。

部署的部分介绍完毕，下面是具体使用方法。

## 用法

hpr 提供 [HTTP APIs](api.md) 方法来管理 git 镜像仓库。
