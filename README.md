# AlakhService

> **Hyperlocal service marketplace** — connecting customers with local service providers for home services, repairs, beauty, and more.

[![Backend CI](https://github.com/alakh8653/alakh_service/actions/workflows/backend-ci.yml/badge.svg)](https://github.com/alakh8653/alakh_service/actions/workflows/backend-ci.yml)

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐  │
│  │   mobile_app     │  │   shop_web       │  │  admin_web   │  │
│  │  (Flutter iOS/   │  │  (Flutter Web    │  │ (Flutter Web │  │
│  │   Android)       │  │   Shop Dashboard)│  │  Admin Panel)│  │
│  └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘  │
│           │                     │                    │          │
│           └─────────────────────┼────────────────────┘          │
│                                 │                               │
│              Shared packages: api_client · auth_module          │
│              shared_models · shared_utils · ui_kit              │
│              realtime_client · notification_module              │
│              analytics_module                                   │
└─────────────────────────────────┬───────────────────────────────┘
                                  │  REST (HTTP/HTTPS) + WebSocket
┌─────────────────────────────────▼───────────────────────────────┐
│                        BACKEND LAYER                            │
│                                                                 │
│           Node.js + TypeScript + Express                        │
│           Prisma ORM · Socket.IO · Bull (job queues)            │
│           JWT Auth · Razorpay · FCM · AWS S3                    │
│                                                                 │
└──────────────────┬──────────────────────────┬───────────────────┘
                   │                          │
       ┌───────────▼──────────┐  ┌────────────▼──────────┐
       │   PostgreSQL 16       │  │       Redis 7          │
       │   (primary datastore) │  │   (cache · sessions   │
       └───────────────────────┘  │    · job queues)       │
                                  └───────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Mobile / Web Frontend** | Flutter 3, Dart 3 |
| **State Management** | BLoC / Cubit |
| **HTTP Client** | Dio (via `api_client` package) |
| **Real-time** | Socket.IO (via `realtime_client` package) |
| **Backend Runtime** | Node.js 20 LTS |
| **Backend Language** | TypeScript |
| **Web Framework** | Express.js |
| **ORM** | Prisma |
| **Database** | PostgreSQL 16 |
| **Cache / Queue** | Redis 7 + Bull |
| **Auth** | JWT (access + refresh tokens) |
| **Payments** | Razorpay |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **File Storage** | AWS S3 |
| **Monitoring** | Sentry |
| **Containerisation** | Docker + Docker Compose |

---

## Quick Start

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ≥ 3.10
- [Dart SDK](https://dart.dev/get-dart) ≥ 3.0
- [Node.js](https://nodejs.org/) 20 LTS
- [Docker](https://www.docker.com/) + Docker Compose

### 1 — Install dependencies

```bash
make setup
```

This runs `npm install` for the backend, copies `.env.example → .env`, generates the Prisma client, bootstraps all Flutter packages via Melos, and runs code generators.

### 2 — Start infrastructure

```bash
make start
```

Starts PostgreSQL, Redis, the API server, pgAdmin (`:8080`), and Redis Commander (`:8081`) via Docker Compose.

### 3 — Run database migrations

```bash
make db-migrate
make db-seed   # optional: seed with sample data
```

### 4 — Run the apps

```bash
make run-mobile       # Flutter mobile app (Android/iOS)
make run-shop-web     # Shop dashboard (Chrome)
make run-admin-web    # Admin panel (Chrome)
```

The backend API is available at **http://localhost:3000/api/v1** and the interactive API docs at **http://localhost:3000/api/docs**.

---

## Project Structure

```
alakh_service/                   ← monorepo root
├── apps/
│   ├── mobile_app/              ← Customer-facing Flutter app (iOS + Android)
│   │   ├── lib/
│   │   │   ├── config/env.dart  ← Build-time environment config
│   │   │   └── main.dart
│   │   ├── .env.example
│   │   └── .vscode/launch.json  ← Dev/Staging/Production run configs
│   ├── shop_web/                ← Provider/shop Flutter web dashboard
│   │   ├── lib/config/env.dart
│   │   └── .env.example
│   └── admin_web/               ← Admin control panel Flutter web
│       ├── lib/config/env.dart
│       └── .env.example
│
├── packages/                    ← Shared Flutter packages
│   ├── api_client/              ← Dio HTTP client, interceptors, endpoints
│   ├── auth_module/             ← Auth logic, token management
│   ├── shared_models/           ← Freezed data models shared across apps
│   ├── shared_utils/            ← Extensions, helpers, utilities
│   ├── ui_kit/                  ← Design system, theme, common widgets
│   ├── realtime_client/         ← Socket.IO client (queue, tracking, chat)
│   ├── notification_module/     ← FCM + local notifications, channels, prefs
│   └── analytics_module/        ← Analytics (Firebase), events, screen tracking
│
├── backend/                     ← Node.js TypeScript backend
│   ├── src/
│   │   ├── config/              ← App config, CORS, env validation
│   │   ├── middleware/          ← Auth, error handling, rate limiting
│   │   ├── modules/             ← Feature modules (auth, bookings, payments…)
│   │   └── shared/              ← Shared utilities, validators, types
│   ├── prisma/
│   │   ├── schema.prisma        ← Database schema (40+ models)
│   │   └── migrations/          ← SQL migrations
│   └── docker/
│       └── Dockerfile
│
├── .github/
│   └── workflows/
│       ├── backend-ci.yml       ← Lint → Test → Build → Docker
│       └── backend-deploy.yml   ← Deploy to staging on push to main
│
├── docker-compose.yml           ← Full stack: API + PostgreSQL + Redis + UIs
├── Makefile                     ← Developer convenience commands
└── README.md
```

---

## Available Make Commands

| Command | Description |
|---|---|
| `make setup` | Full install (backend + frontend) |
| `make start` | Start Docker Compose stack |
| `make stop` | Stop Docker Compose stack |
| `make backend-dev` | Start backend in watch mode |
| `make backend-test` | Run backend tests |
| `make db-migrate` | Run Prisma migrations |
| `make db-seed` | Seed database |
| `make db-reset` | Reset + re-migrate database ⚠ |
| `make db-studio` | Open Prisma Studio |
| `make run-mobile` | Run Flutter mobile app |
| `make run-shop-web` | Run Flutter shop web |
| `make run-admin-web` | Run Flutter admin web |
| `make test` | Run all tests |
| `make clean` | Remove containers, volumes, build artifacts |

---

## API Documentation

- **Interactive (Swagger UI):** http://localhost:3000/api/docs  
- **OpenAPI spec:** `backend/docs/openapi.yaml`  
- **Postman collection:** `backend/docs/AlakhService.postman_collection.json`

---

## Environment Setup

Each app uses `--dart-define` flags for build-time environment injection — **no secrets are ever committed**.

Copy the example file for each app/backend and fill in real values:

```bash
cp apps/mobile_app/.env.example   apps/mobile_app/.env
cp apps/shop_web/.env.example     apps/shop_web/.env
cp apps/admin_web/.env.example    apps/admin_web/.env
cp backend/.env.example           backend/.env
```

The VS Code launch configurations in `apps/mobile_app/.vscode/launch.json` include pre-configured Development, Staging, and Production run targets.

---

## Backend Modules

| Module | Endpoints | Key Features |
|---|---|---|
| **Auth** | 8 | OTP login, JWT refresh, logout |
| **Users** | 12 | Profile management, addresses |
| **Shops / Services** | 20 | CRUD, search, availability |
| **Bookings** | 15 | Create, confirm, cancel, complete |
| **Queue** | 10 | Join, leave, position updates |
| **Dispatch** | 12 | Staff assignment, location tracking |
| **Payments** | 30 | Razorpay, wallet, refunds, settlements |
| **Reviews** | 19 | Submit, moderate, shop responses |
| **Chat** | 16 | Real-time messaging, file uploads |
| **Notifications** | 13 | FCM, preferences, bulk send |
| **Disputes** | 21 | Evidence, mediation, resolutions |
| **Trust** | 22 | Score calculation, badges, verification |
| **Referrals** | 14 | Codes, rewards, leaderboard |
| **Compliance** | 16 | Documents, approval, expiry reminders |
| **Admin** | 30+ | Dashboard, flags, audit logs, exports |
| **Analytics** | 13 | Revenue, growth, heatmaps, cohorts |

---

## Deployment

### Docker (recommended)

```bash
# Build and start the full stack
docker-compose up --build

# Production (with your own .env and registry)
docker build -t alakh-service-backend:latest ./backend/docker/Dockerfile
```

The CI/CD pipeline (`.github/workflows/backend-ci.yml`) automatically:
1. Lints and formats the code
2. Runs tests with PostgreSQL + Redis service containers
3. Builds the TypeScript project
4. Builds the Docker image on merges to `main`

The deploy workflow (`.github/workflows/backend-deploy.yml`) triggers on pushes to `main` and deploys to the configured staging environment. Update the `TODO` steps with your container registry and deployment target (ECS, Cloud Run, Kubernetes, etc.).

---

## Contributing

1. Fork the repository and create a feature branch from `develop`
2. Follow the existing code style (ESLint + Prettier for backend, `flutter_lints` for Dart)
3. Write tests for new features
4. Open a pull request targeting `develop`

---

## License

MIT © AlakhService
