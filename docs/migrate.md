# 迁移至 hpr

这里列举了一些其他类似工具如何迁移到 hpr 的一些教程或工具。

## gitlab-mirrors

[gitlab-mirrros](https://github.com/samrocketman/gitlab-mirrors) 是一个年久失修的开源工具，虽然基本功能可用但并不好使。

迁移至 hpr 需要手动迁移一些配置参数:

名称 | gitlab-mirrors | hpr | 是否可选
---|---|---|---
配置文件 | `config.sh` | `config/hpr.json` | **必须**
Gitlab URL | gitlab_url | gitlab.endpoint | **必须**
Gitlab 用户私钥 | gitlab_user_token_secret | gitlab.private_token | **必须**
gitlab 分组名 | gitlab_namespace | gitlab.group_name | **必须**
是否公开项目 | public | gitlab.project_public | 可选
是否开启 Issue | issues_enabled | gitlab.project_issue | 可选
是否开启 Wiki | wiki_enabled | gitlab.project_wiki | 可选
是否开启 Snippets | snippets_enabled | gitlab.project_snippet | 可选
是否开启 MR | merge_requests_enabled | gitlab.project_merge_request | 可选

其他参数不需要迁移，对于 hpr 额外的参数定义参加[配置文件](configuration.md)。

配置文件迁移完毕好之后，需要获取 gitlab-mirrors 的仓库路径。从 gitlab-mrrors 的 config.sh 拿到 **$repo_dir** 的路径，默认是 /home/gitmirror/repositories

我们先把 hpr 运行起来

```bash
$ docker run -d --name hpr \
  -v /data/volumes/hpr-data:/app \
  -v /data/volumes/hpr-redis-data:/data \
  -v /home/gitmirror/repositories:/app/old-repositories \
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

在把上面 ssh key 传到 gitlab 后我们需要执行迁移的命令：

```bash
$ docker exec hpr hpr migrate --source gitlab-mirrors /app/old-repositories/
+------------------------+
|CyberAgent-iOS-NBUCore|
+------------------------+
Coping repository directory
Configuring remote of git
Fetching origin and pushing gitlab
+----------------------------+
|entotsu-TKSubmitTransition|
+----------------------------+
Coping repository directory
Configuring remote of git
Fetching origin and pushing gitlab
```

> 温馨提示：工具会把三种情况都会考虑在内，分别包括本地已存在项目但 gitlab 没有/没有的项目/存在的项目。

命令执行完毕后可通过 [统计接口](api.md#id=统计信息) 获取同步状态，包括定时更新到时间。如果你没有修改 `config/hpr.json` 的 `schedule` 的值默认是每小时进行更新。
