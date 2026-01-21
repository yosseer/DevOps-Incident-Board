# ============================================================================
# DevOps Incident Board - Backend Dockerfile
# Multi-stage build for Spring Boot with Maven + JDK 21
# OpenShift-compatible (non-root container)
# ============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build Stage
# Uses Maven to compile and package the Spring Boot application
# -----------------------------------------------------------------------------
FROM maven:3.9.6-eclipse-temurin-21 AS builder

# Set working directory
WORKDIR /app

# Copy Maven configuration files first (for better layer caching)
COPY pom.xml .

# Download dependencies (cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application (skip tests for faster builds)
RUN mvn clean package -DskipTests -B

# -----------------------------------------------------------------------------
# Stage 2: Runtime Stage
# Minimal JRE image for running the application
# -----------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine

# Labels for OpenShift and container registry
LABEL maintainer="Yosser Fhal <fhalyosser@tbs.u-tunis.tn>" \
      app.name="incident-backend" \
      app.version="1.0.0" \
      app.description="DevOps Incident Board Backend API" \
      io.openshift.tags="java,spring-boot,incident-management" \
      io.k8s.description="Spring Boot REST API for incident management" \
      io.openshift.expose-services="8080:http"

# Create non-root user for OpenShift security compliance
# OpenShift runs containers with arbitrary UIDs, so we use a high UID
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set working directory
WORKDIR /app

# Create data directory for H2 database persistence
RUN mkdir -p /app/data && \
    chown -R appuser:appgroup /app

# Copy the built JAR from builder stage
COPY --from=builder --chown=appuser:appgroup /app/target/*.jar app.jar

# Switch to non-root user
USER 1001

# Expose the application port
EXPOSE 8080

# Health check for container orchestration
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Environment variables for configuration
ENV JAVA_OPTS="-Xms256m -Xmx512m -XX:+UseG1GC -XX:+UseContainerSupport" \
    SPRING_PROFILES_ACTIVE="openshift" \
    SERVER_PORT="8080"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
