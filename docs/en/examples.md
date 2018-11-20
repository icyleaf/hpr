# Examples

We archive some examples to help you use it.

## Self-host Gitlab

Prepare `config/hpr.json` file, this is a sample:

```json
{
  "schedule_in": "1.day",
  "basic_auth": {
    "enable": false,
    "user": "hpr",
    "password": "p@ssw0rd"
  },
  "gitlab": {
    "ssh_port": 22,
    "endpoint": "http://10.10.10.221:9000/api/v4",
    "private_token": "<private-token>",

    "group_name": "hpr-mirrors",

    "project_public": true,
    "project_issue": false,
    "project_wiki": false,
    "project_merge_request": false,
    "project_snippet": false
  },
  "sentry" : {
    "report": false,
    "dns": "http://<key>@<host>:<port>/<project>"
  }
}
```

Store config file to `/data/volumes/hpr-data/config/hpr.json`, Then create your own docker instance:

```bash
$ docker run -d --restart=unless-stopped --name hpr \
  -v /data/volumes/hpr-data:/app \
  -v /data/volumes/hpr-redis-data:/data \
  -p 8848:8848 \
  icyleafcn/hpr:ubuntu

Generating public/private rsa key pair ...

SSH PUBLIC KEY:
##################################################################
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD1gmxn5Rk5N1mRGzynZgYyeKb4Q5OsoQ9erLZY1nP6i8ICL+Dn+b/6YoFUcdIBsE1sv9eu6fyP7TfdLD8FWV6qK9rJSwJFq3wTF6Liu+fOSHOpDffTcAQ5dciIzu/goheYwfKekcu6EiGTn9XdHtXwOgC0+T1OLu0dskUyMhyIsYxJiDlAJL6YFgMRXVE6HPZp3XfXP2BuVCo8WydfKgs8EyQ4pbQ3yGvvb2jUgeJX+Qb4OcbKyrO7i/L2KidE2Xzzxx6QBWNkPDvGnh0b12E6UApEq99cY5bURw7qSsOfY4ct1GgMHdsjeEN4olcIici+11+iQPR3VocePbFVxEt3 hpr@docker
##################################################################
...
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
Using config: /app/config/hpr.json
[224] Salt server starting ...
[224] * Version 0.4.4 (Crystal 0.27.0)
[224] * Environment: production
[224] * Listening on http://0.0.0.0:8848/
[224] Use Ctrl-C to stop
```

Copy ssh public key and create it to gitlab.

## Gitlab hosting services

### gitlab.com

Prepare `config/hpr.json` file, this is a sample:

```json
{
  "schedule_in": "1.day",
  "basic_auth": {
    "enable": false,
    "user": "hpr",
    "password": "p@ssw0rd"
  },
  "gitlab": {
    "ssh_port": 22,
    "endpoint": "http://gitlab.com/api/v4",
    "private_token": "<private-token>",

    "group_name": "hpr-mirrors",

    "project_public": true,
    "project_issue": false,
    "project_wiki": false,
    "project_merge_request": false,
    "project_snippet": false
  },
  "sentry" : {
    "report": false,
    "dns": "http://<key>@<host>:<port>/<project>"
  }
}
```

Store config file to `/data/volumes/hpr-data/config/hpr.json`, Then create your own docker instance:

```bash
$ docker run -d --restart=unless-stopped --name hpr \
  -v /data/volumes/hpr-data:/app \
  -v /data/volumes/hpr-redis-data:/data \
  -p 8848:8848 \
  icyleafcn/hpr:ubuntu

Generating public/private rsa key pair ...

SSH PUBLIC KEY:
##################################################################
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD1gmxn5Rk5N1mRGzynZgYyeKb4Q5OsoQ9erLZY1nP6i8ICL+Dn+b/6YoFUcdIBsE1sv9eu6fyP7TfdLD8FWV6qK9rJSwJFq3wTF6Liu+fOSHOpDffTcAQ5dciIzu/goheYwfKekcu6EiGTn9XdHtXwOgC0+T1OLu0dskUyMhyIsYxJiDlAJL6YFgMRXVE6HPZp3XfXP2BuVCo8WydfKgs8EyQ4pbQ3yGvvb2jUgeJX+Qb4OcbKyrO7i/L2KidE2Xzzxx6QBWNkPDvGnh0b12E6UApEq99cY5bURw7qSsOfY4ct1GgMHdsjeEN4olcIici+11+iQPR3VocePbFVxEt3 hpr@docker
##################################################################
...
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
Using config: /app/config/hpr.json
[224] Salt server starting ...
[224] * Version 0.4.4 (Crystal 0.27.0)
[224] * Environment: production
[224] * Listening on http://0.0.0.0:8848/
[224] Use Ctrl-C to stop
```

Copy ssh public key and create it to gitlab.com.
