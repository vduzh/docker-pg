####### First stage #######
# base image
FROM alpine as base

# install software
RUN apk add git openjdk17

# download sources
# WORKDIR now is /
RUN git clone https://github.com/dmdev2020/spring-starter.git

# change WORKDIR
WORKDIR spring-starter

# checkout and build the app
RUN git checkout lesson-125 && ./gradlew bootJar

####### Second stage #######
FROM alpine as result

# install software
RUN apk add openjdk17

WORKDIR /app

COPY --from=base /spring-starter/build/libs/spring-starter-*.jar ./service.jar
COPY application-dev.yaml .

EXPOSE 8080

# specify executable
ENTRYPOINT ["java", "-jar", "service.jar"]
# set additional params
CMD ["--spring.config.location=classpath:/application.yml,file:application-dev.yaml"]

