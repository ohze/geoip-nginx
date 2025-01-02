FROM nginx:1.26.2 AS builder

# nginx:alpine contains NGINX_VERSION environment variable, like so:
ENV NGINX_VERSION=1.26.2

# Our NCHAN version
ENV NCOOKIE_VERSION=1.1.1
ENV GEOIP2_VERSION=3.4

RUN apt-get update && \
    apt-get install -y wget \
    gcc \
    g++ \
    libc-dev \
    make \
    libssl-dev \
    libpcre3-dev \
    zlib1g-dev \
    curl \
    gnupg \
    libxslt-dev \
    libgd-dev \
    libgeoip-dev \
    zlib1g-dev \
    libmaxminddb-dev

RUN wget "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" -O nginx.tar.gz && \
  wget "https://github.com/leev/ngx_http_geoip2_module/archive/${GEOIP2_VERSION}.tar.gz" -O geoip2.tar.gz

# Reuse same cli arguments as the nginx:alpine image used to build
RUN mkdir -p /usr/src && \
    CONFARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
	tar -zxC /usr/src -f nginx.tar.gz && \
    tar -xzvf "geoip2.tar.gz" && \
    GEOIPDIR="$(pwd)/ngx_http_geoip2_module-${GEOIP2_VERSION}" && \
    cd /usr/src/nginx-$NGINX_VERSION && \
    ./configure --with-compat $CONFARGS --add-dynamic-module=$GEOIPDIR  && \
    make && make install

FROM nginx:1.26.2-alpine

RUN apk add --no-cache libmaxminddb

COPY --from=builder /usr/local/nginx/modules/ngx_http_geoip2_module.so /usr/local/nginx/modules/ngx_http_geoip2_module.so

COPY --chmod=0755 rootfs /

RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
