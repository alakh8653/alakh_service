.PHONY: setup backend-setup frontend-setup start stop \
        backend-dev backend-test \
        db-migrate db-seed db-reset db-studio \
        run-mobile run-shop-web run-admin-web \
        test clean

# ──────────────────────────────────────────────────────────────────────────────
# Full setup
# ──────────────────────────────────────────────────────────────────────────────

## setup: Install all dependencies and generate code for both backend and frontend.
setup: backend-setup frontend-setup

# ──────────────────────────────────────────────────────────────────────────────
# Backend
# ──────────────────────────────────────────────────────────────────────────────

## backend-setup: Install backend npm packages, copy .env.example, and generate Prisma client.
backend-setup:
	cd backend && npm install
	cd backend && cp -n .env.example .env || true
	cd backend && npx prisma generate

## backend-dev: Start the backend in watch mode.
backend-dev:
	cd backend && npm run dev

## backend-test: Run backend unit and integration tests.
backend-test:
	cd backend && npm test

# ──────────────────────────────────────────────────────────────────────────────
# Frontend
# ──────────────────────────────────────────────────────────────────────────────

## frontend-setup: Activate Melos, bootstrap packages, and run code generators.
frontend-setup:
	dart pub global activate melos
	melos bootstrap
	melos run build:runner
	melos run gen:l10n

# ──────────────────────────────────────────────────────────────────────────────
# Docker
# ──────────────────────────────────────────────────────────────────────────────

## start: Start all services (API, PostgreSQL, Redis, pgAdmin, Redis Commander).
start:
	docker-compose up -d

## stop: Stop all services.
stop:
	docker-compose down

# ──────────────────────────────────────────────────────────────────────────────
# Database
# ──────────────────────────────────────────────────────────────────────────────

## db-migrate: Run pending Prisma migrations in development.
db-migrate:
	cd backend && npx prisma migrate dev

## db-seed: Seed the database with initial data.
db-seed:
	cd backend && npx prisma db seed

## db-reset: Reset the database and re-run all migrations (⚠ destructive).
db-reset:
	cd backend && npx prisma migrate reset --force

## db-studio: Open Prisma Studio in the browser.
db-studio:
	cd backend && npx prisma studio

# ──────────────────────────────────────────────────────────────────────────────
# Run apps
# ──────────────────────────────────────────────────────────────────────────────

## run-mobile: Run the mobile app on a connected device or emulator.
run-mobile:
	cd apps/mobile_app && flutter run \
		--dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 \
		--dart-define=WS_BASE_URL=http://10.0.2.2:3000

## run-shop-web: Run the shop dashboard in Chrome.
run-shop-web:
	cd apps/shop_web && flutter run -d chrome \
		--dart-define=API_BASE_URL=http://localhost:3000/api/v1 \
		--dart-define=WS_BASE_URL=http://localhost:3000

## run-admin-web: Run the admin panel in Chrome.
run-admin-web:
	cd apps/admin_web && flutter run -d chrome \
		--dart-define=API_BASE_URL=http://localhost:3000/api/v1 \
		--dart-define=WS_BASE_URL=http://localhost:3000

# ──────────────────────────────────────────────────────────────────────────────
# Tests
# ──────────────────────────────────────────────────────────────────────────────

## test: Run all tests (backend + Flutter).
test: backend-test
	melos run test

# ──────────────────────────────────────────────────────────────────────────────
# Clean
# ──────────────────────────────────────────────────────────────────────────────

## clean: Remove Docker volumes, node_modules, build artifacts, and Dart caches.
clean:
	docker-compose down -v
	cd backend && rm -rf node_modules dist coverage
	melos clean
