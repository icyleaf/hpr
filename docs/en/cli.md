# CLI

hpr is a command line tool, it also support some commands to manage mirror repositories temporary.

## Run Web API server

```bash
$ hpr -s
# Or customize server port
$ hpr -s --port 8848
  _
 | |__  _ __  _ __
 | '_ \| '_ \| '__|
 | | | | |_) | |
 |_| |_| .__/|_|
       |_|
2018-04-28 10:06:42 +08:00   INFO   API Server now listening at localhost:8848, press Ctrl-C to stop
```

## List repositories

```bash
$ hpr -l
# or
$ hpr --list
2018-04-28 18:01:32 +08:00   INFO   listing repositories (2):

=> Name: icyleaf-gitlab.cr
   Path: /Users/icyleaf/data/repositories/icyleaf-gitlab.cr
   OriginalUrl: https://github.com/icyleaf/gitlab.cr
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-gitlab.cr.git
   Status: idle
   CreatedAt: 2018-04-26 17:05:44 +0800
   UpdatedAt: 2018-04-26 17:05:46 +0800
   ScheduledAt: 2018-04-29 05:05:46 +0800

=> Name: icyleaf-salt
   Path: /Users/icyleaf/data/repositories/icyleaf-salt
   OriginalUrl: https://github.com/icyleaf/salt.git
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-salt.git
   Status: idle
   CreatedAt: 2018-04-28 18:00:56 +0800
   UpdatedAt: 2018-04-28 18:00:58 +0800
   ScheduledAt: 2018-05-01 06:00:58 +0800
```

## Search repositories

```bash
$ hpr -S icyleaf
# or
$ hpr --search icyleaf

2018-04-28 18:07:34 +08:00   INFO   searching repositories ... icyleaf
2018-04-28 18:07:34 +08:00   INFO   found repositories (2):

=> Name: icyleaf-gitlab.cr
   Path: /Users/icyleaf/data/repositories/icyleaf-gitlab.cr
   OriginalUrl: https://github.com/icyleaf/gitlab.cr
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-gitlab.cr.git
   Status: idle
   CreatedAt: 2018-04-26 17:05:44 +0800
   UpdatedAt: 2018-04-26 17:05:46 +0800
   ScheduledAt: 2018-04-29 05:05:46 +0800

=> Name: icyleaf-salt
   Path: /Users/icyleaf/data/repositories/icyleaf-salt
   OriginalUrl: https://github.com/icyleaf/salt.git
   MirrorUrl: git@git.example.com:hpr-mirrors/icyleaf-salt.git
   Status: idle
   CreatedAt: 2018-04-28 18:00:56 +0800
   UpdatedAt: 2018-04-28 18:00:58 +0800
   ScheduledAt: 2018-05-01 06:00:58 +0800
```

## Create a new repository

```bash
$ hpr -c -U https://github.com/icyleaf/salt.git icyleaf-salt
# or
$ hpr --create --url https://github.com/icyleaf/salt.git
2018-04-26 17:04:39 +08:00   INFO   creating repository ... ews-team/icyleaf-salt
2018-04-26 17:04:41 +08:00   INFO   cloning https://github.com/icyleaf/salt.cr ... icyleaf-salt
2018-04-26 17:05:44 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:05:47 +08:00   INFO   create repository ... done
```

## Update a repository

```bash
$ hpr -u icyleaf-salt
# or
$ hpr --update icyleaf-salt
2018-04-26 17:04:01 +08:00   INFO   updating from origin ... icyleaf-salt
2018-04-26 17:04:06 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:04:07 +08:00   INFO   update repository ... done
```

## Delete a repository

```bash
$ hpr -d icyleaf-salt
# or
$ hpr --delete icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   destroying project ... ews-team/icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   deleting directory ... icyleaf-salt
2018-04-26 17:04:26 +08:00   INFO   delete repository ... done
```
