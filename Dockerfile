FROM tomcat:jdk11
ADD server.xml /usr/local/tomcat/conf/server.xml
ADD web.xml /usr/local/tomcat/conf/web.xml
ADD login.html/ /usr/local/tomcat/webapps/login.html
CMD ["shutdown.sh"]
CMD ["catalina.sh", "run"]
