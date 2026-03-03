# 在docker中运行Diconf
## 前言
Diconf是一个比较老的配置中心，代码差不多有十年没有更新了，为了方便维护公司的老项目，尽可能减少安全漏洞，因此创建了这个项目。本文提供了两种模式，一种是docker compose方式，包含全部的组件，每个组件一个容器，方便快速搭建测试环境。另外一种是前后端在一起的单镜像。

## Compose快速运行（建议测试）

```shell
# 打包
docker compose build
# 启动
docker cmopose up -d
# 销毁
docker compose down
```

Note: 如果要正式部署，建议修改默认密码，挂载数据卷以保留数据，

## 前后端合一的单镜像（建议生产）

中间件全部单独部署，然后编译镜像部署到docker或者k8s中，对应配置文件需要单独挂载

```shell
# 打包
docker build --extra-host "backend:127.0.0.1" -t ttcheng/disconf:2.6.36 .
# 部署
docker run -d --name disconf \
  --add-host "backend:127.0.0.1" \
  -p 8081:8081 \
  -e TZ=Asia/Shanghai \
  -v /opt/disconf/tomcat-logs:/usr/local/tomcat/logs \
  -v /opt/disconf/conf/nginx.conf:/etc/nginx/nginx.conf  \
  -v /opt/disconf/conf/application.properties:/usr/local/tomcat/webapps/ROOT/application.properties \
  -v /opt/disconf/conf/jdbc-mysql.properties:/usr/local/tomcat/webapps/ROOT/jdbc-mysql.properties \
  -v /opt/disconf/conf/redis-config.properties:/usr/local/tomcat/webapps/ROOT/redis-config.properties \
  -v /opt/disconf/conf/zoo.properties:/usr/local/tomcat/webapps/ROOT/zoo.properties \
  ttcheng/disconf:2.6.36
```

