#!/usr/bin/env bash
# Generate Prisma client and TypeScript types
set -euo pipefail

CYAN='\033[0;36m'
GREEN='\033[0;32m'
NC='\033[0m'

log() { echo -e "${CYAN}[GEN-TYPES]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }

BACKEND_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$BACKEND_DIR"

log "Generating Prisma client..."
npx prisma generate
success "Prisma client generated at node_modules/@prisma/client"

log "Building TypeScript project to verify types..."
npx tsc --noEmit
success "TypeScript types verified — no errors"

echo ""
success "Type generation complete."
