#!/bin/bash


export HUBOT_GITHUB_TOKEN="${CFG_GITHUB_HUBOT_TOKEN}"
#export HUBOT_GITHUB_WEBHOOK_SECRET=- Optional, if you are using webhooks and have a secret set this for additional security checks on payload delivery
#export HUBOT_GITHUB_URL=- Set this value if you are using Github Enterprise default: https://api.github.com
#export HUBOT_GITHUB_ORG= Github Organization Name (the one in the url)
export HUBOT_GITHUB_REPOS_MAP='{"git":["ballab1/jenkins","ballab1/jenkins-config","ballab1/jenkins-files","ballab1/mysql_init","ballab1/rails","ballab1/update-check","ballab1/UptimePipline" ]}'
export HUBOT_SLACK_TOKEN="${CFG_SLACK_HUBOT_TOKEN}"
export HUBOT_BOT_NAME=hubot



cat << EOF > /home/bobb/prod/hubot/hubot.conf
## Bot Settings
export HUBOT_NAME="${CFG_GITHUB_HUBOT_TOKEN}" # what hubot listens to
## Slack adapter settings
# Credentials
export HUBOT_SLACK_TOKEN="${CFG_SLACK_HUBOT_TOKEN}"
EOF

