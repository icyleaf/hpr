# 范例

项目代码中提供了两个范例来帮助理解和本地测试使用。

## 自建 Gitlab 服务

本范例主要演示使用自建 Gitlab 且 Web 服务提供 9000 端口和 SSH 提供 22 端口的状况（但 gitlab 中设置的 ssh 端口号是 22）。首先需要把 Gitlab 服务在一台机器或服务器上跑起来

首先需要登录你的自建 gilab 服务，从个人设置 Access Tokens 页面生成自己的 Access Token：

1. 填写 Access Token 名称 Name，随意。
1. 留空过期时间，这意味着永不过期。
1. 权限（Scopes）则是全部勾选。
1. 点击下面 Create personal access token 即可获得，注意这个 Token 只显示这一次好好记录下来。

获取之后，编辑 `config/hpr.json` 文件，把刚获得的 token 更新到 **private_token**。

由于目前使用的是管理账户，**group_name** 默认没有的话会尝试进行创建。没有创建组权限的需要提前让管理员帮忙创建好。

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
    "endpoint": "http://10.10.10.221:9000/api/v4",
    "private_token": "<private-token>",

    "group_name": "hpr-mirrors",

    "project_public": true,
    "project_issue": false,
    "project_wiki": false,
    "project_merge_request": false,
    "project_snippet": false
  },
  "sentry" : {
    "report": false,
    "dns": "http://<key>@<host>:<port>/<project>"
  }
}
```

假如这个文件存放在 `/data/volumes/hpr-data/config/hpr.json`，那么你可以这样创建你的 docker 实例：

```bash
$ docker run -d --name hpr \
  -v /data/volumes/hpr-data:/app \
  -v /data/volumes/hpr-redis-data:/data \
  -e HPR_SSH_HOST=10.10.10.221 \
  -e HPR_SSH_PORT=2233 \
  -p 8848:8848 \
  icyleafcn/hpr:ubuntu

Generating public/private rsa key pair ...

SSH PUBLIC KEY:
##################################################################
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD1gmxn5Rk5N1mRGzynZgYyeKb4Q5OsoQ9erLZY1nP6i8ICL+Dn+b/6YoFUcdIBsE1sv9eu6fyP7TfdLD8FWV6qK9rJSwJFq3wTF6Liu+fOSHOpDffTcAQ5dciIzu/goheYwfKekcu6EiGTn9XdHtXwOgC0+T1OLu0dskUyMhyIsYxJiDlAJL6YFgMRXVE6HPZp3XfXP2BuVCo8WydfKgs8EyQ4pbQ3yGvvb2jUgeJX+Qb4OcbKyrO7i/L2KidE2Xzzxx6QBWNkPDvGnh0b12E6UApEq99cY5bURw7qSsOfY4ct1GgMHdsjeEN4olcIici+11+iQPR3VocePbFVxEt3 hpr@docker
##################################################################
...
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
Using config: /app/config/hpr.json
[224] Salt server starting ...
[224] * Version 0.4.4 (Crystal 0.27.0)
[224] * Environment: production
[224] * Listening on http://0.0.0.0:8848/
[224] Use Ctrl-C to stop
```

复制上面 SSH 公钥到 gitlab 个人设置的 SSH Keys 中即可，之后可通过 [API](api.md) 管理镜像仓库。

## 线上 Gitlab 托管服务

### Gitlab.com

登录 [gitlab.com](https://gitlab.com) 后需要从个人设置 Access Tokens 页面生成自己的 Access Token：

1. 填写 Access Token 名称 Name，随意。
1. 留空过期时间，这意味着永不过期。
1. 权限（Scopes）则是全部勾选。
1. 点击下面 Create personal access token 即可获得，注意这个 Token 只显示这一次好好记录下来。

获取之后，编辑 `config/hpr.json 文件`，把刚获得的 token 更新到 **private_token**。

由于目前使用的是管理账户，**group_name** 默认没有的话会尝试进行创建。没有创建组权限的需要提前让管理员帮忙创建好。

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
    "endpoint": "http://gitlab.com/api/v4",
    "private_token": "<private-token>",

    "group_name": "hpr-mirrors",

    "project_public": true,
    "project_issue": false,
    "project_wiki": false,
    "project_merge_request": false,
    "project_snippet": false
  },
  "sentry" : {
    "report": false,
    "dns": "http://<key>@<host>:<port>/<project>"
  }
}
```

假如这个文件存放在 `/data/volumes/hpr-data/config/hpr.json`，那么你可以这样创建你的 docker 实例：

```bash
$ docker run --restart=unless-stopped --name hpr -d \
  -v /data/volumes/hpr-data:/app \
  -v /data/volumes/hpr-redis-data:/data \
  -p 8848:8848 \
  icyleafcn/hpr:ubuntu

Generating public/private rsa key pair ...

SSH PUBLIC KEY:
##################################################################
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD1gmxn5Rk5N1mRGzynZgYyeKb4Q5OsoQ9erLZY1nP6i8ICL+Dn+b/6YoFUcdIBsE1sv9eu6fyP7TfdLD8FWV6qK9rJSwJFq3wTF6Liu+fOSHOpDffTcAQ5dciIzu/goheYwfKekcu6EiGTn9XdHtXwOgC0+T1OLu0dskUyMhyIsYxJiDlAJL6YFgMRXVE6HPZp3XfXP2BuVCo8WydfKgs8EyQ4pbQ3yGvvb2jUgeJX+Qb4OcbKyrO7i/L2KidE2Xzzxx6QBWNkPDvGnh0b12E6UApEq99cY5bURw7qSsOfY4ct1GgMHdsjeEN4olcIici+11+iQPR3VocePbFVxEt3 hpr@docker
##################################################################
...
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
Using config: /app/config/hpr.json
[224] Salt server starting ...
[224] * Version 0.4.4 (Crystal 0.27.0)
[224] * Environment: production
[224] * Listening on http://0.0.0.0:8848/
[224] Use Ctrl-C to stop
```

复制上面 SSH 公钥到 gitlab 个人设置的 SSH Keys 中即可，之后可通过 [API](api.md) 管理镜像仓库。
