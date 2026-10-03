# Task 2: Create, edit & delete goals

**Goal:** Extend the app so users can create their own goals, add contributions of any amount, see each goal's details, and edit or delete goals, in more than one currency.

**Builds on:** Task 1 · **Time:** 2–3 hours

## What you're building

The user is no longer stuck with five fixed goals. They tap **+** to create a goal,
tap a goal to see its details and contribution history, add any amount, and edit or
delete goals. Goals can be in UGX, USD or KES, and each currency is shown correctly.

## Requirements

**Money**
- [ ] Create a `Money` class: an amount in the smallest unit (cents for USD/KES,
  shillings for UGX) plus a currency.
  - [ ] `format()` → `UGX 50,000`, `USD 12.50`, `KES 1,000.00`
  - [ ] `Money.parse('12.50', 'USD')` turns user input into money **without using `double`** (`'4.35'` must give 435 cents)
  - [ ] Add and compare amounts. Mixing currencies throws an error.
- [ ] `Goal` now uses `Money` for its target and saved amounts.

**New goal screen** (opened with a floating **+** button)
- [ ] Fields: name, target amount, currency (UGX / USD / KES), and an optional deadline (date picker).
- [ ] Validation with messages under each field:
  - name is required, 3–40 characters
  - amount is required, must be a number, and must be greater than 0
  - USD/KES allow up to 2 decimals; UGX allows none
- [ ] Saving returns to the list, and the new goal appears **at the top**. Pass it back with `Navigator.pop`.

**Goal detail screen** (tap a goal)
- [ ] Shows the name, amounts, progress, deadline, and **"12 days left"** / **"Due today"** / **"3 days overdue"**.
- [ ] Shows the **contribution history** (amount and date, newest first).
- [ ] An **"Add contribution"** button opens a **bottom sheet** with an amount field:
  - it can't be empty or 0
  - it can't be more than the remaining amount (show `Amount exceeds the remaining UGX 150,000`)
- [ ] The updated amount shows on the detail screen **and** on the list.
- [ ] **Edit goal** opens the same form as "New goal", pre-filled.

**List screen**
- [ ] **Swipe a goal to delete it**, with a "Goal deleted" snackbar that has an **UNDO** button.
- [ ] When there are no goals, show an empty state: an icon plus "Create your first goal".

**Code quality**
- [ ] Build one reusable `AmountField` widget and use it in both the goal form and the contribution sheet.
- [ ] Dispose every `TextEditingController`.
- [ ] No "setState() called after dispose()" errors.

## Tests to write

- [ ] `Money` unit tests: parsing (`'4.35'`, `'1,000'`, `'abc'`, too many decimals), formatting per currency, mixing currencies throws.
- [ ] Form widget tests: each validation message appears for the right input, and a valid form returns a goal.
- [ ] Contribution sheet: an amount over the remaining shows the error, and a valid amount updates the goal.
- [ ] Swipe to delete, then UNDO brings the goal back.
- [ ] Days-left text for future, today, and past deadlines. Make the current date injectable so the test doesn't depend on today's date.

## Skills this task shows

Forms and validation · navigation with results · bottom sheets · widget lifecycle
(`initState`, `dispose`, `mounted`) · keys in lists · reusable widgets ·
value objects · testable code (injecting the clock).

## Questions (answer in `assessment/answers/task_02.md`)

1. List the `StatefulWidget` lifecycle methods in the order they run. What goes in `initState` and `dispose`?
2. What does checking `mounted` protect you from after an `await`?
3. Why does the swipe-to-delete list need a `Key` on each item? What goes wrong without one?
4. How did you get the new or edited goal back to the list? What becomes painful about this as the app grows?
5. How does your `Money.parse` avoid floating-point errors?

## Bonus (optional)

- Reorder goals by drag and drop.
- Use `Money.allocate` to split a contribution across several goals without losing a cent.
