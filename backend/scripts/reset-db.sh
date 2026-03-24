#!/usr/bin/env bash
# Reset database: drop, recreate, migrate, and seed
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${CYAN}[RESET-DB]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BACKEND_DIR"

# ---- Confirmation ----
if [ "${1:-}" != "--yes" ] && [ "${1:-}" != "-y" ]; then
  warn "This will DROP and RECREATE the database, and re-run all migrations."
  read -rp "Are you sure? (y/N): " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { log "Aborted."; exit 0; }
fi

# ---- Load env ----
if [ -f ".env" ]; then
  set -a
  # shellcheck disable=SC1091
  source .env
  set +a
else
  error ".env file not found. Run scripts/setup.sh first."
fi

log "Resetting database..."

# ---- Drop all tables via Prisma ----
log "Running prisma migrate reset..."
npx prisma migrate reset --force
success "Database reset complete"

# ---- Seed ----
log "Running seed..."
npx ts-node prisma/seed.ts
success "Seed complete"

echo ""
success "Database has been fully reset and seeded."
