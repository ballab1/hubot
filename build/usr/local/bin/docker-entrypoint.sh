#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose
#env


#########################################################################################################
function verifyEnvironment()
{
    ## Slack adapter settings
    export HUBOT_BOT_NAME="${HUBOT_BOT_NAME:?'Envorinment variable HUBOT_BOT_NAME must be defined'}"            # what hubot listens to
    export HUBOT_SLACK_TOKEN="${HUBOT_SLACK_TOKEN?:'Envorinment variable HUBOT_SLACK_TOKEN must be defined'}"   # Credentials

    export HUBOT_HOME="${HUBOT_HOME:-/usr/local/hubot}"
    export PATH="${HUBOT_HOME}/node_modules/.bin:${HUBOT_HOME}/node_modules/hubot/node_modules/.bin:${PATH}"
}

#########################################################################################################
function loadUserScripts()
{
    declare -a hubot_scripts="hubot-diagnostics hubot-help hubot-redis-brain hubot-rules hubot-shipit hubot-reload-scripts"

    # Utilize external-scripts.json to control which scripts are installed.
    export EXTERNAL_SCRIPTS="${HUBOT_HOME}/external-scripts.json"
    [[ -e /opt/hubot/external-scripts.json ]] && cp /opt/hubot/external-scripts.json "$EXTERNAL_SCRIPTS"
    hubot_scripts=$(awk -F'"' '{ if (NF > 3) {print $2 "@" $4} else if (NF == 3) {print $2} }' "$EXTERNAL_SCRIPTS")
    
    # load extended scripts 
    for script in ${hubot_scripts}; do
        npm install $script --save
    done
    npm install  # Install any dependencies missed by the hubot generate
}


#########################################################################################################
#
#   MAIN
#
#########################################################################################################

cd "${HUBOT_HOME}"
if [ "$1" = 'hubot' ]; then       # regular app start

    shift
    verifyEnvironment
    loadUserScripts

    #start our app
#    exec node_modules/.bin/hubot --name "Hubot" "$@"
#    npm start
    ln -s /etc/supervisor.d/supervisord.regular /etc/supervisor.d/supervisord.ini
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=info


elif [ "$1" = 'hubot_debug' ]; then     # debugging line: allows access from chrome

    shift
    verifyEnvironment
    loadUserScripts

    #start our app with debug  (check docker log for CHROME browser access)
#    exec --inspect node_modules/.bin/hubot --name "Hubot" "$@"
#    node --inspect app.js
    ln -s /etc/supervisor.d/supervisord.debug /etc/supervisor.d/supervisord.ini
    exec supervisord --nodaemon --configuration="/etc/supervisord.conf" --loglevel=debug


else
    exec $@
fi
