FROM docker.io/selenium/standalone-chrome:123.0

user root
arg JRE_VERSION=8
RUN apt-get -qqy update -y 
RUN apt-get -qqy --no-install-recommends install temurin-${JRE_VERSION}-jre -y
RUN update-java-alternatives --set /usr/lib/jvm/temurin-8-jre-amd64
RUN rm -rf /var/lib/apt/lists/*

USER ${SEL_UID}
#ENV JAVA_OPS="-Xms256m -Xmx256m"
CMD tail -f /dev/null

# docker build --force-rm -t softlang/java:jre8-chrome123.0 -f chrome.Dockerfile .

