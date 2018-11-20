# 命令行工具

hpr 本身是一个命令行工具，因此也提供了一个临时可用的辅助命令来管理镜像仓库。

## 检测 hpr 运行环境

便于自己检查配置是否有问题

```bash
$ hpr check
Checking config ... [OK]
Checking service status of gitlab ... [OK]
Checking authorize of gitlab ... [OK]
Checking group of gitlab ... [OK]
Checking create project role of gitlab ... [OK]
Checking ssh key of gitlab ... [OK]
```

## 运行 Web API 服务器

```bash
$ hpr server
# 或者更改端口号
$ hpr server --port 8848
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
Using config: /app/config/hpr.json
[219] Salt server starting ...
[219] * Version 0.4.4 (Crystal 0.27.0)
[219] * Environment: production
[219] * Listening on http://0.0.0.0:8848/
[219] Use Ctrl-C to stop
```

## 显示已镜像的仓库列表

```bash
$ hpr list
2018-04-28 18:01:32 +08:00   INFO   listing repositories (2):

=> Name: icyleaf-gitlab.cr
   Path: /Users/icyleaf/data/repositories/icyleaf-gitlab.cr
   OriginalUrl: https://github.com/icyleaf/gitlab.cr
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-gitlab.cr.git
   Status: idle
   CreatedAt: 2018-04-26 17:05:44 +0800
   UpdatedAt: 2018-04-26 17:05:46 +0800
   ScheduledAt: 2018-04-29 05:05:46 +0800

=> Name: icyleaf-salt
   Path: /Users/icyleaf/data/repositories/icyleaf-salt
   OriginalUrl: https://github.com/icyleaf/salt.git
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-salt.git
   Status: idle
   CreatedAt: 2018-04-28 18:00:56 +0800
   UpdatedAt: 2018-04-28 18:00:58 +0800
   ScheduledAt: 2018-05-01 06:00:58 +0800
```

## 搜索镜像仓库

```bash
$ hpr search icyleaf

2018-04-28 18:07:34 +08:00   INFO   searching repositories ... icyleaf
2018-04-28 18:07:34 +08:00   INFO   found repositories (2):

=> Name: icyleaf-gitlab.cr
   Path: /Users/icyleaf/data/repositories/icyleaf-gitlab.cr
   OriginalUrl: https://github.com/icyleaf/gitlab.cr
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-gitlab.cr.git
   Status: idle
   CreatedAt: 2018-04-26 17:05:44 +0800
   UpdatedAt: 2018-04-26 17:05:46 +0800
   ScheduledAt: 2018-04-29 05:05:46 +0800

=> Name: icyleaf-salt
   Path: /Users/icyleaf/data/repositories/icyleaf-salt
   OriginalUrl: https://github.com/icyleaf/salt.git
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-salt.git
   Status: idle
   CreatedAt: 2018-04-28 18:00:56 +0800
   UpdatedAt: 2018-04-28 18:00:58 +0800
   ScheduledAt: 2018-05-01 06:00:58 +0800
```

## 创建镜像仓库

```bash
$ hpr create --progress -U https://github.com/icyleaf/salt.git icyleaf-salt
2018-04-26 17:04:39 +08:00   INFO   creating repository ... ews-team/icyleaf-salt
2018-04-26 17:04:41 +08:00   INFO   cloning https://github.com/icyleaf/salt.cr ... icyleaf-salt
2018-04-26 17:05:44 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:05:47 +08:00   INFO   create repository ... done
```

## 更新镜像仓库

```bash
$ hpr update --progress icyleaf-salt
2018-04-26 17:04:01 +08:00   INFO   updating from origin ... icyleaf-salt
2018-04-26 17:04:06 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:04:07 +08:00   INFO   update repository ... done
```

## 删除镜像仓库

```bash
$ hpr delete --progress icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   destroying project ... ews-team/icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   deleting directory ... icyleaf-salt
2018-04-26 17:04:26 +08:00   INFO   delete repository ... done
```

## 迁移工具

请看 [迁移文档](migrate.md)
