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

配置文件迁移完毕好之后，需要把当前已经管理的仓库文件夹复制到 hpr 对于文件夹中。

```bash
# 从 gitlab-mrrors 的 config.sh 拿到 $repo_dir 的路径，默认是 /home/gitmirror/repositories
$ cd /home/gitmirror/repositories

# 把 gitlab_namespace 的名称的文件夹制到新的项目，这里比方说是 mirrors
$ cp -r mirrors /path/to/hpr/repositories
```

编辑 docker-compose.yml

```yaml
version: '2'

services:
  hpr:
    image: icyleafcn/hpr
    ports:
      - 8848:8848
    volumes:
      - ./config:/app/config
      - /path/to/hpr/repositories:/app/repositories
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

这里只是那老的数据迁移到 hpr，还需要设置定时任务更新，在配置好 ssh key 之后这里目前没有工具需要通过脚本完成：

```ruby
# gem install http
require 'http'

# 这里修改成你的 hpr 实例的地址或 IP
hpr_url = 'http://localhost:8848/repositories'

repositories = HTTP.get(hpr_url).parse
repositories.each do |repo|
  url = File.join(hpr_url, repo["name"])
  HTTP.put url
end
```

如果你没有修改 `config/hpr.json` 的 `schedule` 的值默认是每小时进行更新。