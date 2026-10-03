# Task 1: Savings tracker

**Goal:** Create a Flutter app that shows a list of savings goals and lets the user add money to each goal.

**Time:** 1–2 hours

## What you're building

A single screen called **FlutterFund**. It lists five savings goals (for example
"Laptop", "School fees", "Emergency fund"). Each goal shows how much has been saved
towards its target. The user taps a button on a goal to add UGX 10,000 to it, and
the screen updates straight away.

## Requirements

- [ ] Replace the counter app with FlutterFund. The app bar title is "FlutterFund".
- [ ] Show **5 hard-coded goals**. Each goal card shows:
  - the goal name
  - the saved and target amounts, e.g. `UGX 500,000 of UGX 2,000,000`
  - a progress bar
  - the percentage saved, e.g. `25%`
- [ ] Each card has an **"Add UGX 10,000"** button that adds that amount to the goal.
- [ ] When a goal reaches its target, it shows a **"Completed" label with a tick icon**, and its button is disabled.
- [ ] At the top of the screen, a summary shows the **total saved across all goals**.
- [ ] Store amounts as **whole numbers (`int`)**, not `double`.
- [ ] Format amounts with thousands separators (`2,000,000`) using **your own function** (no packages).
- [ ] Create a `Goal` class that is **immutable** (all fields `final`) with:
  - a `copyWith` method
  - a `progress` getter (0.0 to 1.0)
  - an `isCompleted` getter
- [ ] Organise the code into files:
  - `lib/models/goal.dart`
  - `lib/widgets/goal_card.dart`
  - `lib/screens/home_screen.dart`
  - `lib/utils/format.dart`
  - `lib/main.dart`

## Tests to write

- [ ] Unit tests for `Goal`: `progress`, `isCompleted`, and that `copyWith` changes only what you pass.
- [ ] Unit tests for your amount formatter: `0`, `999`, `1000`, `2000000`.
- [ ] Widget test: tapping "Add UGX 10,000" updates the amount shown on the card and the total.
- [ ] Widget test: a completed goal shows "Completed" and its button is disabled.
- [ ] Delete or rewrite the old `test/widget_test.dart`.

## Skills this task shows

Dart classes and immutability · stateless vs stateful widgets · `setState` ·
building lists · splitting UI into reusable widgets · unit and widget testing.

## Questions (answer in `assessment/answers/task_01.md`)

1. Why store money as `int` instead of `double`? Give an example where `double` gives a wrong answer.
2. What is the difference between a `StatelessWidget` and a `StatefulWidget`? What happens when you call `setState`?
3. Why use `ListView.builder` rather than a `Column` of cards?
4. What does putting `const` in front of a widget do, and why does it help?
5. Why make `Goal` immutable instead of just changing `goal.saved` directly?

## Bonus (optional)

- Make the progress bar animate smoothly when the amount changes.
- Show goals sorted by progress, with completed goals at the bottom.
