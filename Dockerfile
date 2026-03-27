FROM maven:4.0.0-rc-5-eclipse-temurin-25 AS builder

WORKDIR /app

COPY pom.xml .

# Cache warstw
RUN mvn dependency:go-offline

COPY src src

RUN mvn package -DskipTests

FROM eclipse-temurin:25-jre-alpine
WORKDIR /app

RUN apk add --no-cache curl

RUN addgroup -S springgroup && adduser -S springuser -G springgroup
USER springuser:springgroup

COPY --from=builder /app/target/*.jar app.jar

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]