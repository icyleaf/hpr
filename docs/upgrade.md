# 版本升级

Hpr 目前还是开发阶段每个版本可能会有大的变化，这里归档了各个版本升级所需的步骤。

## 通用升级方案

先停止 hpr 服务

```bash
$ docker stop <container_name_of_hpr>
```

创建 hpr-data 数据备份镜像

```bash
$ docker create --volume-from <container_name_of_hpr> --name hpr-data hpr:<tag_of_previous_hpr>
```

拉取最新版本的 hpr

```bash
$ docker pull hpr:latest
```

部启新版本

```bash
$ docker run -d --volumes-from hpr-data --restart=unless-stopped \
  -p 8848:8848 hpr:latest
```

## 不同版本的迁移

### `0.9.x` 升级至 `0.10.0`

`v0.10.0` 开始仓库采用数据库取代 git config 作文章的方法，已经使用的用户可通过内置的 `hpr upgrade` 隐藏命令来升级。

在完成通用升级之后，需要在执行下如下命令

```bash
$ docker exec <container_name_of_hpr> hpr upgrade
icyleaf-halite ... [UPGRADED]
icyleaf-totem ... [UPGRADED]
```

看到 **[UPGRADED]** 说明该仓库已经处理完成，如果显示 **[PASS]** 则代表已经迁移过无需处理。
