# Contributing to AlakhService

Thank you for your interest in contributing to AlakhService! This guide explains how to contribute effectively.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Branch Naming Convention](#branch-naming-convention)
- [Commit Message Convention](#commit-message-convention)
- [Pull Request Process](#pull-request-process)
- [Code Review Guidelines](#code-review-guidelines)
- [Code Style](#code-style)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)

---

## Code of Conduct

Be respectful and constructive. We follow the [Contributor Covenant](https://www.contributor-covenant.org/).

---

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/alakh_service.git
   cd alakh_service
   ```
3. **Set up** the project following the [setup guide](docs/setup.md):
   ```bash
   make setup
   make build-runner
   ```
4. **Create a branch** from `develop` (or `main` for hotfixes):
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

---

## Branch Naming Convention

Use the following prefixes:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `feature/` | New feature or enhancement | `feature/shop-analytics-dashboard` |
| `bugfix/` | Non-critical bug fix | `bugfix/booking-time-display` |
| `hotfix/` | Critical production fix | `hotfix/payment-crash-fix` |
| `chore/` | Tooling, dependencies, CI/CD | `chore/update-flutter-version` |
| `refactor/` | Code refactoring | `refactor/auth-module-cleanup` |
| `docs/` | Documentation only | `docs/setup-guide-update` |
| `test/` | Adding or fixing tests | `test/booking-bloc-coverage` |

---

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <short description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that is neither a fix nor a feature |
| `test` | Adding or fixing tests |
| `chore` | Build process, CI, tooling, dependencies |
| `perf` | Performance improvement |
| `style` | Formatting, white-space (no logic change) |
| `revert` | Revert a previous commit |

### Examples

```
feat(booking): add slot selection to booking flow
fix(auth): handle expired token refresh race condition
docs(readme): update setup instructions for FVM
chore(deps): upgrade flutter_bloc to 8.1.4
test(shared_models): add unit tests for Booking entity
refactor(api_client): extract retry logic into interceptor
```

---

## Pull Request Process

1. **Run the CI checks** locally before opening a PR:
   ```bash
   make ci   # format + analyze + test
   ```

2. **Ensure all tests pass** and coverage is maintained above **70%**.

3. **Fill out the PR template** completely, including:
   - A clear description of changes
   - Type of change
   - Screenshots for UI changes
   - Related issue numbers

4. **Keep PRs focused** — one logical change per PR. If you're fixing a bug while adding a feature, open separate PRs.

5. **Request a review** from at least one team member via CODEOWNERS assignments.

6. **Address review comments** within 48 hours. If you disagree, discuss in the PR comments.

7. PRs are merged by **squash merge** into `develop`, and `develop` is periodically merged into `main` for releases.

---

## Code Review Guidelines

### For Reviewers

- Review within **48 hours** of assignment.
- Be constructive — suggest improvements with explanations.
- Distinguish between blocking issues (🔴) and suggestions (💡).
- Approve only when all blocking issues are resolved.
- Check for: correctness, test coverage, documentation, code style, performance.

### For Authors

- Respond to all comments before requesting re-review.
- Mark resolved comments with a checkmark.
- Don't force-push after requesting review (it breaks the diff).

---

## Code Style

### Formatting

All Dart code must be formatted with `dart format`:

```bash
make format-fix   # auto-format all files
make format       # check only (used in CI)
```

### Analysis

All code must pass `flutter analyze` with no warnings:

```bash
make analyze
```

### Style Guidelines

- Follow the official [Dart style guide](https://dart.dev/guides/language/effective-dart/style).
- Use `const` constructors where possible.
- Prefer `final` over `var`.
- Name files in `snake_case.dart`.
- Name classes in `PascalCase`.
- Use descriptive variable names — avoid single-letter names except for loop counters.
- Avoid `dynamic` types; use generics or sealed types.
- No `print()` in production code — use a proper logger.
- Keep files under 300 lines; extract when larger.

### Architecture Rules

- Follow the Clean Architecture layer rules: UI → Domain → Data (never cross layers upward).
- BLoCs must not directly call data layer — route through Use Cases.
- Use `Either<Failure, T>` for error handling in domain/data layers.
- Dependency injection via `injectable`/`get_it` — never instantiate services directly in UI.

---

## Testing Requirements

All new code **must** have tests:

| Code Type | Test Required | Minimum Coverage |
|-----------|--------------|-----------------|
| Use Cases (domain logic) | Unit test | 90% |
| BLoCs / Cubits | Unit test with `bloc_test` | 90% |
| Repositories | Unit test with mocks | 80% |
| Widgets | Widget test | 70% |
| API client / Data sources | Unit test with mocked HTTP | 80% |

### Running Tests

```bash
# All tests
make test

# Unit tests only
melos run test:unit

# Widget tests
melos run test:widget

# Specific package
cd packages/shared_models && flutter test --coverage
```

### Test File Structure

```
lib/
  features/
    booking/
      domain/
        use_cases/
          get_bookings_use_case.dart
test/
  features/
    booking/
      domain/
        use_cases/
          get_bookings_use_case_test.dart   ← mirrors lib/ structure
```

### Mocking

Use `mocktail` for mocking:

```dart
class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late MockBookingRepository mockRepo;
  late GetBookingsUseCase useCase;

  setUp(() {
    mockRepo = MockBookingRepository();
    useCase = GetBookingsUseCase(mockRepo);
  });

  test('returns bookings on success', () async {
    when(() => mockRepo.getBookings()).thenAnswer(
      (_) async => Right([Booking.fixture()]),
    );
    final result = await useCase(NoParams());
    expect(result.isRight(), true);
  });
}
```

---

## Documentation

- Public APIs must have `///` dartdoc comments.
- Update `CHANGELOG.md` for user-facing changes.
- Update `README.md` if the setup steps or features change.
- Update `ARCHITECTURE.md` if you change the architecture.
