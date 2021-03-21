ARG FROM_BASE=${DOCKER_REGISTRY:-s2.ubuntu.home:5000/}${CONTAINER_OS:-alpine}/supervisord:${BASE_TAG:-latest}
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=hubot
# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION

# include our project files
COPY build Dockerfile /tmp/

# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0


ARG HUBOT_USER=hubot
ARG HUBOT_HOME=/usr/local/hubot


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$DEBUG_TRACE" "$TZ" \
    && ([ "$DEBUG_TRACE" != 0 ] || rm -rf /tmp/*) 


# hubot app port: Exposing node-inspector
#EXPOSE 8123
#EXPOSE 5858
#EXPOSE 8080

# Expose volumes for long term data storage
#VOLUME /var/lib/redis
#VOLUME $HUBOT_HOME/scripts
#VOLUME $HUBOT_HOME/config


#USER $HUBOT_USER
WORKDIR $HUBOT_HOME

ENTRYPOINT [ "docker-entrypoint.sh" ]
#CMD ["$CONTAINER_NAME"]
CMD ["hubot"]
