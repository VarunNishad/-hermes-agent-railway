FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

# Pinned hermes-agent release. Auto-bumped daily by .github/workflows/auto-update.yml
# which queries the GitHub API and commits a new tag when upstream releases one.
# Format: vYYYY.M.D (e.g. v2026.5.16). Use `main` only for bleeding-edge testing.
ARG HERMES_REF=v2026.7.1

# tini: tiny init as PID 1 — reaps zombie grandchildren (MCP stdio servers, git,
# browser daemons) so long-running containers don't exhaust the kernel PID table.
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl ca-certificates git tini && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

# Clone hermes at the pinned ref, install all extras, pre-build the React dashboard
# and TUI bundle so first-chat-open is instant (no npm install at runtime).
RUN git clone --depth 1 --branch ${HERMES_REF} https://github.com/NousResearch/hermes-agent.git /opt/hermes-agent && \
    cd /opt/hermes-agent && \
    uv pip install --system --no-cache -e ".[all,messaging,tts-premium,honcho,bedrock,anthropic,edge-tts,hindsight]" && \
    cd /opt/hermes-agent/web && \
    npm install --silent && \
    npm run build && \
    cd /opt/hermes-agent/ui-tui && \
    npm install --silent --no-fund --no-audit --progress=false && \
    npm run build && \
    rm -rf /opt/hermes-agent/web /opt/hermes-agent/.git /root/.npm

COPY requirements.txt /app/requirements.txt
RUN uv pip install --system --no-cache -r /app/requirements.txt

RUN mkdir -p /data/.hermes

COPY server.py /app/server.py
COPY templates/ /app/templates/
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV HOME=/data
ENV HERMES_HOME=/data/.hermes
# Tells hermes to use the pre-built TUI bundle instead of re-running npm at runtime.
ENV HERMES_TUI_DIR=/opt/hermes-agent/ui-tui

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/app/start.sh"]
