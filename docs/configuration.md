# 配置文件

hpr 默认提供了一个模板文件 `config/hpr.example.yml` 可根据自己的需求做调整。

目前 hpr 只能从 `config/hpr.yml` 获取配置，请务必保证配置的路径和文件名没有错误。

## schedule_in

镜像仓库的更新频率，频率设置是针对每个仓库进行单独设置，不会造成同一时间更新全部镜像仓库。

接受以分钟为单位的整型和可识别时间类型的字符串型。没有匹配到的规则会默认转换为分钟。

时间单位 | 类型 | 可用值 | 举例
---|---|---|---
分钟 | string/integer | `整型数字`/`minute`/`minutes` | 60<br />1.minute<br />30.minutes
小时 | string | `hour`/`hours` | 1.hour<br />5.hours
天 | string | `day`/`days` | 1.day<br />10.days
周 | string | `week`/`weeks` | 1.week<br />2.weeks
月 | string | `month`/`months` | 1.month<br />6.months
年 | string | `year`/`years` | 1.year<br />2.years

## basic_auth

HTTP APIs 认证机制，如果需要暴露在外网访问为了安全起见目前支持了 basic auth 认证机制。

| 名称 | 类型 | 说明 | 备注 |
|---|---|---|---|
| enable | boolean | 是否开启认证 | `true`/`false` |
| user | string | 用户名 | |
| password | string | 密码 | |

## gitlab

镜像服务 gitlab 的必备的配置参数。必须设置的主要是 `endpoint`、`prite_token` 和 `group_name`。

| 名称 | 类型 | 说明 | 备注 |
|---|---|---|---|
| endpoint | boolean | Gitlab 接口地址 | 支持非 GraphQL 的所有版本(v3/v4) |
| private_token | string | Gitlab 接口访问的私钥 | 新版本改名叫 Access Token |
| group_name | string | 镜像的组名 | 如果没有创建组权限需要提前准备好，<br />目前不支持创建在个人项目中 |
| project_public | boolean | 是否公开项目 | 非私有项目一般会选择公开，无法设置内部公开 |
| project_issue | boolean | 是否开启 Issue | `true`/`false` |
| project_wiki | boolean | 是否开启 Wiki | `true`/`false` |
| project_merge_request | boolean | 是否开启 MR | `true`/`false` |
| project_snippet | boolean | 是否开启 Snippet | `true`/`false` |

## sentry

匿名错误上报，建议在 hpr 还未稳定之前保持开启状态，hpr 使用过程中遇到的各种问题上报对于尽快修复有很大的帮助作用，同时也减少了您提 issue 的环节和填写补充信息。如果你强烈不想错误上报也可以关闭它。

| 名称 | 类型 | 说明 | 备注 |
|---|---|---|---|
| report | boolean | 是否开启上报 | `true`/`false` |
| dsn | string | DSN 地址 | 从 Sentry 获取 |
