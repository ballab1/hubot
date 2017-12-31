#!/bin/bash

#set -o xtrace
set -o errexit
set -o nounset 
#set -o verbose

declare -r CONTAINER='HUBOT'

export TZ=America/New_York
declare -r TOOLS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  


# Alpine Packages
declare -r BUILDTIME_PKGS="file gnutls-utils nodejs-dev shadow build-base gcc g++ gcc-objc libtool libc6-compat make expat expat-dev gnupg tar git"
declare -r CORE_PKGS="bash imagemagick nodejs nodejs-npm sudo tzdata"
declare -r NPM_PKGS="coffee-script yo generator-hubot node-inspector"
#declare -r HUBOT_PKGS="bash supervisor redis build-base gcc g++ gcc-objc libtool libc6-compat make expat expat-dev python wget gnupg tar git zip curl wget"
declare -r HUBOT_PKGS="bash supervisor redis python wget zip curl"


declare -r HUBOT_APP=hubot

#  groups/users
declare -r hubot_uid=${hubot_uid:-2223}
declare -r hubot_gid=${hubot_gid:-2223}
declare -r HUBOT_GROUP="${HUBOT_GROUP:-hubot}"
declare -r HUBOT_HOME="${HUBOT_HOME:-/usr/local/hubot}"


# global exceptions
declare -i dying=0
declare -i pipe_error=0


#----------------------------------------------------------------------------
# Exit on any error
function catch_error() {
    echo "ERROR: an unknown error occurred at $BASH_SOURCE:$BASH_LINENO" >&2
}

#----------------------------------------------------------------------------
# Detect when build is aborted
function catch_int() {
    die "${BASH_SOURCE[0]} has been aborted with SIGINT (Ctrl-C)"
}

#----------------------------------------------------------------------------
function catch_pipe() {
    pipe_error+=1
    [[ $pipe_error -eq 1 ]] || return 0
    [[ $dying -eq 0 ]] || return 0
    die "${BASH_SOURCE[0]} has been aborted with SIGPIPE (broken pipe)"
}

#----------------------------------------------------------------------------
function die() {
    local status=$?
    [[ $status -ne 0 ]] || status=255
    dying+=1

    printf "%s\n" "FATAL ERROR" "$@" >&2
    exit $status
}  

#############################################################################
function cleanup()
{
    printf "\nclean up\n"
    apk del .buildDepedencies 
}

