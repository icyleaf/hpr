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

配置文件迁移完毕好之后，需要获取 gitlab-mirrors 的仓库路径。从 gitlab-mrrors 的 config.sh 拿到 $repo_dir 的路径，默认是 /home/gitmirror/repositories

编辑 docker-compose.yml 并把刚才得到的仓库路径加到 volumes 里面。

```yaml
version: '2'

services:
  hpr:
    image: icyleafcn/hpr
    ports:
      - 8848:8848
    volumes:
      - /my/own/hprdir:/app
      - /home/gitmirror/repositories:/tmp/old-repositories
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

运行实例: `docker-compose up -d`

目前只是把 hpr 运行起来了，但还没有真正迁移数据。Hpr 提供了一个迁移工具来帮助你轻松快速完全，确保还在刚才的目录下执行：

```bash
$ docker-compose exec hpr hpr-migration --endpoint "http://localhost:8848" /tmp/old-repositories
* project1
 - Configuring git remote ...
 - Updating and pushing mirror
* project2
 - Create gitlab repository
 - Configuring git remote ...
 - Updating and pushing mirror
* project3
 - Existed, Skip
```

> 温馨提示：工具会把三种情况都会考虑在内，分别包括本地已存在项目但 gitlab 没有/没有的项目/存在的项目。

命令执行完毕后可通过 [统计接口](api.md#id=统计信息) 获取同步状态，包括定时更新到时间。如果你没有修改 `config/hpr.json` 的 `schedule` 的值默认是每小时进行更新。
