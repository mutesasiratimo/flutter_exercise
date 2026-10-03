# Task 9: Quality (end-to-end tests, bug hunt & performance)

**Goal:** Prove the app is reliable and fast: automate the main user journey end to end, find and fix hidden bugs in a feature someone else wrote, and measure and improve performance.

**Builds on:** Task 8 · **Time:** 3 hours

## What you're building

A test that drives the real app on an emulator, from login to contribution to
logout, against the mock server. You also fix a buggy **Leaderboard** feature, which
I'll add to your app when you start this task. It has about 10 hidden bugs covering
state, layout, memory leaks, navigation, API use, and performance. Finally, you make
the app measurably faster and smaller.

## Requirements

**End-to-end tests (`integration_test`)**, run on an Android emulator against the mock server:
- [ ] Log in → see goals → scroll to load more → search "laptop" → open a goal → add a contribution → see the new amount on the detail and list screens → log out.
- [ ] Enter an invalid contribution amount → see the error message.
- [ ] Offline: add a contribution with no internet → "Pending sync" → back online → it syncs, and the server shows **one** contribution.
- [ ] Run with: `flutter test integration_test`

**Other tests**
- [ ] **Golden (screenshot) tests** for `GoalCard`: active / completed, light / dark, normal / large text.
- [ ] Test coverage of **at least 70%** of `lib/` (excluding generated files). Run `flutter test --coverage`.
- [ ] Run the whole suite 5 times in a row with no random failures.

**Bug hunt**
- [ ] Fix **at least 8** of the Leaderboard bugs.
- [ ] For each, write a short report in `assessment/answers/task_09_bugs.md`:
  **what the user sees → how to reproduce → the real cause → the fix → the test you added**.

**Performance** (measure in **profile mode**: `flutter run --profile`)
- [ ] Measure and write down: startup time, janky frames while scrolling the goals list,
  memory after opening and closing a goal 20 times, and APK size
  (`flutter build apk --analyze-size --target-platform android-arm64`).
- [ ] Make **at least 3 improvements**, with before and after numbers. For example:
  image sizes and caching, fewer widget rebuilds, faster lists, smaller app size, less work at startup.

## Skills this task shows

Integration and end-to-end testing · golden tests · debugging state, rendering,
navigation, API, and memory bugs · profiling with DevTools · image optimisation ·
reducing app size.

## Questions (answer in `assessment/answers/task_09.md`)

1. What can an integration test catch that a widget test can't?
2. `pump()` vs `pumpAndSettle()`: when does `pumpAndSettle` hang, and what do you do?
3. Why must you never measure performance in debug mode?
4. What are the most common causes of memory leaks in Flutter apps?
5. A user says "the app freezes on my Tecno phone but not on my Pixel". How do you investigate?