#############################################################################
function createUserAndGroup()
{
    local -r user=$1
    local -r uid=$2
    local -r group=$3
    local -r gid=$4
    local -r homedir=$5
    local -r shell=$6
    
    local wanted=$( printf '%s:%s' $group $gid )
    local nameMatch=$( getent group "${group}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    local idMatch=$( getent group "${gid}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    printf "\e[1;34mINFO: group/gid (%s):  is currently (%s)/(%s)\e[0m\n" "$wanted" "$nameMatch" "$idMatch"           

    if [[ $wanted != $nameMatch  ||  $wanted != $idMatch ]]; then
        printf "\ncreate group:  %s\n" "${group}"
        [[ "$nameMatch"  &&  $wanted != $nameMatch ]] && groupdel "$( getent group ${group} | awk -F ':' '{ print $1 }' )"
        [[ "$idMatch"    &&  $wanted != $idMatch ]]   && groupdel "$( getent group ${gid} | awk -F ':' '{ print $1 }' )"
        /usr/sbin/groupadd --gid "${gid}" "${group}"
    fi

    
    wanted=$( printf '%s:%s' $user $uid )
    nameMatch=$( getent passwd "${user}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    idMatch=$( getent passwd "${uid}" | awk -F ':' '{ printf "%s:%s",$1,$3 }' )
    printf "\e[1;34mINFO: user/uid (%s):  is currently (%s)/(%s)\e[0m\n" "$wanted" "$nameMatch" "$idMatch"    
    
    if [[ $wanted != $nameMatch  ||  $wanted != $idMatch ]]; then
        printf "create user: %s\n" "${user}"
        [[ "$nameMatch"  &&  $wanted != $nameMatch ]] && userdel "$( getent passwd ${user} | awk -F ':' '{ print $1 }' )"
        [[ "$idMatch"    &&  $wanted != $idMatch ]]   && userdel "$( getent passwd ${uid} | awk -F ':' '{ print $1 }' )"

        /usr/sbin/useradd --home-dir "$homedir" --uid "${uid}" --gid "${gid}" --no-create-home --shell "${shell}" "${user}"
    fi
}

#############################################################################
function header()
{
    local -r bars='+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
    printf "\n\n\e[1;34m%s\nBuilding container: \e[0m%s\e[1;34m\n%s\e[0m\n" $bars $CONTAINER $bars
}
 
#############################################################################
function install_CUSTOMIZATIONS()
{
    printf "\nAdd configuration and customizations\n"

    declare -a DIRECTORYLIST="/etc /usr /opt /var"
    for dir in ${DIRECTORYLIST}; do
        [[ -d "${TOOLS}/${dir}" ]] && cp -r "${TOOLS}/${dir}/"* "${dir}/"
    done

    ln -s /usr/local/bin/docker-entrypoint.sh /docker-entrypoint.sh
}

#############################################################################
function install_HUBOT_USER()
{
    local -r file="$HUBOT_APP"
    local -r hubot_home=$1
    local -r hubot_user=$2

    printf "\nprepare and install %s specific content for %s\n" "${file}" "$hubot_user"

    cd "${hubot_home}"

    sudo --login --user=$hubot_user npm install coffee-script@1.12.6 hubot-slack --save
    sudo --login --user=$hubot_user yo hubot --owner="Dell EMC" --license="MIT" --name="Hubot" --description="fun stuff" --adapter=slack --defaults
}

#############################################################################
function install_HUBOT_SYSTEM()
{
    local -r app_home=$1

    printf "\nprepare and install NodeJS stuff\n"

    mkdir -p "${app_home}"
    cd "${app_home}"

    npm install --global $NPM_PKGS
}

#############################################################################
function installAlpinePackages()
{
    apk update
    apk add --no-cache $CORE_PKGS $HUBOT_PKGS
    apk add --no-cache --virtual .buildDepedencies $BUILDTIME_PKGS
}

#############################################################################
function installTimezone()
{
    echo "$TZ" > /etc/TZ
    cp /usr/share/zoneinfo/$TZ /etc/timezone
    cp /usr/share/zoneinfo/$TZ /etc/localtime
}

#############################################################################
function setPermissions()
{
    local -r hubot_user=$1
    local -r hubot_group=$2

    printf "\nmake sure that ownership & permissions are correct\n"

    chmod u+rwx /usr/local/bin/docker-entrypoint.sh

    declare -a DIRECTORYLIST="/usr/local/bin /usr/bin /var/log/supervisor /etc/supervisor.d/ $HUBOT_HOME $HUBOT_HOME/scripts $HUBOT_HOME/node_modules $HUBOT_HOME/bin $HUBOT_HOME/.npm"
    for dir in ${DIRECTORYLIST}; do
        mkdir -p ${dir} && chmod -R 777 ${dir}
    done

    declare -a HUBOTLIST="$HUBOT_HOME $HUBOT_HOME/scripts $HUBOT_HOME/node_modules $HUBOT_HOME/bin"
    for botdir in ${HUBOTLIST}; do
        chown -R "$hubot_user":"$hubot_group" ${botdir}
    done
}

#############################################################################

trap catch_error ERR
trap catch_int INT
trap catch_pipe PIPE 

set -o verbose

header
declare -r HUBOT_USER="${HUBOT_USER:?'Envorinment variable HUBOT_USER must be defined'}"
installAlpinePackages
createUserAndGroup "${HUBOT_USER}" "${hubot_uid}" "${HUBOT_GROUP}" "${hubot_gid}" "${HUBOT_HOME}" /bin/bash
installTimezone
install_CUSTOMIZATIONS
install_HUBOT_SYSTEM "${HUBOT_HOME}"
setPermissions "${HUBOT_USER}" "${HUBOT_GROUP}"
install_HUBOT_USER "${HUBOT_HOME}" "${HUBOT_USER}"
cleanup
exit 0
