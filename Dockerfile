FROM docker.1ms.run/library/python:2.7.18-alpine as build
# FROM docker.1ms.run/maven:3.8.8-eclipse-temurin-8-alpine as build

LABEL maintainer=ttchengwang@foxmail.com

# DKCONFIG sed_mirror alpine
# DKCONFIG multi_config dk_config_all
# 国内软件源
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN apk add openjdk8
RUN apk add maven
RUN apk add git
#RUN apk add python2
#RUN apk add nginx

# pyhon 软件源
ENV PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/
ENV PIP_TRUSTED_HOST=mirrors.aliyun.com
# maven 仓库镜像源
RUN mkdir -p /root/.m2 && echo '<?xml version="1.0" encoding="UTF-8"?>\
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"\
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">\
  <mirrors>\
    <mirror>\
      <id>aliyunmaven</id>\
      <mirrorOf>central</mirrorOf>\
      <url>https://maven.aliyun.com/repository/public</url>\
    </mirror>\
  </mirrors>\
</settings>' > /root/.m2/settings.xml
RUN mvn help:effective-settings

RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk' >> /etc/profile
RUN echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
RUN echo '#jdk8' >> /etc/profile


COPY conf/application.properties  /conf/application.properties
COPY conf/jdbc-mysql.properties  /conf/jdbc-mysql.properties
COPY conf/redis-config.properties  /conf/redis-config.properties
COPY conf/zoo.properties  /conf/zoo.properties

#COPY nginx.conf /etc/nginx/
#RUN rm -rf /etc/nginx/conf.d/default.conf

COPY gitjar.sh /gitjar.sh
RUN chmod 755 /*.sh
RUN /gitjar.sh

FROM docker.1ms.run/library/tomcat:9.0.115-jdk8 as production

RUN sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i 's/<\/Host>/<Context path="" docBase="\/war"\/><\/Host>/' /usr/local/tomcat/conf/server.xml

COPY --from=build --chown=dify:dify /opt/soft/version/disconf/disconf-web/output /war
COPY docker.sh /docker.sh
CMD ["/docker.sh"]