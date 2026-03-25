# Changelog

All notable changes to AlakhService will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [1.0.0] — 2026-03-24

### Added

#### Mobile App (`apps/mobile_app`)

- **Auth**: Phone OTP login with Firebase Authentication
- **Onboarding**: First-run onboarding flow with permission requests
- **Discovery**: Nearby shop search with map view and category filters
- **Booking**: Service booking with slot selection and confirmation
- **Queue**: Live queue position tracking with real-time updates
- **Dispatch**: Staff dispatch notifications and live status
- **Tracking**: Real-time service progress and ETA tracking
- **Payments**: In-app payments supporting UPI, cards, and wallet
- **Disputes**: Raise and track disputes with evidence upload
- **Trust**: Trust scores, user ratings, and badge display
- **Reviews**: Write and read shop/service reviews
- **Chat**: In-app messaging between consumers and shops
- **Referral**: Referral program with reward tracking
- **Notifications**: Push notification center with read/unread states
- **Profile**: User profile management with photo upload
- **Settings**: App preferences, language, and notification settings
- **Staff Mode**: Staff-specific view for managing assigned bookings

#### Shop Dashboard (`apps/shop_web`)

- **Dashboard**: Overview KPIs, today's summary, and quick actions
- **Queue Control**: Real-time queue management, call next customer, hold/skip
- **Bookings**: View, filter, and manage all bookings
- **Staff Management**: Add/remove staff, assign roles, set schedules
- **Earnings**: Revenue tracking, daily/weekly/monthly breakdowns
- **Analytics**: Booking trends, customer demographics, service popularity
- **Settlements**: Payment settlement history and export
- **Compliance**: Document upload, verification status, compliance checklist
- **Settings**: Shop profile, operating hours, services, and pricing

#### Admin Panel (`apps/admin_web`)

- **City Management**: CRUD for cities, service zones, geo-fencing, pricing rules
- **Shop Approval**: Review shop applications, approve/reject with comments
- **Dispute Resolution**: Admin dispute queue, assign mediators, process refunds
- **Fraud Monitoring**: Fraud alerts, risk scores, suspicious activity dashboard, blacklist
- **Payments Monitoring**: Payment pipeline health, failed payment queue, reconciliation
- **Trust Engine Control**: Configure trust score weights, thresholds, and badge rules
- **Audit Logs**: System-wide audit trail with filters and CSV export
- **Analytics Dashboard**: Platform KPIs, revenue, user growth, cohort analysis
- **System Health**: Service uptime, API latency monitoring, feature flags

#### Shared Packages (`packages/`)

- **`shared_models`**: Core entities (User, Shop, Booking, Payment, etc.) with Freezed
- **`shared_utils`**: Extensions, formatters, validators, and helpers
- **`api_client`**: Dio-based HTTP client with auth, retry, and logging interceptors
- **`ui_kit`**: Design system — colors, typography, spacing, and 30+ shared widgets
- **`auth_module`**: JWT token management, secure storage, refresh logic
- **`realtime_client`**: WebSocket client with reconnection and event streaming
- **`analytics_module`**: Event tracking, screen view logging, user properties
- **`notification_module`**: FCM push notification handling, local notifications

#### Infrastructure

- Melos monorepo configuration (`melos.yaml`)
- GitHub Actions CI/CD workflows (CI, mobile build, web build, code quality)
- Dependabot for weekly dependency updates
- PR and issue templates
- Code owners configuration
- Comprehensive root documentation (`README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`)
- Editor configuration (`.editorconfig`)
- Flutter version pinning (`.fvmrc`)
- Root `Makefile` with developer shortcuts

[Unreleased]: https://github.com/alakh8653/alakh_service/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/alakh8653/alakh_service/releases/tag/v1.0.0
