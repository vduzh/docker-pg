# stage 0
FROM alpine:latest AS tomcat

# use default work dir: /
#WORKDIR /app/build

RUN cd .. \
    && wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.41/bin/apache-tomcat-10.1.41.tar.gz \
    && tar -xvzf apache-tomcat-10.1.41.tar.gz \
    && rm apache-tomcat-10.1.41.tar.gz

# stage 1
FROM alpine:latest

RUN apk add openjdk17

WORKDIR /app/build
#COPY --from=tomcat /app/apache-tomcat-10.1.41 /app/apache-tomcat-10.1.41
COPY --from=tomcat /apache-tomcat-10.1.41 /app/apache-tomcat-10.1.41

EXPOSE 8080

ENTRYPOINT ["/app/apache-tomcat-10.1.41/bin/catalina.sh"]
CMD ["run"] 

