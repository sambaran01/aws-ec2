# Use official Nginx image as base
FROM nginx:alpine

# Set maintainer label
LABEL maintainer="AWS Engineering Lab"
LABEL description="Production-grade AWS infrastructure engineering educational platform"

# Remove default Nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy website files to Nginx html directory
COPY aws-lab.html /usr/share/nginx/html/index.html
COPY aws-styles.css /usr/share/nginx/html/
COPY aws-script.js /usr/share/nginx/html/
COPY project-detail.html /usr/share/nginx/html/
COPY project-detail.css /usr/share/nginx/html/
COPY project-detail.js /usr/share/nginx/html/
COPY README.md /usr/share/nginx/html/

# Create custom Nginx configuration
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    \
    # Enable gzip compression \
    gzip on; \
    gzip_vary on; \
    gzip_min_length 1024; \
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json; \
    \
    # Security headers \
    add_header X-Frame-Options "SAMEORIGIN" always; \
    add_header X-Content-Type-Options "nosniff" always; \
    add_header X-XSS-Protection "1; mode=block" always; \
    \
    # Cache static assets \
    location ~* \.(css|js|jpg|jpeg|png|gif|ico|svg|woff|woff2|ttf|eot)$ { \
        expires 1y; \
        add_header Cache-Control "public, immutable"; \
    } \
    \
    # HTML files - no cache \
    location ~* \.html$ { \
        expires -1; \
        add_header Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0"; \
    } \
    \
    # Handle 404 errors \
    error_page 404 /index.html; \
    \
    # Deny access to hidden files \
    location ~ /\. { \
        deny all; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
