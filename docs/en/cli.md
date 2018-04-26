# Cli

hpr is a command line tool, it also support some commands to manage mirror repositories temporary.

## List repositories

```bash
$ hpr -l
# or
$ hpr --list
2018-04-26 17:05:44 +08:00   INFO   listing repositories (2):
* icyleaf-halite
* icyleaf-gitlab.cr
```

## Create a new repository

```bash
$ hpr --create --url https://github.com/icyleaf/salt.git icyleaf-salt
# or
$ hpr -c -U https://github.com/icyleaf/salt.git
2018-04-26 17:04:39 +08:00   INFO   creating repository ... ews-team/icyleaf-salt
2018-04-26 17:04:41 +08:00   INFO   cloning https://github.com/icyleaf/salt.cr ... icyleaf-salt
2018-04-26 17:05:44 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:05:47 +08:00   INFO   create repository ... done
```

## Update a repository

```bash
$ hpr -u icyleaf-salt
2018-04-26 17:04:01 +08:00   INFO   updating from origin ... icyleaf-salt
2018-04-26 17:04:06 +08:00   INFO   pushing to mirror ... icyleaf-salt
2018-04-26 17:04:07 +08:00   INFO   update repository ... done
```

## Delete a repository

```bash
$ hpr -d icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   destroying project ... ews-team/icyleaf-salt
2018-04-26 17:04:25 +08:00   INFO   deleting directory ... icyleaf-salt
2018-04-26 17:04:26 +08:00   INFO   delete repository ... done
```
