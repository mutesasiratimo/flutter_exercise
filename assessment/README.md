# FlutterFund assessment

You will build **one app, FlutterFund**, a savings-goals app, over 10 tasks.
Task 1 is a simple one-screen app. Each task adds features to the same app, and
each feature brings in more of the skills the job asks for. By Task 10 you have a
production-style app that logs in, works offline, sends push notifications, is
tested end to end, and is ready for the stores.

## How it works

1. Open the next task in `assessment/tasks/`.
2. Build everything in its **Requirements** list and write the tests it asks for.
3. Answer its **Questions** in `assessment/answers/task_NN.md`, in your own words.
4. Run `flutter analyze` (no issues) and `flutter test` (all passing), commit, then tell me **"Assess task N"**.

I then run your app and tests, add a few tests of my own, review your code, ask
you a few follow-up questions, and write feedback in `assessment/feedback/task_NN.md`.
If something important is missing, you fix it before starting the next task.

Stuck? Ask for a hint, e.g. "hint task 2", instead of looking up a full solution.

## How each task is scored

| Area | 1 | 4 |
|---|---|---|
| **Works** | Requirements missing or buggy | Every requirement works, edge cases handled |
| **Code quality** | Hard to follow, logic in widgets | Clean, reusable, well organised |
| **Tests** | Few or shallow tests | Tests cover the main paths and the failure paths |
| **Understanding** | Can't explain the choices made | Clear answers, knows the trade-offs |

**Pass:** every requirement done, no area below 2, and an average of **3 or more**.

## The tasks

| # | Task | You build | Time |
|---|---|---|---|
| 1 | [Savings tracker](tasks/task_01_savings_tracker.md) | A one-screen app listing goals, with a button to add money | 1–2 h |
| 2 | [Create, edit & delete goals](tasks/task_02_manage_goals.md) | Forms, a detail screen, contributions, multiple currencies | 2–3 h |
| 3 | [Look & feel](tasks/task_03_look_and_feel.md) | Themes, a design system, tablet layout, accessibility, 2 languages, animations | 2–3 h |
| 4 | [Architecture](tasks/task_04_architecture.md) | State management, a repository with DI, tabs, URL navigation, deep links | 3 h |
| 5 | [Backend & login](tasks/task_05_backend_login.md) | Login, a REST API, token refresh, paging, search, error handling | 3 h |
| 6 | [Offline mode](tasks/task_06_offline.md) | Secure storage, a local cache, a sync queue, background sync | 3 h |
| 7 | [Device features & native code](tasks/task_07_device_native.md) | Biometric lock, camera, reminders, Kotlin/Swift, isolates | 2–3 h |
| 8 | [Firebase](tasks/task_08_firebase.md) | Push notifications, analytics, crash reporting, remote config | 2 h |
| 9 | [Quality](tasks/task_09_quality.md) | End-to-end tests, a hidden-bug hunt, performance tuning | 3 h |
| 10 | [Ship it](tasks/task_10_ship_it.md) | Flavors, signing, CI/CD, code review, system design, mock interview | 3 h |

**Short on time?** Tasks 1, 2, 4, 5 and 6 cover the core of the role.

## Where each job requirement is covered

| Job requirement | Task |
|---|---|
| Cross-platform apps with Flutter & Dart | All |
| Reusable widgets, responsive layouts, navigation, animations, async, DI, lifecycle | 1, 2, 3, 4, 7 |
| Reusable widgets, shared packages, utilities, themes, design system | 2, 3 |
| Turning designs into responsive, accessible, maintainable UX | 3 |
| State management (Riverpod / Bloc / Provider / GetX) | 4 |
| REST APIs, authentication, microservices, cloud, third-party SDKs | 5, 8 |
| Secure storage, offline, caching, sync, error handling | 5, 6 |
| Push notifications, deep linking, background processing | 4, 6, 7, 8 |
| Performance: rendering, profiling, memory, images, app size | 7, 9 |
| Unit, widget, integration & end-to-end tests | All (in depth: 9) |
| Diagnosing defects (state, devices, rendering, navigation, API, platform) | 9 |
| Code reviews; clean, secure, documented code | Every review, 10 |
| Working with PO / UX / backend / QA / DevOps | 10 |
| Firebase, analytics, crash reporting, remote config, monitoring | 8 |
| Git, CI/CD, signing, Google Play & App Store, production support | 10 |
| *Bonus:* Kotlin / Swift | 7 |
| *Bonus:* payments, biometrics, maps, location, camera | 7 |
| *Bonus:* design systems, accessibility, localisation | 3 |

## Tools

- Flutter 3.44 / Dart 3.12 (already installed).
- The mock backend for Task 5 onwards: `dart run assessment/mock_server/server.dart`.
- Run `git init` before Task 1, and commit after each task so reviews can compare tasks.
