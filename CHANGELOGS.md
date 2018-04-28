# 更新日志

所有版本的更新日志都会归档到本文件。

> 格式是基于 [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) 和 [Semantic Versioning](http://semver.org/spec/v2.0.0.html)。

## [Unreleased]

> TOOD

## [0.6.0] (2018-04-28)

### Added

- [功能] 新增搜索仓库功能（API/CLI）
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
- [配置] 修改 `schedule` 为 `schedule_in` 并修改规则（单位从秒改为分钟，并接受可读的字符串时间单位）

### Fixed

- [API] 修复创建项目时错误的 git ssh 地址的问题
- [CLI] 修复多次输出帮助

## [0.3.0] (2018-04-23)

### Added

- [API] 新增仓库在 clone 的状态（在获取仓库详情接口返回 `202`）
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

[Unreleased]: https://github.com/icyleaf/hpr/compare/v0.6.0...HEAD
[0.6.0]: https://github.com/icyleaf/hpr/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/icyleaf/hpr/compare/v0.3.0...v0.5.0
[0.3.0]: https://github.com/icyleaf/hpr/compare/v0.2.0...v0.3.0
