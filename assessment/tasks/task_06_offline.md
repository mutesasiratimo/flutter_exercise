# Task 6: Offline mode

**Goal:** Make the app usable without internet: it keeps the user logged in securely, shows saved goals instantly, and queues contributions made offline so they sync later, without ever charging twice.

**Builds on:** Task 5 · **Time:** 3 hours

## What you're building

The user opens the app on a bus with no signal. They are still logged in, see their
goals (with "Updated 5 min ago"), and add a contribution, which shows as **"Pending
sync"**. When the signal returns, it syncs automatically, even if the app was closed
in between.

## Requirements

**Stay logged in, securely**
- [ ] Save the refresh token in **`flutter_secure_storage`**. Keep the access token in memory only.
- [ ] When the app opens: show a splash screen while restoring the session, then go to Goals (or Login if the session is invalid). Don't flash the wrong screen first.
- [ ] Logout deletes **everything**: tokens, cached data, and queued items.
- [ ] Theme and language settings are saved with `shared_preferences`.

**Show saved data first**
- [ ] Save goals and contributions in a **local database** (`drift` recommended).
- [ ] Screens read from the database. Data from the server is written to the database, and the screens update from there.
- [ ] On opening, show cached goals **immediately**, then refresh from the server in the background.
- [ ] Show "Updated 5 min ago" and an **offline banner** when there's no internet.

**Offline contributions**
- [ ] Adding a contribution offline:
  - saves it to a **sync queue** in the database (goal, amount, idempotency key, status, attempts)
  - updates the goal's amount on screen straight away, marked **"Pending sync"**
- [ ] The queue syncs automatically when the internet returns, when the app is reopened, and after login.
- [ ] Items sync **in order**, one at a time per goal.
- [ ] Temporary failures (no internet, 503) are retried later, waiting longer each time.
- [ ] Permanent failures (e.g. the goal was completed on another device) revert the amount and show the item with **Retry** / **Discard**.
- [ ] If the app is killed mid-sync, the next attempt reuses the **same idempotency key** (it is stored in the queue), so there is no double charge.
- [ ] A badge shows "2 contributions waiting to sync".

**Background sync (Android)**
- [ ] Use `workmanager` to sync the queue about every 15 minutes when online, even with the app closed.
- [ ] Show a local notification: "2 contributions synced".
- [ ] For iOS, write down what you would configure and what iOS limits.

## Tests to write

- [ ] Session restore: a valid stored token → Goals; an invalid one → Login.
- [ ] Database: saving goals updates the screen stream.
- [ ] Sync queue:
  - offline → queued; online → sent
  - a temporary failure is retried
  - a permanent failure reverts the amount
  - after a simulated restart, the same idempotency key is sent
  - order is kept per goal
- [ ] Logout clears storage and the database.

## Skills this task shows

Secure local storage · offline-first design · caching · synchronisation ·
background processing · error handling · data safety.

## Questions (answer in `assessment/answers/task_06.md`)

1. How does `flutter_secure_storage` keep data safe on Android and on iOS? What surprise happens with iOS Keychain data when the app is uninstalled?
2. Why must tokens never go in `shared_preferences`, a `.env` file, or `--dart-define`?
3. Why is the idempotency key stored **with** the queued contribution rather than created at send time?
4. The phone says it's on Wi-Fi, but there's no internet (a hotel login page). How does your app handle this?
5. What can and can't background work do on Android vs iOS?

## Bonus (optional)

- Encrypt the local database.
- Hide app content in the recent-apps screen (screenshot protection).
