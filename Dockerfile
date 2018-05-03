ARG FROM_BASE=${DOCKER_REGISTRY:-}supervisord:${CONTAINER_TAG:-latest}
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=hubot
ARG CONTAINER_VERSION=${CONTAINER_VERSION:-3.0.0}

LABEL org_name=$CONTAINER_NAME \
      version=$CONTAINER_VERSION 

# Specify CBF version to use with our configuration and customizations
ARG CBF_VERSION="${CBF_VERSION}"
# include our project files
COPY build Dockerfile /tmp/
# set to non zero for the framework to show verbose action scripts
#    (0:default, 1:trace & do not cleanup; 2:continue after errors)
ENV DEBUG_TRACE=0


ARG HUBOT_USER=hubot
ENV HUBOT_HOME=/usr/local/hubot


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME" "$DEBUG_TRACE"
RUN [ $DEBUG_TRACE != 0 ] || rm -rf /tmp/* 


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
