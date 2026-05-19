#!/bin/bash
set -e

# Seed every directory hermes expects under /data/.hermes.
# Without this, hermes dashboard endpoints (logs/, sessions/, cron/) can fail
# with opaque errors on first boot when the volume is empty.
mkdir -p /data/.hermes/cron /data/.hermes/sessions /data/.hermes/logs \
         /data/.hermes/memories /data/.hermes/skills /data/.hermes/pairing \
         /data/.hermes/hooks /data/.hermes/image_cache /data/.hermes/audio_cache \
         /data/.hermes/workspace /data/.hermes/skins /data/.hermes/plans \
         /data/.hermes/home

if [ ! -f /data/.hermes/config.yaml ] && [ -f /opt/hermes-agent/cli-config.yaml.example ]; then
    cp /opt/hermes-agent/cli-config.yaml.example /data/.hermes/config.yaml
fi

[ ! -f /data/.hermes/.env ] && touch /data/.hermes/.env

# Bootstrap OAuth tokens from env var (e.g. xAI Grok SuperGrok).
# Set HERMES_AUTH_JSON_BOOTSTRAP to the contents of a locally-generated
# ~/.hermes/auth.json. Written only once — refreshes update the file in place.
if [ ! -f /data/.hermes/auth.json ] && [ -n "${HERMES_AUTH_JSON_BOOTSTRAP}" ]; then
    printf '%s' "${HERMES_AUTH_JSON_BOOTSTRAP}" > /data/.hermes/auth.json
    chmod 600 /data/.hermes/auth.json
fi

# Remove stale PID file from the previous container. The /data volume persists
# across Railway redeploys; without this, hermes gateway exits immediately with
# "PID file race lost to another gateway instance".
rm -f /data/.hermes/gateway.pid

exec python /app/server.py
