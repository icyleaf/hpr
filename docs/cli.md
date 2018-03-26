# Cli

hpr 本身是一个命令行工具，因此也提供了一个临时可用的辅助命令来管理镜像仓库。

## 显示已镜像的仓库列表

```bash
$ hpr -l
```

## 创建镜像仓库

```bash
$ hpr -c --name hpr-mirror https://github.com/icyleaf/hpr.git
```

## 更新镜像仓库

```bash
$ hpr -u --name hpr-mirror
```

## 删除镜像仓库

```bash
$ hpr -d --name hpr-mirror
```
