# linux-hub

Create Linux users from Github Teams

## Challenges

If you want to use immutable AMIs it can be difficult to give users access,
you need to deploy a new version of your AMI.

Netflix [BLESS](https://github.com/Netflix/bless) serves to solve a similar problem, but is much more complicated (and feature rich).

## Solution

Github exposes all users public SSH keys via their API
We can associate users to a Github Team
We can query the members of a team via the Github API, provided we have an access key with 'read:org' permissions

So we can therefore use the Github API to provide authorization and authentication of users to systems.

## Usage

The idea of this gem is to be run as a cron job, to synchronise users at a regular interval. You need to create a config file that specifies:
- The organisation to find the team in
- The team who are permitted access
- The access key to query team membership

Example config:
```yaml
---
organisation: github
team: sysadmins
access_token: baconfoobar
```

Example command:

```
linux-hub --config-file config/config.yaml --sync-users
```
