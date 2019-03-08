# hearstat/hubot-slack
Hubot running on [Alpine](https://hub.docker.com/_/alpine/) with the [Slack Adapter](https://github.com/slackhq/hubot-slack).

# Build Info
## NODE
- NodeJS: 4.12
- NPM: 2.24.9

## Default Scripts
- [hubot-slack](https://github.com/slackhq/hubot-slack)
- [hubot-diagnostics](https://github.com/hubot-scripts/hubot-diagnostics)
- [hubot-help](https://github.com/hubot-scripts/hubot-help)
- [hubot-maps](https://github.com/nhoag/hubot-maps)
- [hubot-redis-brain](https://github.com/github/hubot-scripts/blob/master/src/scripts/redis-brain.coffee)
- [hubot-rules](https://github.com/hubot-scripts/hubot-rules)
- [hubot-shipit](https://github.com/github/hubot-scripts/blob/master/src/scripts/shipit.coffee)
- [hubot-plusplus](https://github.com/hubot-scripts/hubot-plusplus)
- [hubot-reload-scripts](https://github.com/vinta/hubot-reload-scripts)

## Installed Packages
- bash
- supervisor
- nodejs
- redis
- build-base
- gc
- g++
- gcc-objc
- libtool
- libc6-compat
- make
- expat
- expat-dev
- python
- wget
- gnupg
- tar
- git
- zip
- curl
- wget

## Suggested Mounts
Mount the redis directory to avoid data reset on container replacement
- /var/lib/redis

Mount the config directory to manage credentials/settings outside of container
- /opt/hubot/config

Mount the scripts directory to manage any non-npm installs/simple scripts
- /opt/hubot/scripts

Mount the external-scripts for control
- /opt/hubot/external-scripts.json

# Usage
You have a few options in how to utilize this container

## Basic Start

```
docker run -v -e HUBOT_SLACK_TOKEN=TOKEN \
  -d hearstat/hubot-slack
```

## Configuration File Start

```
docker run -v /path/to/hubot.conf:/opt/hubot/config/hubot.conf \
  -d hearstat/hubot-slack
```

## Full Feature Start

```
docker run -v /path/to/hubot.conf:/opt/hubot/config/hubot.conf \
  -v /path/to/redis/save:/var/lib/redis \
  -v /path/to/external-scripts.json:/opt/hubot/external-scripts.json \
  -d hearstat/hubot-slack
```
## Dev Mode Start
I've setup this bot to be able to switch back and forth from Slack to Shell via startup commands. This is how to get into "Dev Mode" or enable the shell adapter.
```
docker run -d hearstat/hubot-slack /usr/bin/devmode
```
then just do the following to connect to the container at the shell level
```
docker exec -it $container_name bash
```
then once in run the following
```
./bin/hubot
```
Then you can interact with hubot at the shell level

## Node-Inspector

Run:

```
docker run -d -p 8123:8123 -p 5858:5858 \
  --name=devbot hearstat/hubot-slack devmode
docker exec -it devbot bash
coffee --nodejs --debug $(which hubot)
```

In Chrome navigatate to http://<docker IP>:8123/?ws=<docker IP>:8123&port=5858
For Mac users "docker IP" can be found in Kitematic.
Example: http://192.168.99.100:8123/?ws=192.168.99.100:8123&port=5858

NOTE: You should end up in a hubot REPL, if you end up in a coffee REPL you did something wrong.  To exit:

```
coffee> process.exit()
```

NOTE: node-inspector currently only works in Chrome.

To set a breakpoint in coffeescript you will want to open the code in the /opt/hubot/node_modules/ directory and add at the appropriate line:

```
debugger
```

You may want to mount a directory locally so you can use your local editor.  For Mac this will need to be in your /Users/<username> dir  To do this consider:

```
mkdir -p ~/node_modules
docker run -d -p 8123:8123 -p 5858:5858 \
  -v /Users/<username>/node_modules:/opt/hubot/node_modules \
  -v /Users/ablythe/hubot/config:/opt/hubot/config \
  --name=devbot hearstat/hubot-slack devmode
docker exec -it devbot bash
# needed the first time to populate the mounted volume
python script-install-dev.py
# needed each time configuration changes
source ./config/hubot.conf
coffee --nodejs --debug $(which hubot)
```

## Prod Mode Start
To switch back to slack or "Prod Mode" do the following

```
docker exec $container_name /usr/bin/prodmode
```

or just run a new container

# Run Time Help
Since this container comes with a bot reload option, edit the external-scripts.json as needed and run the following

```
docker exec $container_name python script-install.py
```

Note: you can just restart the container, it will re-run the same script before loading the bot.

Then in chat tell hubot to reload (my default is thebot)

```
@hubot reload
```

# Building
To build the image, do the following

```
docker build github.com/hearstat/docker-hubot-slack
```

A prebuilt container is available in the docker index.

```
docker pull hearstat/hubot-slack
```

# Template files
## Hubot.Conf
Lives at /opt/hubot/config and is sourced at run time.

Add all environment variables needed to conf file. See script repos for specific settings available.

The baseline config file in container only has ADAPTER/HUBOT_NAME set.

```
## Bot Settings
export HUBOT_NAME='hubot' # what hubot listens to

## Slack adapter settings

# Credentials
export HUBOT_SLACK_TOKEN=''

```

## external-scripts.json
The embedded script-install.py utilizes the external-scripts.json for it's install items, I did this to simplify the process. You already have to add everything to the file regardless, so use it to install from.

```
[
  "hubot-diagnostics",
  "hubot-help",
  "hubot-maps",
  "hubot-redis-brain",
  "hubot-rules",
  "hubot-shipit",
  "hubot-plusplus",
  "hubot-reload-scripts"
]
```
