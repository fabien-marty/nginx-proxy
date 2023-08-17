FROM nginxproxy/docker-gen:0.10.6-debian AS docker-gen

FROM nginxproxy/forego:0.17.2-debian AS forego

# Build the final image
FROM openresty/openresty:1.21.4.1-0-jammy

ARG NGINX_PROXY_VERSION
# Add DOCKER_GEN_VERSION environment variable because 
# acme-companion rely on it (but the actual value is not important)
ARG DOCKER_GEN_VERSION="unknown"
ENV NGINX_PROXY_VERSION=${NGINX_PROXY_VERSION} \
   DOCKER_GEN_VERSION=${DOCKER_GEN_VERSION} \
   DOCKER_HOST=unix:///tmp/docker.sock

# Install/update certificates
RUN apt-get update \
   && apt-get install -y -q --no-install-recommends ca-certificates \
   && apt-get clean \
   && rm -r /var/lib/apt/lists/*

# Configure Nginx
RUN echo "daemon off;" >> /etc/nginx/nginx.conf \
   && sed -i 's/worker_processes  1/worker_processes  auto/' /etc/nginx/nginx.conf \
   && sed -i 's/worker_connections  1024/worker_connections  10240/' /etc/nginx/nginx.conf \
   && mkdir -p '/etc/nginx/dhparam' \
   && mkdir -p '/etc/nginx/dhparam' \
   && mkdir -p '/var/log/nginx'

# Install Forego + docker-gen
COPY --from=forego /usr/local/bin/forego /usr/local/bin/forego
COPY --from=docker-gen /usr/local/bin/docker-gen /usr/local/bin/docker-gen

COPY network_internal.conf /etc/nginx/

COPY app nginx.tmpl LICENSE /app/
WORKDIR /app/

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["forego", "start", "-r"]
