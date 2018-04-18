# 配置文件

hpr 默认提供了一个模板文件: `config/hpr.json.example`，根据自己的需要进行修改。

目前 hpr 只能从 `config/hpr.json` 获取配置，请务必保证配置的路径和文件名没有错误。

## schedule_in

镜像仓库的更新频率，频率设置是针对每个仓库进行单独设置，不会造成统一时间全部镜像仓库。

接受以分钟为单位的整型和可识别时间类型的字符串型。没有匹配到的规则会默认转换为分钟。

时间单位 | 类型 | 可用值 | 举例
---|---|---|---
分钟 | String/Int32/Int64 | `整型数字`/`minute`/`minutes` | 60<br />"1.minute"<br />"30.minutes"
小时 | String | `hour`/`hours` | "1.hour"<br />"5.hours"
天 | String | `day`/`days` | "1.day"<br />"10.days"
周 | String | `week`/`weeks` | "1.week"<br />"2.weeks"
月 | String | `month`/`months` | "1.month"<br />"6.months"
年 | String | `year`/`years` | "1.year"<br />"2.years"

## basic_auth - 接口认证

由于默认提供 API 接口，如果需要暴露在外网访问为了安全起见目前支持了 basic auth 认证机制。

| 名称 | 类型 | 说明 | 备注 |
|---|---|---|---|
| enable | boolean | 是否开启认证 | `true`/`false` |
| user | string | 用户名 | |
| password | string | 密码 | 尽量复杂包含大小写、数字和特殊字符 |

## gitlab

这里主要是镜像服务 gitlab 的必备的配置参数。必须设置的主要是 `endpoint`、`prite_token` 和 `group_name`。

| 名称 | 类型 | 说明 | 备注 |
|---|---|---|---|
| endpoint | boolean | Gitlab 接口地址 | 支持非 GraphQL 的所有版本(v3/v4) |
| private_token | string | Gitlab 接口访问的私钥 | 新版本改名叫 Access Token |
| ssh_port | integer | gitlab 提供 ssh 协议的端口号 | 默认都是 22 |
| group_name | string | 镜像的组名 | 如果没有创建组权限需要提前准备好，<br />目前不提供在个人项目中创建 |
| project_public | boolean | 是否公开项目 | 非私有项目一般会选择公开 |
| project_issue | boolean | 是否开启 Issue | `true`/`false` |
| project_wiki | boolean | 是否开启 Wiki | `true`/`false` |
| project_merge_request | boolean | 是否开启 MR | `true`/`false` |
| project_snippet | boolean | 是否开启 Snippet | `true`/`false` |
