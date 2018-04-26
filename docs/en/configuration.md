# Configuration

You can create a new hpr config file by copying the template that we have included for you:

```
$ cp config/hpr.json.example.json config/hpr.json.json
```

For now, hpr only read config from `config/hpr.json` file.

## schedule_in

Update cycle for each repository, the min unit is miniute.

Unit | Type | Values | Samples
---|---|---|---
Minute | String/Int32/Int64 | `interge value`/`minute`/`minutes` | 60<br />"1.minute"<br />"30.minutes"
Houe | String | `hour`/`hours` | "1.hour"<br />"5.hours"
Day | String | `day`/`days` | "1.day"<br />"10.days"
Week | String | `week`/`weeks` | "1.week"<br />"2.weeks"
Month | String | `month`/`months` | "1.month"<br />"6.months"
Year | String | `year`/`years` | "1.year"<br />"2.years"

## basic_auth

You can enable basic auth for security.

| Key | Type | Description | Note |
|---|---|---|---|
| enable | boolean | Enable Basic auth | `true`/`false` |
| user | string | User | |
| password | string | Password | Be complex |

## gitlab

Config of gitlab, main key were `endpoint`, `prite_token` and `group_name`。

| Key | Type | Description | Note |
|---|---|---|---|
| endpoint | boolean | Endpoint of gitlab | Support non-GraphQL API |
| private_token | string | private token of gitlab | New version gitlab rename to Access Token |
| ssh_port | integer | ssh port of gitlab | default is 22 |
| group_name | string | name of group | Ask Admin to create group if you have not create group role<br />No support for personal namespace |
| project_public | boolean | Is public | |
| project_issue | boolean | Enable Issue | `true`/`false` |
| project_wiki | boolean | Enable Wiki | `true`/`false` |
| project_merge_request | boolean | Enable MR | `true`/`false` |
| project_snippet | boolean | Enable Snippet | `true`/`false` |
