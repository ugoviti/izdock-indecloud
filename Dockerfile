FROM nikolaik/python-nodejs:python3.8-nodejs12

MAINTAINER Christopher Viola <christopher.viola@initzero.it>

# default versions
ARG APP_VER_MAJOR=20
ARG APP_VER_MINOR=0
ARG APP_VER_PATCH=4
ARG APP_VER=${APP_VER_MAJOR}.${APP_VER_MINOR}.${APP_VER_PATCH}

# default app configuration variables
ENV APP_HOME_DEFAULT      "/opt/inde"
ENV APP_CONF_DEFAULT      "${APP_HOME_DEFAULT}/config"
ENV APP_DATA_DEFAULT      "${APP_HOME_DEFAULT}"

# custom app configuration variables
ENV APP_NAME              "nodejs-inde"
ENV APP_DESCRIPTION       "NodeJS InDe"
ENV APP_HOME              "${APP_HOME_DEFAULT}"
ENV APP_CONF              "${APP_CONF_DEFAULT}"
ENV APP_DATA              "${APP_DATA_DEFAULT}"
ENV APP_USR               "indert"

# node application name
ENV NODE_APP_NAME    ""
# node deploy home
ENV NODE_APP_HOME    ""
# node application server directory
ENV NODE_SERVER_DIR  ""
# node application server configuration
ENV NODE_SERVER_CONF ""
# node application directory
ENV NODE_APP_DIR     ""
# node application data directory
ENV NODE_DATA_DIR    ""
# node application data directory
ENV NODE_LOG_DIR     ""

ENV CONFIG_NAME     "default"
ENV DOMAIN          "example.com"
ENV ALIAS           "app.example.com"
ENV SERVER_TYPE     "default"
ENV SSL_CERT        "${APP_DATA}/ssl/${DOMAIN}.cert"
ENV SSL_KEY         "${APP_DATA}/ssl/${DOMAIN}.key"
ENV SSL_BUNDLE      "${APP_DATA}/ssl/${DOMAIN}_bundle.crt"

# debian specific
ENV DEBIAN_FRONTEND       noninteractive

## install
RUN set -ex && \
    apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
      tini \
      git \
      tar \
      bzip2 \
      zip && \
    # cleanup system
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/* /tmp/*

RUN set -ex && \
    groupadd -g 993 ${APP_USR} && \
    useradd -u 993 -g ${APP_USR} -d ${APP_HOME} -s /bin/bash -m ${APP_USR}

# install inde apps
RUN set -ex && \
  mkdir -p ${APP_DATA} ${APP_CONF} && \
  : "---------- Installing InDe Self ----------" && \
  cd /usr/src && \
  git clone https://github.com/initzero-it/instant-developer-platform && \
  cd instant-developer-platform/public_html && \
  mkdir data appDirectory log && \
  npm install && npm audit fix --force && \
  cd .. && \
  mv public_html ${APP_DATA}/instant-developer-platform && \
  : "---------- Installing InDe Cloud Connector ----------" && \
  cd /usr/src && \
  git clone https://github.com/progamma/cloud-connector.git && \
  cd cloud-connector/public_html && \
  mkdir data appDirectory log && \
  npm install && npm audit fix --force && \
  cd .. && \
  mv public_html ${APP_DATA}/cloud-connector && \
  : "---------- Finalizing Config ----------" && \
  chown -R ${APP_USR}:${APP_USR} ${APP_HOME} && \
  rm -rf /usr/src/* && \
  : "---------- END Installing InDe Apps ----------"

#git clone https://github.com/progamma/instant-developer-platform.git && \
  
# define volumes
VOLUME ["${APP_HOME}","${APP_CONF}"]

EXPOSE 8081/tcp 8082/tcp

# add local files to container
ADD filesystem /

# add local files to container
ADD Dockerfile VERSION README.md /
  
# become unprivileged user
USER ${APP_USR}

WORKDIR "${APP_HOME}"

## CI args
ARG APP_VER_BUILD
ARG APP_BUILD_COMMIT
ARG APP_BUILD_DATE

# define other build variables
ENV APP_VER          "${APP_VER}"
ENV APP_VER_BUILD    "${APP_VER_BUILD}"
ENV APP_BUILD_COMMIT "${APP_BUILD_COMMIT}"
ENV APP_BUILD_DATE   "${APP_BUILD_DATE}"

# start the container process
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "node", "server.js"]
