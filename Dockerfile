FROM alpine:3.6

ARG TZ="America/New_York"
ARG HUBOT_USER=hubot

ENV VERSION=1.0.0 \
    TZ="America/New_York" \
    HUBOT_HOME=/usr/local/hubot
LABEL version=$VERSION

# Add configuration and customizations
COPY build /tmp/

# build content
RUN set -o verbose \
    && apk update \
    && apk add --no-cache bash \
    && chmod u+rwx /tmp/build_container.sh \
    && /tmp/build_container.sh \
    && rm -rf /tmp/*


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
