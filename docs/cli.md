# 命令行工具

hpr 本身是一个命令行工具，因此也提供了一个临时可用的辅助命令来管理镜像仓库。

## 显示已镜像的仓库列表

```bash
$ hpr -l
# or
$ hpr --list
Here are 4 mirrored repositories:
* icyleaf-gitlab.cr
* icyleaf-halite
* icyleaf-salt
```

## 创建镜像仓库

```bash
$ hpr --create --url https://github.com/icyleaf/salt.git icyleaf-salt
# or
$ hpr -c -U https://github.com/icyleaf/salt.git
```

## 更新镜像仓库

```bash
$ hpr -u icyleaf-salt
```

## 删除镜像仓库

```bash
$ hpr -d icyleaf-salt
```
