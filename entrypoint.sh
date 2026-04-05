#!/bin/sh
set -e

ARGS=""

# Las variables TELEGRAM_API_ID y TELEGRAM_API_HASH son obligatorias
if [ -z "$TELEGRAM_API_ID" ] || [ -z "$TELEGRAM_API_HASH" ]; then
    echo "Error: Las variables de entorno TELEGRAM_API_ID y TELEGRAM_API_HASH son obligatorias."
    exit 1
fi

# Concatenación estándar POSIX
ARGS="${ARGS} --api-id=${TELEGRAM_API_ID}"
ARGS="${ARGS} --api-hash=${TELEGRAM_API_HASH}"

# Variables de entorno opcionales
if [ -n "$TELEGRAM_HTTP_PORT" ]; then
    ARGS="${ARGS} --http-port=${TELEGRAM_HTTP_PORT}"
fi

if [ -n "$TELEGRAM_HTTP_STAT_PORT" ]; then
    ARGS="${ARGS} --http-stat-port=${TELEGRAM_HTTP_STAT_PORT}"
fi

if [ -n "$TELEGRAM_DIR" ]; then
    mkdir -p "$TELEGRAM_DIR"
    chown -R tgbot:tgbot "$TELEGRAM_DIR"
    ARGS="${ARGS} --dir=${TELEGRAM_DIR}"
fi

if [ -n "$TELEGRAM_TEMP_DIR" ]; then
    mkdir -p "$TELEGRAM_TEMP_DIR"
    chown -R tgbot:tgbot "$TELEGRAM_TEMP_DIR"
    ARGS="${ARGS} --temp-dir=${TELEGRAM_TEMP_DIR}"
fi

if [ -n "$TELEGRAM_LOG_FILE" ]; then
    LOG_DIR=$(dirname "$TELEGRAM_LOG_FILE")
    mkdir -p "$LOG_DIR"
    chown -R tgbot:tgbot "$LOG_DIR"
    ARGS="${ARGS} --log=${TELEGRAM_LOG_FILE}"
fi

if [ -n "$TELEGRAM_LOCAL" ] && [ "$TELEGRAM_LOCAL" = "true" ]; then
    ARGS="${ARGS} --local"
fi

if [ -n "$TELEGRAM_MAX_CONNECTIONS" ]; then
    ARGS="${ARGS} --max-connections=${TELEGRAM_MAX_CONNECTIONS}"
fi

if [ -n "$TELEGRAM_VERBOSITY" ]; then
    ARGS="${ARGS} --verbosity=${TELEGRAM_VERBOSITY}"
fi

if [ -n "$TELEGRAM_MAX_WEBHOOK_CONNECTIONS" ]; then
    ARGS="${ARGS} --max-webhook-connections=${TELEGRAM_MAX_WEBHOOK_CONNECTIONS}"
fi

if [ -n "$TELEGRAM_FILTER" ]; then
    ARGS="${ARGS} --filter=${TELEGRAM_FILTER}"
fi

if [ -n "$TELEGRAM_LOG_MAX_FILE" ]; then
    ARGS="${ARGS} --log-max-file-size=${TELEGRAM_LOG_MAX_FILE}"
fi

# Mensaje de inicio
VERSION=$(/usr/local/bin/telegram-bot-api --version | head -n 1)
echo "Starting telegram-bot-api ($VERSION) with args: $ARGS"

# Ejecuta la API con los argumentos construidos
exec su-exec tgbot /usr/local/bin/telegram-bot-api $ARGS
