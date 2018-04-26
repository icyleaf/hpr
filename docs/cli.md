# 命令行工具

hpr 本身是一个命令行工具，因此也提供了一个临时可用的辅助命令来管理镜像仓库。

## 显示已镜像的仓库列表

```bash
$ hpr -l
# or
$ hpr --list
2018-04-26 17:05:44 +08:00   INFO   listing repositories (2):
* icyleaf-halite
* icyleaf-gitlab.cr
```

## 创建镜像仓库

```bash
$ hpr --create --url https://github.com/icyleaf/salt.git icyleaf-salt
# or
$ hpr -c -U https://github.com/icyleaf/salt.git
2018-04-26 17:04:39 +08:00   INFO   creating repository ... ews-team/icyleaf-salt
2018-04-26 17:04:41 +08:00   INFO   cloning https://github.com/icyleaf/salt.cr ... icyleaf-salt
2018-04-26 17:05:44 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:05:47 +08:00   INFO   create repository ... done
```

## 更新镜像仓库

```bash
$ hpr -u icyleaf-salt
2018-04-26 17:04:01 +08:00   INFO   updating from origin ... icyleaf-salt
2018-04-26 17:04:06 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:04:07 +08:00   INFO   update repository ... done
```

## 删除镜像仓库

```bash
$ hpr -d icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   destroying project ... ews-team/icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   deleting directory ... icyleaf-salt
2018-04-26 17:04:26 +08:00   INFO   delete repository ... done
```
