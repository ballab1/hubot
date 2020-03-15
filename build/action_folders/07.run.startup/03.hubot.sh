#!/bin/bash

# HUBOT_BOT_NAME:     what hubot listens to
: HUBOT_BOT_NAME="${HUBOT_BOT_NAME:?'Envorinment variable HUBOT_BOT_NAME must be defined'}"

# HUBOT_SLACK_TOKEN:  Credentials
[ ${HUBOT_SLACK_TOKEN:-} ] || lib.file_env 'HUBOT_SLACK_TOKEN'
: HUBOT_SLACK_TOKEN="${HUBOT_SLACK_TOKEN?:'Envorinment variable HUBOT_SLACK_TOKEN must be defined'}"

cd /etc/supervisor.d/

#start our app
[ ! -e inspector.ini ] || rm inspector.ini
[ -e hubot.ini ] || cp hubot.regular hubot.ini

declare iniFile="/etc/supervisor.d/hubot.ini"
sed -i -E -e 's|^environment=.*$|environment=HUBOT_SLACK_TOKEN='"$HUBOT_SLACK_TOKEN"',HUBOT_BOT_NAME='"$HUBOT_BOT_NAME"'|' "$iniFile"


cd "${HUBOT_HOME}"
if ! hubot.hasUIDchanged; then
    [ -f "$(crf.STARTUP)/99.workdir.sh" ] && sed -i -e 's|crf.fixupDirectory|#crf.fixupDirectory|g' "$(crf.STARTUP)/99.workdir.sh"
fi
true
: