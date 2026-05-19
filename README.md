# Hermes Agent — Railway Template (Auto-Update)

Deploy [Hermes Agent](https://github.com/NousResearch/hermes-agent) on [Railway](https://railway.app/) with automatic version tracking. A GitHub Actions workflow runs daily, detects new upstream releases, and pushes a version bump — Railway auto-deploys the update.

## How Auto-Update Works

1. GitHub Actions runs daily at 06:00 UTC (`.github/workflows/auto-update.yml`)
2. Queries the GitHub API for the latest `NousResearch/hermes-agent` release tag
3. If the tag differs from the pinned `HERMES_REF` in `Dockerfile`, it commits the bump
4. Railway detects the push and triggers a new build

Trigger manually anytime: **Actions → Auto-Update Hermes Release → Run workflow**

## Deploy to Railway

1. Fork this repo (or create a new GitHub repo from these files)
2. Go to [railway.app](https://railway.app/) → New Project → Deploy from GitHub repo
3. Select your repo — Railway auto-detects `railway.toml` and uses the Dockerfile builder
4. Add a **volume** mounted at `/data` (persists config and sessions across redeploys)
5. Set the `ADMIN_PASSWORD` environment variable (or one is auto-generated and printed to logs)
6. Click Deploy → open your Railway URL → log in with `admin` / your password

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `PORT` | `8080` | Set automatically by Railway |
| `ADMIN_USERNAME` | `admin` | Dashboard login username |
| `ADMIN_PASSWORD` | _(auto-generated)_ | Dashboard login password — set this |

All other config (LLM provider, model, Telegram/Discord token, tool API keys) is managed through the admin dashboard at `/setup`.

## Quick Start

1. Get an [OpenRouter](https://openrouter.ai/) API key (free tier available)
2. Create a Telegram bot via [@BotFather](https://t.me/BotFather) and copy the Bot Token
3. Deploy to Railway (steps above)
4. Open the dashboard → configure LLM provider + messaging channel → Save & Start
5. Message your bot → approve the pairing request in the dashboard under Users

## Local Development

```bash
docker build -t hermes-local .
docker run --rm -it -p 8080:8080 -e ADMIN_PASSWORD=test -v hermes-data:/data hermes-local
```

Open http://localhost:8080 and log in with `admin` / `test`.

## Architecture

```
Railway Container
├── Python Admin Server (Starlette + Uvicorn)
│   ├── /setup       — Setup wizard / admin UI (cookie auth)
│   ├── /login       — Login page
│   ├── /health      — Healthcheck (no auth)
│   └── /setup/api/* — Config, status, logs, gateway control, pairing
└── hermes gateway   — Managed as async subprocess
```

Config lives at `/data/.hermes/.env` and `/data/.hermes/config.yaml` on the persistent volume.

## Supported Providers

OpenRouter, DeepSeek, DashScope, GLM / Z.AI, Kimi, MiniMax, HuggingFace, OpenAI, Anthropic

## Supported Channels

Telegram, Discord, Slack, WhatsApp, Email, Mattermost, Matrix

## Supported Tool Integrations

Parallel (search), Firecrawl (scraping), Tavily (search), FAL (image gen), Browserbase, GitHub, OpenAI Voice (Whisper/TTS), Honcho (memory)

## Credits

- [Hermes Agent](https://github.com/NousResearch/hermes-agent) by [Nous Research](https://nousresearch.com/)
- Template based on [praveen-ks-2001/hermes-agent-template](https://github.com/praveen-ks-2001/hermes-agent-template)
