#!/bin/sh
set -x
source /etc/profile;java -version

#nginx

sh /usr/local/tomcat/bin/shutdown.sh
sh /usr/local/tomcat/bin/startup.sh
tail -f /docker.sh