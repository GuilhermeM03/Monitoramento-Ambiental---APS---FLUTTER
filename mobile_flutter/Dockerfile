# frontend/Dockerfile

# Etapa 1 — Build do Flutter Web
FROM ubuntu:22.04 AS build
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa ca-certificates --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

ENV FLUTTER_VERSION=3.24.3-stable
RUN curl -L -o /tmp/flutter.tar.xz "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}.tar.xz" \
    && tar -xJf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

WORKDIR /app
COPY . .
RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web --release

# Etapa 2 — Servir com nginx
FROM nginx:1.25-alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
