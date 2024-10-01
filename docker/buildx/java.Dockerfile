# docker -c=pod01.dev -t hub.lan/app:j17 -f Dockerfile [OPTIONS] PATH | - | URL
# tar czf ./demo.tar --exclude=crmls-ai/target crmls-ai/
# java 17-lts
FROM docker.io/maven:3.8.5-eclipse-temurin-17 AS builder
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 5001 siri && chown -R siri:siri $uhome
USER siri

RUN printf '\
<?xml version="1.0" encoding="UTF-8"?>\n\
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" \n\
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" \n\
    xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 \n\
    http://maven.apache.org/xsd/settings-1.0.0.xsd">\n\
    <mirrors>\n\
        <mirror>\n\
            <id>mirror</id>\n\
            <mirrorOf>*</mirrorOf>\n\
            <name>mirror</name>\n\
            <url>https://maven.aliyun.com/repository/public</url>\n\
        </mirror>\n\
    </mirrors>\n\
</settings>\n\
' > ~/m2.xml
# config maven run with proxy and settings in m2.xml 
# ARG M2PROXY="-DproxySet=true -Dhttp.proxyHost=v2ray.tinyproxy -Dhttp.proxyPort=8888"
RUN alias m2="mvn $M2PROXY -s ~/m2.xml -f pom.xml"

COPY --chown=siri:siri pom.xml .
RUN m2 dependency:go-offline -q

COPY --chown=siri:siri . .
# mvn clean package -s ~/m2_settings.xml -q -Dmaven.test.skip=true -f pom.xmls
RUN m2 clean package -Dmaven.test.skip=true
RUN ls -lha target && mv $(realpath target/*.jar) target/app.jar && ls -lha target

# ----- runtime
# eclipse-temurin:17-jre-alpine
FROM docker.io/eclipse-temurin:17-jre-focal
ARG uhome=/siri
WORKDIR $uhome/app
RUN useradd -d $uhome -s /bin/sh -u 5001 siri && chown -R siri:siri $uhome
USER siri
COPY --from=builder $uhome/app/target/app.jar .
RUN pwd && ls -lha

# environment
ARG app_profile=dev
ARG app_path=/api-crmls
ARG app_port=5000
ENV JAR_OPTIONS="-Dserver.port=${app_port} -Dserver.servlet.context-path=${app_path}"
ENV JAR_PROFILE="-Dspring.profiles.active=${app_profile}"
ENV JAVA_OPS="-Xms512m -Xmx512m"

CMD java $JAVA_OPS $JAR_PROFILE $JAR_OPTIONS -jar app.jar
# CMD ["java", "-jar", "app.jar"]
# for java 17 jre 
# java -Dspring.profiles.active=dev -Dserver.servlet.context-path=/api-crmls -Dserver.port=5000 -jar app.jar
# for java 8
# sh -c "java -jar app.jar --spring.profiles.active=dev --server.port=5000 --server.servlet.context-path=/api"