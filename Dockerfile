FROM adoptopenjdk:11-jdk-hotspot as builder
ADD . /code/
RUN \
    apt-get update && \
    apt-get install build-essential -y && \
    apt-get install dos2unix -y && \
    cd /code/ && \
    dos2unix mvnw && \
    rm -Rf target node_modules && \
    chmod +x /code/mvnw && \
    sleep 1 && \
    JHI_DISABLE_WEBPACK_LOGS=true ./mvnw package -ntp -Pprod -DskipTests && \
    mv /code/target/*.jar /jhipster-registry.jar && \
    apt-get clean && \
    rm -Rf /code/ /root/.m2 /root/.cache /tmp/* /var/lib/apt/lists/* /var/tmp/*

FROM adoptopenjdk:11-jre-hotspot
ENV SPRING_OUTPUT_ANSI_ENABLED=ALWAYS \
    JAVA_OPTS="" \
    JHIPSTER_SLEEP=0 \
    SPRING_PROFILES_ACTIVE=prod
EXPOSE 8761
RUN apt-get install -y curl && \
    apt-get clean && \
    mkdir /target && \
    chmod g+rwx /target
CMD echo "The JHipster Registry will start in ${JHIPSTER_SLEEP}s..." && \
    sleep ${JHIPSTER_SLEEP} && \
    java \
        ${JAVA_OPTS} -Djava.security.egd=file:/dev/./urandom \
        -jar /jhipster-registry.jar

ADD /central-config /central-config
COPY --from=builder /jhipster-registry.jar .
