ARG FROM_BASE=base_container:20180314
FROM $FROM_BASE

# name and version of this docker image
ARG CONTAINER_NAME=hubot
ARG CONTAINER_VERSION=1.0.0

LABEL org_name=$CONTAINER_NAME \
      version=$CONTAINER_VERSION 

# set to non zero for the framework to show verbose action scripts
ARG DEBUG_TRACE=0

# Add CBF, configuration and customizations
ARG CBF_VERSION=${CBF_VERSION:-v2.0}
ADD "https://github.com/ballab1/container_build_framework/archive/${CBF_VERSION}.tar.gz" /tmp/
COPY build /tmp/


ARG HUBOT_USER=hubot
ENV HUBOT_HOME=/usr/local/hubot


# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/build.sh \
    && /tmp/build.sh "$CONTAINER_NAME"
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
