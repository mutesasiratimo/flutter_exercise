# Task 4: Architecture (state management, DI & navigation)

**Goal:** Restructure the app so it can scale: move state into Riverpod or Bloc, load data through a repository injected with dependency injection, and switch to URL-based navigation with tabs and deep links.

**Builds on:** Task 3 · **Time:** 3 hours

## What you're building

To the user, the app now has three tabs: **Goals**, **Summary** and **Settings**.
It shows proper loading and error screens, and a link like `flutterfund://goals/g2`
opens a goal directly. Under the hood, you're replacing `setState` and
`Navigator.push` with a structure a team could work in.

## Requirements

**State management**
- [ ] Choose **Riverpod** or **Bloc**, and say why in your answers.
- [ ] Remove all app-level `setState`. `setState` is only allowed for small local UI state.
- [ ] Goals, the selected goal, theme, and language all live in your state solution.

**Repository & dependency injection**
- [ ] A `GoalsRepository` interface (fetch goals, fetch one goal, create, update, delete, add contribution).
- [ ] An `InMemoryGoalsRepository` that waits **800 ms** and fails **20% of the time**
  when "Simulate slow network" is switched on in Settings.
- [ ] Wire dependencies in **one place** (e.g. `lib/bootstrap.dart`). Screens never create repositories themselves.
- [ ] Organise folders by feature: `lib/features/goals/{data,domain,presentation}`, `lib/features/settings/…`.

**Loading, errors & updates**
- [ ] The goals list shows **loading**, **error with Retry**, **empty**, and **data** states.
- [ ] Pull-to-refresh keeps the old list visible while reloading.
- [ ] Adding a contribution shows the new amount **immediately**. If the repository fails,
  it **reverts** and shows an error message.
- [ ] Double-tapping "Save" doesn't add the contribution twice.

**Navigation (`go_router`)**
- [ ] Bottom tabs: **Goals / Summary / Settings** (a side rail on wide screens).
  Each tab keeps its own history when you switch tabs.
- [ ] Routes: `/goals`, `/goals/new`, `/goals/:id`, `/goals/:id/edit`, `/summary`, `/settings`.
- [ ] An unknown route shows a "Page not found" screen. An unknown goal ID shows "Goal not found".
- [ ] **Summary tab:** total saved per currency, the number of goals by status, and the goal closest to completion.
- [ ] **Deep link:** `flutterfund://goals/<id>` opens that goal on Android, with the goals list behind it. Test it with:
  ```bash
  adb shell am start -a android.intent.action.VIEW -d "flutterfund://goals/g2"
  ```

## Tests to write

- [ ] State tests with a **fake repository**: loading → data; error → retry → data; the optimistic contribution reverts on failure; double submit is ignored.
- [ ] A widget test that injects a failing fake repository and shows the error view with Retry.
- [ ] Router tests: `/goals/g2` opens the detail screen; an unknown route shows "Page not found"; switching tabs keeps each tab's history.

## Skills this task shows

State management · dependency injection · layered architecture · repository
pattern · navigation · deep linking · optimistic updates · testable design.

## Questions (answer in `assessment/answers/task_04.md`)

1. Why did you choose Riverpod or Bloc? How would the other one (and Provider or GetX) handle the same problem?
2. *(Riverpod)* `ref.watch` vs `ref.read` vs `ref.listen`. *(Bloc)* `BlocBuilder` vs `BlocListener`. Where should snackbars and navigation be triggered?
3. `context.go` vs `context.push` in `go_router`: what happens to the back stack?
4. What can go wrong with optimistic updates if the user adds two contributions quickly?
5. Why do screens receive the repository instead of creating it? How does that help testing?

## Bonus (optional)

- Undo a contribution within 5 seconds.
- Keep the list filter and sort in the URL (`/goals?status=active&sort=progress`).
