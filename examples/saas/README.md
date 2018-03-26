# 范例：使用 Gitlab.com 服务

登录 [gitlab.com](gitlab.com) 后需要从个人设置 Access Tokens 页面生成自己的 Access Token：

1. 填写 Access Token 名称 Name，随意。
2. 留空过期时间，这意味着永不过期。
3. 权限（Scopes）则是全部勾选。

点击下面 `Create personal access token` 即可获得，注意这个 Token 只显示这一次好好记录下来。

获取之后，编辑 `config/hpr.json` 文件，把刚获得的 token 更新到 **private_token**。

由于目前使用的是管理账户，**group_name** 默认没有的话会尝试进行创建。没有创建组权限的需要提前让管理员帮忙创建好。

```
{
  "schedule": 3600,
  "basic_auth": {
    "enable": false,
    "user": "hpr",
    "password": "p@ssw0rd"
  },
  "gitlab": {
    "ssh_port": 10022,
    "endpoint": "https://gitlab.com/api/v4",
    "private_token": "<change me>",

    "group_name": "hpr-mirrors",

    "project_public": false,
    "project_issue": false,
    "project_wiki": false,
    "project_merge_request": false,
    "project_snippet": false
  }
}

保存之后，运行 hpr 的配置文件：

```bash
$ docker-compose up
...
hpr_1      | GENERATED SSH PUBLIC KEY:
hpr_1      | ##################################################################
hpr_1      | ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCw1v+Wt6kKpqctlDU54UHiK1h5XUOfYqJjOQj7Kv7CIsPfI2S8MrD0ze3vMFXabznG5/pH0yXed6BehUwF4jsVmm45lMwWayDYCoFtEzLXozNi9kSqBaR5B8ppkqnGekybt/T/1I4lr93bhyPSjmKuqZC
+A5XI/rTK3r+zlK0uO12XfANnfdSfYDccP2j687U/dZvBAn4pPZX+5a2EIPS2gTuNvJgTKIHYllPXlIEAeIxQwDEB7hzaFz25VNwihPkUR2oXHiRVbDhSRgvZhmf73muTY0EP79TrGh6Fl3OKafUOSIuYDIgQxj4AREw6H1BaZIcptTGX6DWLM9UZtWXT hpr@docker
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
hpr_1      | I, [2018-03-26 08:21:10 +00:00 #9]  INFO -- hpr: API Server now listening at localhost:8848, press Ctrl-C to stop
```

复制上面 SSH 公钥到 gitlab 个人设置的 SSH Keys 中即可，之后可通过 [API](https://icyleaf.github.io/hpr/#/api) 管理镜像仓库。
