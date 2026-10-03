# Task 10: Ship it

**Goal:** Prepare the app for Google Play and the App Store with separate dev/staging/prod builds, signed releases, and automated CI/CD pipelines. Then finish with a code review, a system-design question, and a mock interview.

**Builds on:** Task 9 · **Time:** 3 hours (part of it live with me)

## Part 1: Release & CI/CD

**Build versions (flavors)**
- [ ] Three builds: **dev**, **staging** and **prod**, each with its own app ID (e.g. `com.flutterfund.app.dev`) and app name, so all three can be installed at once.
- [ ] Each reads its settings (API URL, flavor name) from `config/dev.json` etc. via `--dart-define-from-file`. No secrets in these files.
- [ ] Dev and staging show a visible "DEV" / "STAGING" banner.

**Android release**
- [ ] Create a signing key (`keytool`). Its passwords live in `android/key.properties`, which is **git-ignored**.
- [ ] Build a signed release bundle:
  ```bash
  flutter build appbundle --flavor prod --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=config/prod.json
  ```
- [ ] Keep the symbol files, and explain how they're used for crash reports.

**iOS release**
- [ ] Write a step-by-step guide in `assessment/answers/ios_release.md`: bundle IDs,
  certificates, provisioning profiles, push and associated-domain capabilities,
  TestFlight, and App Review. Build it for real if you have a Mac.

**CI/CD (GitHub Actions)**
- [ ] `.github/workflows/ci.yml`, on every pull request: check formatting, analyze, run tests with coverage, and build a dev APK.
- [ ] `.github/workflows/release.yml`, on a version tag (`v1.2.0`): load the signing key from GitHub secrets, build the prod bundle, upload crash symbols, and publish to the Play Store **internal testing** track.
- [ ] Pin the Flutter version in CI.

**Release plan**
- [ ] Write `assessment/answers/release_checklist.md`: what you check before releasing,
  a **staged rollout** (1% → 10% → 50% → 100%) with the numbers that decide whether
  to continue, and what you do if a bad release goes out.

## Part 2: Live with me (about 90 minutes)

- [ ] **Code review:** I'll give you a pull request written by a "colleague". Write
  review comments as you would on GitHub: bugs, security, performance, tests,
  clarity, and tone.
- [ ] **System design:** *"Design a group-savings app for 1 million users, mostly on
  cheap Android phones with poor internet. Members pay by mobile money, see group
  balances, get notified of payments, and admins approve withdrawals. It must work
  offline and never charge twice."*
- [ ] **Mock interview:** quick technical questions from all tasks, plus behavioural
  questions (working with designers, backend developers, and QA, handling a
  production incident, disagreeing in code review).

At the end, I'll write a **final report**: your strengths (with evidence from your
work), your gaps (with a study plan), and talking points for the real interview.

## Questions (answer in `assessment/answers/task_10.md`)

1. What happens if you lose your Android signing key? How does Play App Signing help?
2. What do `--obfuscate` and `--split-debug-info` do, and what breaks if you lose the symbol files?
3. Explain iOS signing: certificate, provisioning profile, entitlements.
4. Why can't you "roll back" a mobile release like a website? What can you do instead?
5. How do you keep secrets out of the Git repo **and** out of the app? Which keys in a mobile app are unavoidably public?
