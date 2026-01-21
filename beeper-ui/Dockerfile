# ============================================================================
# DevOps Incident Board - Frontend Dockerfile
# Nginx-based static file server
# OpenShift-compatible (non-root container)
# ============================================================================

# -----------------------------------------------------------------------------
# Stage 1: Build/Prepare Stage
# Copy and prepare static files
# -----------------------------------------------------------------------------
FROM nginx:1.25-alpine AS builder

# Copy static files
WORKDIR /app
COPY index.html .
COPY incident-board.css .

# -----------------------------------------------------------------------------
# Stage 2: Runtime Stage
# Nginx configured for OpenShift (non-root)
# -----------------------------------------------------------------------------
FROM nginx:1.25-alpine

# Labels for OpenShift and container registry
LABEL maintainer="Yosser Fhal <fhalyosser@tbs.u-tunis.tn>" \
      app.name="incident-frontend" \
      app.version="1.0.0" \
      app.description="DevOps Incident Board Frontend UI" \
      io.openshift.tags="nginx,frontend,incident-management" \
      io.k8s.description="Nginx-based frontend for incident management dashboard" \
      io.openshift.expose-services="8080:http"

# Install envsubst for runtime configuration
RUN apk add --no-cache gettext

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static files
COPY --from=builder /app/index.html /usr/share/nginx/html/
COPY --from=builder /app/incident-board.css /usr/share/nginx/html/

# Create config.js template for runtime API URL injection
RUN echo 'window.API_BASE_URL = "${API_BASE_URL}";' > /usr/share/nginx/html/config.js.template

# Create startup script for runtime configuration
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo 'envsubst < /usr/share/nginx/html/config.js.template > /usr/share/nginx/html/config.js' >> /docker-entrypoint.sh && \
    echo 'exec nginx -g "daemon off;"' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# OpenShift runs containers with arbitrary UIDs belonging to root group (GID 0)
# All directories must be writable by group 0

# Create all required directories
RUN mkdir -p /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp \
             /var/log/nginx \
             /var/run

# Set ownership to root group for OpenShift arbitrary UID support
RUN chgrp -R 0 /usr/share/nginx/html && \
    chgrp -R 0 /var/cache/nginx && \
    chgrp -R 0 /var/log/nginx && \
    chgrp -R 0 /var/run && \
    chgrp -R 0 /docker-entrypoint.sh && \
    chmod -R g=u /usr/share/nginx/html && \
    chmod -R g=u /var/cache/nginx && \
    chmod -R g=u /var/log/nginx && \
    chmod -R g=u /var/run && \
    chmod g=u /docker-entrypoint.sh

# Create and set permissions for nginx.pid
RUN touch /var/run/nginx.pid && \
    chgrp 0 /var/run/nginx.pid && \
    chmod g=u /var/run/nginx.pid

# Switch to non-root user (OpenShift will override with arbitrary UID)
USER 1001

# Expose port 8080 (non-privileged port for OpenShift)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Environment variable for API URL (will be replaced at runtime)
ENV API_BASE_URL="http://incident-backend:8080/api"

# Start nginx with runtime configuration
ENTRYPOINT ["/docker-entrypoint.sh"]
