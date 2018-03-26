#!/bin/bash

## Slack adapter settings
export HUBOT_BOT_NAME="${HUBOT_BOT_NAME:?'Envorinment variable HUBOT_BOT_NAME must be defined'}"            # what hubot listens to
export HUBOT_SLACK_TOKEN="${HUBOT_SLACK_TOKEN?:'Envorinment variable HUBOT_SLACK_TOKEN must be defined'}"   # Credentials

export HUBOT_HOME="${HUBOT_HOME:-/usr/local/hubot}"
export EXTERNAL_SCRIPTS="${HUBOT_HOME}/external-scripts.json"
export PATH="${HUBOT_HOME}/node_modules/.bin:${HUBOT_HOME}/node_modules/hubot/node_modules/.bin:${PATH}"


cd /etc/supervisor.d/

#if [ "$1" = 'hubot_debug' ]; then     # debugging line: allows access from chrome

    #start our app with debug  (check docker log for CHROME browser access)
#    [ ! -e hubot.ini ] || rm hubot.ini
#    [ -e inspector.ini ] || cp inspector.debug inspector.ini
#
#else

    #start our app
    [ ! -e inspector.ini ] || rm inspector.ini
    [ -e hubot.ini ] || cp hubot.regular hubot.ini

#fi

cd "${HUBOT_HOME}"
