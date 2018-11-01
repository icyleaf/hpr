# Migrate to hpr

A list of community-developed tools for migrating from your existing tools to hpr.

## gitlab-mirrors

[gitlab-mirrros](https://github.com/samrocketman/gitlab-mirrors) is a set of scripts adding the ability of managing remote mirrors to GitLab.
But dependencs python and outdated for years.

Migrate to hpr, you need copy the key values of config:

Name | gitlab-mirrors | hpr | Optional
---|---|---|---
Config file | `config.sh` | `config/hpr.json` | **No**
Gitlab URL | gitlab_url | gitlab.endpoint | **No**
Gitlab user token | gitlab_user_token_secret | gitlab.private_token | **No**
gitlab group name | gitlab_namespace | gitlab.group_name | **No**
Is Public | public | gitlab.project_public | Yes
Enable Issue | issues_enabled | gitlab.project_issue | Yes
Enable Wiki | wiki_enabled | gitlab.project_wiki | Yes
Enable Snippets | snippets_enabled | gitlab.project_snippet | Yes
Enable MR | merge_requests_enabled | gitlab.project_merge_request | Yes

More about hpr's config to check [Configurateion](/en/configuration.md) page.

Next step, you need get the path of gitlab-mirrors's repositories directory: get $repo_dir value from config.sh，default is /home/gitmirror/repositories

Then edit docker-compose.yml file, next move is run `docker-compose up -d`

```yaml
version: '2'

services:
  hpr:
    image: icyleafcn/hpr
    ports:
      - 8848:8848
    volumes:
      - /my/own/hprdir:/app
      - /home/gitmirror/repositories:/tmp/old-repositories
    environment:
      REDIS_URL: tcp://redis:6379
      REDIS_PROVIDER: REDIS_URL

      HPR_SSH_HOST: git.example.com
      HPR_SSH_PORT: 22
    depends_on:
      - redis
  redis:
    image: redis:alpine
```

Hpr is running now, but the data is not migrate, hpr provides a migration command tool named "hpr-migration" to make this move easily:

```bash
$ docker-compose exec hpr hpr-migration --endpoint "http://localhost:8848" /tmp/old-repositories
* project1
 - Configuring git remote ...
 - Updating and pushing mirror
* project2
 - Create gitlab repository
 - Configuring git remote ...
 - Updating and pushing mirror
* project3
 - Existed, Skip
```

You can get migrated data via [stats](/en/api.md#id=stats) api.
By default, Update cycle is every hour in `schedule` (`config/hpr.json`).
