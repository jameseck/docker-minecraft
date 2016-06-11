FROM jameseckersall/docker-centos-base

MAINTAINER James Eckersall <james.eckersall@gmail.com>

COPY files /
RUN yum install -y java-1.8.0-openjdk && \
    yum clean all && \
    chmod -R 0755 /init/* /hooks/*
ENV \
  MINECRAFT_VERSION=1.7.10 \
  FORGE_VERSION=10.13.4.1566 \
  FORGE_URL="" \
  MINECRAFT_MINHEAP=512M \
  MINECRAFT_MAXHEAP=2048M \
  MINECRAFT_MOTD=Minecraft \
  JAVA_OPTS="-server -XX:+UseConcMarkSweepGC nogui"

USER 100000
VOLUME /data
EXPOSE 25565
CMD [ "/data/server/start.sh" ]
