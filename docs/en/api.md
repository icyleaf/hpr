# Web API

hpr support a web api service (port `8848`) by default.

## Authentication

Only support Basic Auth for now. Configure from `config/hpr.json` file，View detail in [Configuration](/en/configuration?id=basic_auth-接口认证).

```bash
$ curl -u user@password http://hpr-ip:8848/info
```

## Repositores

### List repositories

```
GET /repositores
```

#### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| page | Integer | false | |
| per_page | Integer | false |  |

#### Example Response

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


### Get a repository info

```
GET /repositores/:name
```

#### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| name | String | false | Name of mirrored repository |

#### Example Response

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

### Create repository

Create a git repository, it is recommand to use HTTP protocol. The name got from url by default if left it empty but only avaiables with

- github.com
- gitlab.com
- bitbucket.org
- coding.net

`name` Rule:

- `https://github.com/icyleaf/hpr.git` => `icyleaf-hpr`
- `https://git.example.com:222/google-chrome/core` => `google-chrome-core`
- `git@icyleaf.repo.com:hpr.git` => `hpr`

```
POST /repositores
```

#### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| url | String | true | |
| name | String | false |  |

#### Example Response

It always return `true` or `false`, because the task cost too much time, the response is result of request.

```text
true
```

### Update a repository

Update a repository manually.

```
PUT /repositores/:name
```

#### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| name | String | false |  |

#### Example Response

It always return `true` or `false`, because the task cost too much time, the response is result of request.

```text
true
```

### Delete a repository

```
DELETE /repositores/:name
```

#### Parameters

| Name | Type | Required | Description |
|---|---|---|---|
| name | String | false |  |

#### Example Response

It always return `true` or `false`, because the task cost too much time, the response is result of request.

```text
true
```

## Stats

Display repositores and task queue stats.

```
GET /info
```

### Parameters

`None`

### Example Response

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
    },
    "scheduleds": [
        {
            "name": "project1",
            "scheduled_at": "2018-04-28 15:47:48 UTC"
        },
        {
            "name": "project2",
            "scheduled_at": "2018-04-28 20:47:48 UTC"
        }
    ]
}
```
