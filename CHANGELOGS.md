# 更新日志

所有版本的更新日志都会归档到本文件。

> 格式是基于 [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) 和 [Semantic Versioning](http://semver.org/spec/v2.0.0.html)。

## [Unreleased]

> TODO

### Changed

- [API] `/repositories` 创建仓库 API 参数改名 `mirror_only` 为 `create` 并新增 `clone` 参数
- [CLI] 创建仓库传递参数保持上面一条的同步：参数改名 `--mirror_only` 改为 `--no-create` 并新增 `--no-clone` 参数
- [CLI] 执行 `hpr` 命令没有带任何参数时默认显示帮助文档
- [Core] 新版本 Gitlab 项目的 path 支持大小写区分，此版本将会尽量保证和原仓库大小写一致(**不再强制小写**)
- [Core] 镜像的仓库目录结构发生变动，由原来的 `repositories` 和镜像仓库目录中间新增了 `group_name` (从配置文件获取)，为以后支持多 group 做扩展
- [Core] 为了消除歧义修改 git remote 名为 `hpr` (之前是 `mirror`)
- [Core] 仓库的状态删除 `busy` 并扩展为 `fetching`/`pushing`

### Added

- [CLI] 新增独立命令 `hpr-migration` 迁移命令 (目前为止仅支持 gitlab-mirror`)
- [CLI] 新增全局参数 `--file` 可以指定自定义的 hpr.json 配置文件.

### Fixed

- [API] 修复丢失 layer 入口文件(docker 镜像不受影响)
- [API] 修复删除仓库可能会出现随机删除的问题(gitlab 接口发生变化)
- [Core] 修复在更新仓库过程中 gitlab 对于项目的描述没有更新或只保留了 `[Syncing]` 文案
- [Core] 修复一些日志输出多处不一致的文案

### Changed

- [API] `/repositories/search` 搜索仓库 API 参数从 query 改为 uri path 方式，名称从 `q` 改为 `keyword`

## [0.6.2] (2018-06-20)

### Fixed

- [CLI] 修复运行时 redis 服务器无法连接造成无法创建异步任务
- [Core] 升级支持 Crystal 0.25.0

## [0.6.0] (2018-04-28)

### Added

- [功能] 新增搜索仓库功能(API/CLI)
- [文档] 命令行工具增加 `hpr server` 的说明
- [文档] 命令行工具增加样例
- [文档] 增加使用 homebrew 安装 hpr
- [文档] 100% 同步英文文档

### Fixed

- [文档] 一些层级错误的修正

## [0.5.0] (2018-04-26)

### Added

- [API] `/info` 接口增加异步任务相关的统计数据
- [CLI] 允许指定自定义的 web 端口

### Changed

- [CLI] 统一所有的日志的格式
- [CLI] 增加更有帮助的日志
- [配置] 修改 `schedule` 为 `schedule_in` 并修改规则 (单位从秒改为分钟，并接受可读的字符串时间单位)

### Fixed

- [API] 修复创建项目时错误的 git ssh 地址的问题
- [CLI] 修复多次输出帮助

## [0.3.0] (2018-04-23)

### Added

- [API] 新增仓库在 clone 的状态 (在获取仓库详情接口返回 `202`)
- [文档] 新增专属的文档系统
- [功能] 新增 Makefile 管理常用操作
- [CLI] 统一所有的日志的格式
- [CLI] 把 sidekiq 的日志写入 `logs/sidekiq.log` 文件

### Changed

- [Core] 使用 sidekiq + redis 替换 faktory 作为异步任务队列的解决方案

### Fixed

- [CLI] 修复捕捉 singal 的退出提醒
- [API] 修复 404 页面的正常数据结构

## 0.2.0 (2018-03-23)

- 第一个测试版本

[Unreleased]: https://github.com/icyleaf/hpr/compare/v0.6.2...HEAD
[0.6.2]: https://github.com/icyleaf/hpr/compare/v0.6.0...v0.6.2
[0.6.0]: https://github.com/icyleaf/hpr/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/icyleaf/hpr/compare/v0.3.0...v0.5.0
[0.3.0]: https://github.com/icyleaf/hpr/compare/v0.2.0...v0.3.0
