# ==========================================
# ETAPA 1: Builder (Compilación)
# ==========================================

FROM alpine:3.19 AS builder

ARG TELEGRAM_BOT_API_VERSION=master

# dependencias de compilación
RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    openssl-dev \
    zlib-dev \
    gperf \
    readline-dev \
    xz-dev \
    boost-dev \
    icu-dev \
    curl-dev \
    libzip-dev \
    json-c-dev \
    linux-headers

WORKDIR /app

# Clonamos el repositorio y compilamos

RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git \
    && cd telegram-bot-api \
    && git checkout ${TELEGRAM_BOT_API_VERSION} \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. \
    && cmake --build . --target install -j$(nproc) \
    && strip /usr/local/bin/telegram-bot-api

# ==========================================
# ETAPA 2: Runtime (Ejecución)
# ==========================================
FROM alpine:3.19


# dependencias de tiempo de ejecución necesarias

RUN apk add --no-cache \
    openssl \
    libstdc++ \
    zlib \
    libgcc \
    su-exec

# Creamos un grupo y usuario de sistema
RUN addgroup -g 1000 tgbot \
    && adduser -u 1000 -G tgbot -s /bin/sh -D tgbot

# Creamos el directorio de datos y asignamos permisos
RUN mkdir -p /data/temp \
    && chown -R tgbot:tgbot /data

COPY --from=builder --chown=tgbot:tgbot /usr/local/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

COPY --chown=tgbot:tgbot entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# directorio de trabajo
WORKDIR /data

# Exponemos el puerto
EXPOSE 8081

# Punto de entrada
ENTRYPOINT ["/entrypoint.sh"]
CMD []
