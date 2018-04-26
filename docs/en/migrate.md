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

Then, migrate old repositories directory to hpr:

```bash
# get $repo_dir value from config.sh，default is /home/gitmirror/repositories
$ cd /home/gitmirror/repositories

# Copy the whole directory to hpr's directory
$ cp -r mirrors /path/to/hpr/repositories
```

Finally, edit docker-compose.yml file:

```yaml
version: '2'

services:
  hpr:
    image: icyleafcn/hpr
    ports:
      - 8848:8848
    volumes:
      - ./config:/app/config
      - /path/to/hpr/repositories:/app/repositories
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

Run `docker-compose up -d`

Apply the update by schedule, you need do this:

```ruby
# gem install http
require 'http'

# Change to ip or address which hpr is
hpr_url = 'http://localhost:8848/repositories'

repositories = HTTP.get(hpr_url).parse
repositories.each do |repo|
  url = File.join(hpr_url, repo["name"])
  HTTP.put url
end
```

By default, Update cycle is every hour in `schedule` (`config/hpr.json`).
