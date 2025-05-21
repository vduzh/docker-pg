ARG alpine_version=latest
# layer 1
FROM alpine:${alpine_version}
ARG foo=bar

# layer 2
# move here to cache it
RUN apk add openjdk17

# layer 3
WORKDIR /app/build

# layer 4
# move here to cache it
RUN cd .. \
    && wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.41/bin/apache-tomcat-10.1.41.tar.gz \
    && tar -xvzf apache-tomcat-10.1.41.tar.gz \
    && rm apache-tomcat-10.1.41.tar.gz

# layer 5
COPY test-dir all-files
# layer 6
COPY test-dir/*.xml xml-files/

# layer 7
RUN touch hello.txt && echo "Hello!" >> hello.txt
# layer 8
RUN touch bye.txt \
    && echo "Good Bye!" >> bye.txt

ENV foo=Foo

EXPOSE 8080

ENTRYPOINT ["/app/apache-tomcat-10.1.41/bin/catalina.sh"]
CMD ["run"] 

