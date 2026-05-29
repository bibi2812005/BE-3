FROM maven:3.9-eclipse-temurin-26 AS build

WORKDIR /workspace

COPY ash-project-be/pom.xml ash-project-be/pom.xml
COPY ash-project-be/src ash-project-be/src

RUN mvn -f ash-project-be/pom.xml -DskipTests package

FROM eclipse-temurin:26-jre

WORKDIR /app

COPY --from=build /workspace/ash-project-be/target/*SNAPSHOT.jar /app/app.jar

EXPOSE 10000

CMD ["sh", "-c", "java -Dserver.port=${PORT:-10000} -jar /app/app.jar"]
