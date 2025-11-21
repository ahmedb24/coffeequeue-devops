# Use a lightweight JDK image
FROM eclipse-temurin:21-jdk-alpine

# Set working directory
WORKDIR /app

# Copy and build the application
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src

# Build the jar
RUN ./mvnw -q -DskipTests package

# Run the app
CMD ["java", "-jar", "target/coffeequeue-0.0.1-SNAPSHOT.jar"]