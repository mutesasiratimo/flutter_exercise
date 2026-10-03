# Task 3: Look & feel

**Goal:** Give the app a consistent design (light and dark themes plus reusable components), make it work well on phones and tablets, for screen-reader users, and in two languages, with polished animations.

**Builds on:** Task 2 · **Time:** 2–3 hours

## What you're building

A **Settings** screen where the user picks the theme and language. A small **design
system** of reusable components used throughout the app. On a **tablet or in
landscape**, the list and the goal detail show side by side. A screen reader can use
the whole app, large text doesn't break the layout, and the app is available in
English plus one more language.

## Requirements

**Theme & design system**
- [ ] Light **and** dark themes built from one seed colour, with a Settings choice of System / Light / Dark.
- [ ] Extra colours Material doesn't have (e.g. `success`, `warning`) come from a `ThemeExtension`.
- [ ] A `lib/design_system/` folder with these reusable components:
  - [ ] `AppButton`: primary / secondary / danger styles, a loading state (spinner, disabled), and an optional icon
  - [ ] `AppTextField`
  - [ ] `AmountText`: displays `Money` formatted for the current language
  - [ ] `GoalProgressBar`
  - [ ] `EmptyState` and `ErrorView` (with a Retry button)
  - [ ] spacing and corner-radius constants
- [ ] Screens use these components. **No hard-coded colours or font sizes** inside screens.

**Phones & tablets**
- [ ] Narrow screens (< 840 px wide): list → tap → detail screen, as before.
- [ ] Wide screens (≥ 840 px): **list on the left, selected goal on the right**, without opening a new page.
- [ ] Rotating the device doesn't lose the selected goal or any typed text.
- [ ] Forms still work with the keyboard open on a small phone (they scroll, with no overflow).

**Accessibility**
- [ ] A screen reader reads each goal card as **one** sentence, e.g. *"Laptop, 25 percent saved, UGX 500,000 of UGX 2,000,000"*.
- [ ] Every button has a label and is at least 48×48.
- [ ] Nothing overflows when text size is at **200%**.
- [ ] Text colours meet contrast guidelines in both themes.

**Languages**
- [ ] English plus one more language (Swahili or French), set up with `flutter gen-l10n` (ARB files).
- [ ] A language option in Settings.
- [ ] At least one plural: "No goals" / "1 goal" / "5 goals".
- [ ] Dates and amounts are formatted for the selected language (`intl`).
- [ ] **No hard-coded user-facing text** in screens.

**Animations**
- [ ] The progress bar animates when the saved amount changes.
- [ ] A **Hero** animation from the goal card to the detail screen.
- [ ] A short **celebration animation** when a goal is completed. It plays once and not again on rebuild.
- [ ] When the device's "reduce motion" setting is on, animations are skipped.

## Tests to write

- [ ] A widget test for each design-system component, including the `AppButton` loading and disabled states.
- [ ] Accessibility tests on the list and form screens using `meetsGuideline(...)` (tap target size, labels, contrast).
- [ ] No overflow at text scale 2.0.
- [ ] A 1024×768 screen shows two panes, and a 390×844 screen shows one.
- [ ] The app in your second language shows a translated string.
- [ ] The celebration animation runs once.

## Skills this task shows

Themes · design-system components · responsive layouts · accessibility ·
localisation/internationalisation · implicit and explicit animations · turning
design requirements into UI.

## Questions (answer in `assessment/answers/task_03.md`)

1. `MediaQuery` vs `LayoutBuilder`: when would you use each?
2. How would you test the app with TalkBack (Android) and VoiceOver (iOS)? What does `MergeSemantics` change?
3. Why is `'You saved ' + amount + ' this month'` a translation bug? What's the right way?
4. Implicit vs explicit animations: when do you need an `AnimationController`, and what happens if you don't dispose it?
5. A designer gives you a screen with light-grey text on white. What do you do?

## Bonus (optional)

- Move `lib/design_system/` into a separate local package, `packages/fund_ui`, and depend on it from the app.
- Add a "component gallery" debug screen showing every component in every state.
