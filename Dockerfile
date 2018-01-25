FROM ubuntu:latest
ADD ./files/supervisor.sh /
RUN chmod +x /supervisor.sh \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates redis-server imagemagick git\
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs \
    && cd /opt \
    && git clone -b v1.x.x https://github.com/NodeBB/NodeBB.git nodebb \
    && cd nodebb \
    && git checkout -b v1.7.4 v1.7.4 \
    && cp install/package.json package.json \
    && npm install --production \
    && rm -r .[!.]* \
    && mkdir -p /etc/nodebb \
    && /etc/init.d/redis-server start \
    && sleep 5 \
    && redis-cli CONFIG SET save "" \
    && redis-cli CONFIG SET appendonly yes \
    && chmod a+w /etc/redis/redis.conf \
    && redis-cli CONFIG rewrite \
    && chmod a-w /etc/redis/redis.conf \
    && apt-get remove -y curl git \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get purge -y \
    && rm -rf /var/lib/apt/lists/*
ENV NODE_ENV=production
WORKDIR /opt/nodebb
EXPOSE 4567
VOLUME ["/etc/nodebb", "/var/lib/redis", "/opt/nodebb/public/uploads"]
ENTRYPOINT ["/supervisor.sh"]