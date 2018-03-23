# 范例：使用 Gitlab.com 服务

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
```

测试是否成功：


```bash
$ curl -i http://localhost:8848/info
```
