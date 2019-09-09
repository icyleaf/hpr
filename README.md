# ḫpr

镜像任意 git 仓库到 Gitlab 的同步工具，具有定时更新的功能。

## 独特优势

* 支持 API 接口，可用于远程控制不仅限于终端使用
* 支持终端命令控制，方便临时使用
* 定时更新镜像的仓库，时间可调，告别不靠谱的 crontab
* 几乎支持所有的 git 托管的仓库
* 使用可独立部署的 Gitlab 作为镜像平台。

## 开始使用

## Docker

```
$ docker pull icyleafcn/hpr
$ curl -fsSL -o hpr.yml https://raw.githubusercontent.com/icyleaf/hpr/master/config/hpr.example.yml
$ docker run --name hpr --restart=unless-stopped -d \
             -p 8848:8848 \
             -v `pwd`/hpr.yml:/app/config/hpr.yml \
             icyleafcn/hpr
```

### 本地部署

先安装依赖 ruby 2.3+、redis 和 sqlite-lib（如果是 Linux 环境），后复制 `config/hpr.example.yml` 为 `config/hpr.yml` 修改对应的参数。

```bash
$ bundle install
$ bundle exec guard start
```

具体配置和说明请移步[本教程](https://hpr.ews.im/#/quickstart)

如果还有哪里遗漏或不足的请[提交申请](https://github.com/icyleaf/hpr/issues/new)。

## 贡献你的力量

本项目由 Ruby 语言编写而成，欢迎贡献你的力量！

1. [Fork 本项目](https://github.com/icyleaf/hpr/fork)
2. 创建你的新特性/修复分支 (`git checkout -b my-new-feature`)
3. 提交你的代码 (`git commit -am 'Add some feature'`)
4. 推送分支到服务器 (`git push origin my-new-feature`)
5. 创建一个新的 PR

## 项目维护者

- [icyleaf](https://github.com/icyleaf) - 核心开发维护者

# 关于项目名和图标

本来就是个`镜像和更新`的项目脑海中就联想来屎壳郎这个名字，但这个名字英文有长又无法凸现特色，正好在维基百科看到了牛哄哄的变体[圣甲虫](https://zh.wikipedia.org/wiki/%E8%81%96%E7%94%B2%E8%9F%B2)。
