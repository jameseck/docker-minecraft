FROM alpine
#FROM jameseckersall/docker-centos-base

MAINTAINER James Eckersall <james.eckersall@gmail.com>

COPY files /
RUN \
  apk add --update bash curl iproute2 openjdk8-jre which wget && \
  rm -rf /var/cache/apk/*

#RUN yum install -y java-1.8.0-openjdk iproute which && \
#    pip uninstall -y supervisor && \
#    rm -rf /init/supervisord /etc/supervisord.d /hooks/supervisord-pre.d /hooks/supervisord-ready && \
#    yum clean all && \
RUN \
    mkdir /data || true && \
    chmod 0777 /data || true && \
    chmod -R 0755 /init/* /hooks/* /usr/local/bin/mccmd
ENV \
  MINECRAFT_VERSION=1.7.10 \
  FORGE_VERSION=10.13.4.1566 \
  FORGE_URL="" \
  FORGE_DOWNLOAD=yes \
  MINECRAFT_MINHEAP=512M \
  MINECRAFT_MAXHEAP=2048M \
  MINECRAFT_MOTD=Minecraft \
  JAVA_OPTS="-server -XX:+UseConcMarkSweepGC nogui" \
  FML_CONFIRM="" \
  MC_HOME=/data

USER 100000
VOLUME $MC_HOME
EXPOSE 25565
ENTRYPOINT ["/bin/bash", "-e", "/init/entrypoint"]
CMD [ "/data/server/start.sh" ]
