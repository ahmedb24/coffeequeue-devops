FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

COPY ./coffeequeue/mvnw .
COPY ./coffeequeue/.mvn .mvn
COPY ./coffeequeue/pom.xml .
COPY ./coffeequeue/src src
COPY application.properties ./src/main/resources/application.properties

RUN chmod +x mvnw
RUN ./mvnw -q -DskipTests package

CMD ["java", "-jar", "target/coffeequeue-0.0.1-SNAPSHOT.jar"]