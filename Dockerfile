ARG FROM_BASE=base_container:20180210
FROM $FROM_BASE

# version of this docker image
ARG CONTAINER_VERSION=1.0.0 
LABEL version=$CONTAINER_VERSION   

ARG HUBOT_USER=hubot
ENV HUBOT_HOME=/usr/local/hubot

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && chmod u+rwx /tmp/container/build.sh \
    && /tmp/container/build.sh 'HUBOT'
RUN rm -rf /tmp/*


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
CMD ["hubot"]
