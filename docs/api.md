# API 接口

hpr 运行后会提供 Web API 接口，端口号 `8848`。

## 认证

接口请求目前仅支持 Basic Auth，通过配置文件 `config/hpr.json` 进行配置，详情参见[配置文件](configuration?id=basic_auth-接口认证)说明。

```bash
$ curl -u user@password http://hpr-ip:8848/info
```

## 仓库

### 镜像仓库列表

```
GET /repositores
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| page | Integer | false | 页数|
| per_page | Integer | false | 每页返回最大数目 |

#### 返回样例

```json
{
    "total": 2,
    "data": [
        {
            "name": "coding-coding-docs",
            "url": "https://git.coding.net/coding/coding-docs.git",
            "mirror_url": "git@git.example.com:hpr-mirrors/coding-coding-docs.git",
            "latest_version": "",
            "status": "idle",
            "created_at": "2018-03-23 16:27:59 +0800",
            "updated_at": "2018-03-23 16:27:59 +0800",
            "scheduled_at": "2018-03-23 17:28:02 +0800"
        },
        {
            "name": "spf13-viper",
            "url": "https://github.com/spf13/viper.git",
            "mirror_url": "git@git.example.com:hpr-mirrors/spf13-viper.git",
            "latest_version": "v1.0.2",
            "status": "idle",
            "created_at": "2018-03-23 16:36:00 +0800",
            "updated_at": "2018-03-23 16:36:00 +0800",
            "scheduled_at": "2018-03-23 17:36:02 +0800"
        }
    ]
}
```


### 单个镜像仓库信息

```
GET /repositores/:name
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | String | false | 镜像名字 |

#### 返回样例

```json
{
  "name": "coding-coding-docs",
  "url": "https://git.coding.net/coding/coding-docs.git",
  "mirror_url": "git@git.example.com:hpr-mirrors/coding-coding-docs.git",
  "latest_version": "",
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
POST /repositores
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| url | String | true | 仓库地址 |
| name | String | false | 镜像名字，不填写默认从 url 自动获取 |

#### 返回样例

鉴于镜像的过程比较长，耗时操作将会丢入任务队列异步完成，这里只会返回操作是否提交成功。

```text
true
```

### 更新镜像仓库

强制更新镜像仓库

```
PUT /repositores/:name
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | String | false | 镜像名字 |

#### 返回样例

鉴于镜像的过程比较长，耗时操作将会丢入任务队列异步完成，这里只会返回操作是否提交成功。

```text
true
```

### 删除镜像仓库

删除镜像仓库

```
DELETE /repositores/:name
```

#### 参数

| 名称 | 类型 | 是否必须 | 描述 |
|---|---|---|---|
| name | String | false | 镜像名字 |

#### 返回样例

鉴于镜像的过程比较长，耗时操作将会丢入任务队列异步完成，这里只会返回操作是否提交成功。

```text
true
```

## 统计信息

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
        "version": "0.2.0",
        "repositroies": {
            "total": 2,
            "entry": [
                "project1",
                "project2"
            ]
        }
    },
    "jobs": {
        "total_scheduled": 7,
        "total_enqueued": 0,
        "total_failures": 0,
        "total_processed": 111,
        "total_queues": {
            "default": 0
        }
    }
}
```
