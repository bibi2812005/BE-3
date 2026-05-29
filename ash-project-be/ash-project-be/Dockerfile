FROM maven:3.9-eclipse-temurin-26 AS build

WORKDIR /workspace

COPY pom.xml pom.xml
COPY src src

RUN mvn -DskipTests package

FROM eclipse-temurin:26-jre

WORKDIR /app

COPY --from=build /workspace/target/*SNAPSHOT.jar /app/app.jar

EXPOSE 10000

CMD ["sh", "-c", "java -Dserver.port=${PORT:-10000} -jar /app/app.jar"]
