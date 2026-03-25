#!/usr/bin/env bash
# Setup script for Alakh Service Backend
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${CYAN}[SETUP]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BACKEND_DIR"

log "Starting Alakh Service Backend setup..."
log "Backend directory: $BACKEND_DIR"

# ---- Check prerequisites ----
command -v node >/dev/null 2>&1 || error "Node.js is not installed. Install from https://nodejs.org"
command -v npm >/dev/null 2>&1 || error "npm is not installed."

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  error "Node.js 18+ is required. Current: $(node -v)"
fi
success "Node.js $(node -v) found"

# ---- .env file ----
if [ ! -f ".env" ]; then
  log "Creating .env from .env.example..."
  cp .env.example .env
  warn ".env created. Please fill in real values before running the server."
else
  success ".env file already exists"
fi

# ---- Install dependencies ----
log "Installing npm dependencies..."
npm install
success "Dependencies installed"

# ---- Prisma generate ----
log "Generating Prisma client..."
npx prisma generate
success "Prisma client generated"

# ---- Check DB connection (optional) ----
if command -v psql >/dev/null 2>&1; then
  log "Attempting database migration..."
  npx prisma migrate dev --name init || warn "Migration failed. Ensure DATABASE_URL is configured."
else
  warn "PostgreSQL client not found locally. Run migrations manually after configuring DATABASE_URL."
fi

# ---- Create log dir ----
mkdir -p logs
success "Log directory created"

# ---- Done ----
echo ""
echo -e "${GREEN}╔══════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Setup complete! Next steps:     ║${NC}"
echo -e "${GREEN}╠══════════════════════════════════╣${NC}"
echo -e "${GREEN}║  1. Edit .env with your config   ║${NC}"
echo -e "${GREEN}║  2. npm run prisma:migrate       ║${NC}"
echo -e "${GREEN}║  3. npm run prisma:seed          ║${NC}"
echo -e "${GREEN}║  4. npm run dev                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════╝${NC}"
