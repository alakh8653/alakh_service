.DEFAULT_GOAL := help

# ==============================================================================
# AlakhService Monorepo Makefile
# ==============================================================================

FLUTTER := flutter
DART    := dart
MELOS   := melos

.PHONY: help setup clean get test analyze format build-runner \
        build-android build-android-prod build-android-aab \
        build-ios build-ios-prod build-web ci

help: ## Show this help message
	@echo "AlakhService Monorepo — Available Commands:"
	@echo "============================================="
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ------------------------------------------------------------------------------
# Setup
# ------------------------------------------------------------------------------

setup: ## Install melos globally and bootstrap the workspace
	@echo "→ Installing Melos..."
	dart pub global activate melos
	@echo "→ Bootstrapping workspace..."
	melos bootstrap
	@echo "✓ Setup complete!"

# ------------------------------------------------------------------------------
# Maintenance
# ------------------------------------------------------------------------------

clean: ## Clean all packages and apps
	@echo "→ Cleaning workspace..."
	$(MELOS) run clean
	@echo "✓ Clean complete!"

get: ## Get all dependencies across the workspace
	@echo "→ Getting dependencies..."
	$(MELOS) run get
	@echo "✓ Dependencies fetched!"

outdated: ## Check outdated dependencies
	$(MELOS) run outdated

upgrade: ## Upgrade all dependencies
	$(MELOS) run upgrade

# ------------------------------------------------------------------------------
# Code Quality
# ------------------------------------------------------------------------------

analyze: ## Analyze all code across the workspace
	@echo "→ Analyzing code..."
	$(MELOS) run analyze
	@echo "✓ Analysis complete!"

format: ## Format all code (check only)
	@echo "→ Checking formatting..."
	$(MELOS) run format
	@echo "✓ Format check complete!"

format-fix: ## Format all code (auto-fix)
	@echo "→ Formatting code..."
	$(MELOS) run format:fix
	@echo "✓ Formatting complete!"

# ------------------------------------------------------------------------------
# Testing
# ------------------------------------------------------------------------------

test: ## Run all tests with coverage
	@echo "→ Running tests..."
	$(MELOS) run test
	@echo "✓ Tests complete!"

test-unit: ## Run unit tests only
	$(MELOS) run test:unit

test-widget: ## Run widget tests only
	$(MELOS) run test:widget

test-integration: ## Run integration tests
	$(MELOS) run test:integration

# ------------------------------------------------------------------------------
# Code Generation
# ------------------------------------------------------------------------------

build-runner: ## Run build_runner code generation in all packages
	@echo "→ Running code generation..."
	$(MELOS) run build:runner
	@echo "✓ Code generation complete!"

gen-l10n: ## Generate localizations in all apps
	@echo "→ Generating localizations..."
	$(MELOS) run gen:l10n
	@echo "✓ Localization generation complete!"

# ------------------------------------------------------------------------------
# Mobile Builds
# ------------------------------------------------------------------------------

build-android: ## Build Android APK (dev flavor)
	@echo "→ Building Android APK (dev)..."
	$(MELOS) run build:android:dev
	@echo "✓ Android dev build complete!"

build-android-prod: ## Build Android APK (production flavor)
	@echo "→ Building Android APK (production)..."
	$(MELOS) run build:android:prod
	@echo "✓ Android production build complete!"

build-android-aab: ## Build Android App Bundle (production)
	@echo "→ Building Android App Bundle (production)..."
	$(MELOS) run build:android:aab:prod
	@echo "✓ Android AAB build complete!"

build-ios: ## Build iOS (dev flavor, no codesign)
	@echo "→ Building iOS (dev)..."
	$(MELOS) run build:ios:dev
	@echo "✓ iOS dev build complete!"

build-ios-prod: ## Build iOS (production, no codesign)
	@echo "→ Building iOS (production)..."
	$(MELOS) run build:ios:prod
	@echo "✓ iOS production build complete!"

# ------------------------------------------------------------------------------
# Web Builds
# ------------------------------------------------------------------------------

build-web: ## Build all web apps (shop_web + admin_web)
	@echo "→ Building shop_web..."
	$(MELOS) run build:web:shop
	@echo "→ Building admin_web..."
	$(MELOS) run build:web:admin
	@echo "✓ All web builds complete!"

build-web-shop: ## Build shop_web only
	$(MELOS) run build:web:shop

build-web-admin: ## Build admin_web only
	$(MELOS) run build:web:admin

# ------------------------------------------------------------------------------
# CI
# ------------------------------------------------------------------------------

ci: format analyze test ## Full CI check: format → analyze → test
	@echo "✓ All CI checks passed!"

ci-full: format analyze build-runner test ## Full CI with code generation
	@echo "✓ Full CI pipeline complete!"

# ------------------------------------------------------------------------------
# Utilities
# ------------------------------------------------------------------------------

loc: ## Count lines of code (excluding generated files)
	$(MELOS) run loc

graph: ## Generate dependency graph for all packages
	$(MELOS) run graph
