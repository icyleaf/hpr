# 版本升级

Hpr 目前还是开发阶段每个版本可能会有大的变化，这里归档了各个版本升级所需的步骤。

## Docker

推荐使用 Docker 的原因在于在于升级方便便捷，先停止正在运行的 hpr 容器：

```bash
$ docker stop <container_name_of_hpr>
```

创建 hpr-data 数据备份容器

```bash
$ docker create --volume-from <container_name_of_hpr> \
                --name hpr-data hpr:<tag_of_previous_hpr>
```

拉取最新版本的 hpr

```bash
$ docker pull hpr:latest
```

使用原由备份数据运行新版本

```bash
$ docker run --volumes-from hpr-data -d \
             --restart=unless-stopped \
             -p 8848:8848 \
             hpr:latest
```
