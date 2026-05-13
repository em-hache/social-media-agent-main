# Docker Project

A monorepo Docker Compose stack with five services:

| Service | Port | Description |
|---|---|---|
| `postgres` | 5432 | PostgreSQL 16 |
| `dynamodb` | 8000 | DynamoDB Local |
| `node-service` | 3001 | Express/Node.js API |
| `fastapi-service` | 8080 | FastAPI Python API |
| `nextjs-app` | 3000 | Next.js 14 frontend |

---

## Quick start (local dev — builds from source)

```bash
# 1. Clone and enter the repo
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>

# 2. Copy and edit env vars
cp .env.example .env

# 3. Start everything (docker-compose.override.yml is loaded automatically)
docker compose up --build
```

Services come up in dependency order. The override file mounts source directories for hot-reload.

---

## Production (pull images from GHCR)

```bash
# 1. Set env vars (especially GITHUB_ORG and image tags)
cp .env.example .env && vim .env

# 2. Pull and start — skips the override file
docker compose -f docker-compose.yml up -d
```

---

## Environment variables

See `.env.example` for the full list. Key variables:

| Variable | Default | Purpose |
|---|---|---|
| `GITHUB_ORG` | `your-org` | GitHub org/user owning GHCR packages |
| `POSTGRES_PASSWORD` | `changeme` | DB password (change in prod!) |
| `NODE_TAG` / `FASTAPI_TAG` / `NEXTJS_TAG` | `latest` | Image tags to pull |

---

## CI/CD (GitHub Actions)

Each service has its own workflow under `.github/workflows/`:

- `node-service.yml` — triggers on changes to `node-service/**`
- `fastapi-service.yml` — triggers on changes to `fastapi-service/**`
- `nextjs-app.yml` — triggers on changes to `nextjs-app/**`

All workflows:
1. Build a multi-stage Docker image
2. Push to **GitHub Container Registry (GHCR)** on every merge to `main`
3. Tag with `latest`, the branch name, and the short commit SHA

### Required repository settings

- **Packages**: set visibility to *public* or grant `read:packages` to your deployment environment.
- **Variables** (Settings → Variables → Actions):
  - `NEXT_PUBLIC_NODE_API_URL` — public URL of node-service
  - `NEXT_PUBLIC_FASTAPI_URL` — public URL of fastapi-service

---

## Database init

| Database | Init location | When it runs |
|---|---|---|
| PostgreSQL | `postgres/init/*.sql` | First container start (empty volume) |
| DynamoDB | `dynamodb/init/setup.sh` | Every start (idempotent) via `dynamodb-init` sidecar |

---

## Project structure

```
.
├── docker-compose.yml           # Production compose file
├── docker-compose.override.yml  # Dev overrides (hot-reload, local builds)
├── .env.example
├── .dockerignore
│
├── postgres/
│   └── init/01_schema.sql
│
├── dynamodb/
│   └── init/setup.sh
│
├── node-service/
│   ├── Dockerfile
│   ├── package.json
│   └── src/index.js
│
├── fastapi-service/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app/
│       ├── main.py
│       ├── config.py
│       ├── db.py
│       ├── dynamo.py
│       └── routers/items.py
│
├── nextjs-app/
│   ├── Dockerfile
│   ├── next.config.js
│   └── package.json
│
└── .github/
    └── workflows/
        ├── node-service.yml
        ├── fastapi-service.yml
        └── nextjs-app.yml
```
