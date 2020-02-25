# API 接口

hpr 运行后会提供 HTTP API 接口，默认端口 `8848`。

## 接口认证

接口请求目前仅支持 Basic Auth，通过[配置文件](configuration?id=basic_auth-接口认证)进行配置是否开启（默认关闭）。

```bash
$ curl http://hpr-ip:8848/info
```

## 镜像仓库

### 镜像仓库列表

获取已镜像仓库信息列表，支持分页

```
GET /repositories
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| page | integer | false | 页数|
| per_page | integer | false | 每页返回最大数目 |

#### 返回样例

```json
{
    "total": 2,
    "data": [
        {
            "name": "coding-coding-docs",
            "url": "https://git.coding.net/coding/coding-docs.git",
            "mirror_url": "git@git.example.com:hpr-mirrors/coding-coding-docs.git",
            "gitlab_project_id": 1,
            "status": "idle",
            "created_at": "2018-03-23 16:27:59 +0800",
            "updated_at": "2018-03-23 16:27:59 +0800",
            "scheduled_at": "2018-03-23 17:28:02 +0800"
        },
        {
            "name": "spf13-viper",
            "url": "https://github.com/spf13/viper.git",
            "mirror_url": "git@git.example.com:hpr-mirrors/spf13-viper.git","gitlab_project_id": 2,
            "status": "idle",
            "created_at": "2018-03-23 16:36:00 +0800",
            "updated_at": "2018-03-23 16:36:00 +0800",
            "scheduled_at": "2018-03-23 17:36:02 +0800"
        }
    ]
}
```

### 搜索镜像仓库

根据关键词搜索镜像仓库，只要关键词匹配到任意镜像仓库名的字符串均会命中。

```
GET /repositories/search?q={:name}
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | string | true | 搜索仓库的名称，默认是模糊搜索 |

#### 返回样例

```json
{
    "total": 2,
    "data": [
        {
            "name": "coding-coding-docs",
            "url": "https://git.coding.net/coding/coding-docs.git",
            "mirror_url": "git@git.example.com:hpr-mirrors/coding-coding-docs.git",
            "gitlab_project_id": 1,
            "status": "idle",
            "created_at": "2018-03-23 16:27:59 +0800",
            "updated_at": "2018-03-23 16:27:59 +0800",
            "scheduled_at": "2018-03-23 17:28:02 +0800"
        },
        {
            "name": "spf13-viper",
            "url": "https://github.com/spf13/viper.git",
            "mirror_url": "git@git.example.com:hpr-mirrors/spf13-viper.git",
            "gitlab_project_id": 2,
            "status": "idle",
            "created_at": "2018-03-23 16:36:00 +0800",
            "updated_at": "2018-03-23 16:36:00 +0800",
            "scheduled_at": "2018-03-23 17:36:02 +0800"
        }
    ]
}
```

### 获取单个镜像仓库信息

获取已镜像仓库的基本信息

```
GET /repositories/:name
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | string | true | 镜像名字 |

#### 返回样例

```json
{
  "name": "coding-coding-docs",
  "url": "https://git.coding.net/coding/coding-docs.git",
  "mirror_url": "git@git.example.com:hpr-mirrors/coding-coding-docs.git",
  "gitlab_project_id": 1,
  "status": "idle",
  "created_at": "2018-03-23 16:27:59 +0800",
  "updated_at": "2018-03-23 16:27:59 +0800",
  "scheduled_at": "2018-03-23 17:28:02 +0800"
}
```

### 创建镜像仓库

创建一个镜像仓库，仓库地址最好是 HTTP 协议的，如果有定制化需求可设置 `name` 参数，如果不设置会进行自动截取。

目前个人测试支持的服务有：

- github.com
- gitlab.com
- bitbucket.org
- coding.net

关于 `name` 的智能截取的规则是尝试获取 url 最后两个路径的地址作为 namespace 和 name，如果两者都存在以 `-` 为分隔进行拼接。

- `https://github.com/icyleaf/hpr.git` => `icyleaf-hpr`
- `https://git.example.com:222/google-chrome/core` => `google-chrome-core`
- `git@icyleaf.repo.com:hpr.git` => `hpr`


```
POST /repositories
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| url | string | true | 仓库地址 |
| name | string | false | 镜像名字，不填写默认从 url 自动获取 |
| create | string | false | 是否创建 gitlab 项目，默认是 "true" |
| clone | string | false | 是否克隆原仓库并推送到 gitlab，默认是 "true" |

#### 返回样例

鉴于镜像的过程比较长，耗时操作将会丢入任务队列异步完成，这里只会返回操作是否提交成功。

```json
{
  "job_id": "fee876a506255c701d06d5b7"
}
```

### 更新镜像仓库

强制同步更新镜像仓库

```
PUT /repositories/:name
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | string | true | 镜像名字 |

#### 返回样例

鉴于镜像的过程比较长，耗时操作将会丢入任务队列异步完成，这里只会返回操作是否提交成功。

```json
{
  "job_id": "fee876a506255c701d06d5b7"
}
```

### 删除镜像仓库

删除镜像仓库，包括数据库记录、本地 git 镜像文件和 Gitlab 创建的项目。

```
DELETE /repositories/:name
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | string | true | 镜像名字 |

#### 返回样例

鉴于镜像的过程比较长，耗时操作将会丢入任务队列异步完成，这里只会返回操作是否提交成功。

```json
{
  "job_id": "fee876a506255c701d06d5b7"
}
```

## 统计信息

### 查看基本信息

显示当前仓库和任务队列的统计信息。

```
GET /info
```

### 参数

`无`

### 返回样例

```json
{
    "hpr": {
        "version": "0.12.0",
        "repositroies": 2,
    },
    "jobs": {
        "total_scheduled": 2,
        "total_enqueued": 0,
        "total_failures": 0,
        "total_processed": 111,
        "total_queues": {
            "default": 0
        }
    }
}
```

### 查看定时更新仓库任务列表

显示已镜像仓库的定时更新任务列表

```
GET /info/scheduled
```

### 参数

`无`

### 返回样例

```json
{
    "jobs": {
        "total_scheduled": 2,
        "total_enqueued": 0,
        "total_failures": 0,
        "total_processed": 111,
        "total_queues": {
            "default": 0
        }
    }
}
```


### 查看正在更新仓库任务列表

显示已镜像仓库正在更新任务列表

```
GET /info/busy
```

### 参数

`无`

### 返回样例

```json
{
    "jobs": {
        "total_scheduled": 2,
        "total_enqueued": 0,
        "total_failures": 0,
        "total_processed": 111,
        "total_queues": {
            "default": 0
        }
    }
}
```

## 查看配置

显示 hpr 配置信息。

```
GET /config
```

### 参数

`无`

### 返回样例

```json
{
  "schedule_in": "1.minute",
  "basic_auth": {
    "enable": false,
    "user": "hpr",
    "password": "p@ssw0rd"
  },
  "gitlab": {
    "endpoint": "http://gitlab.example.com/api/v4",
    "private_token": "<private_token-or-access_token>",
    "group_name": "mirrors",
    "project_public": false,
    "project_issue": false,
    "project_wiki": false,
    "project_merge_request": false,
    "project_snippet": false
  },
  "sentry": {
    "report": true,
    "dns": "https://cd580221c955434b84d8c7fce2e9ed8d:0df7f10ecc864d8b9e77fbaf8f448fe8@sentry.io/1525034"
  },
  "repository_path": "/app/repositories/mirrors"
}
```
