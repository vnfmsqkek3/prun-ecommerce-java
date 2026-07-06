FROM public.ecr.aws/amazoncorretto/amazoncorretto:17
RUN yum install -y shadow-utils curl && yum clean all && \
    groupadd -r appgroup && useradd -r -g appgroup appuser
WORKDIR /app
COPY build/libs/*.jar app.jar
RUN chown appuser:appgroup app.jar
USER appuser

ENV SPRING_PROFILES_ACTIVE=prod
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
