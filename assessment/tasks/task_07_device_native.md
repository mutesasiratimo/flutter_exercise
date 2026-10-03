# Task 7: Device features & native code

**Goal:** Add features that use the phone itself (a fingerprint/Face ID lock, goal photos from the camera, and deadline reminders), add a small native Kotlin/Swift integration, and keep the app smooth while doing heavy work.

**Builds on:** Task 6 · **Time:** 2–3 hours

## What you're building

The app locks when the user leaves it and unlocks with a fingerprint or Face ID.
Each goal can have a cover photo taken with the camera. The user gets a reminder 3
days before a goal's deadline, and tapping it opens that goal. Settings warns if the
phone has no screen lock (checked with native code). Importing a large demo file
doesn't freeze the app.

## Requirements

**Biometric lock**
- [ ] Ask for fingerprint / Face ID (`local_auth`) when the app opens and when it returns after **more than 60 seconds** in the background (use `AppLifecycleListener`).
- [ ] Fall back to the device PIN if biometrics fail or aren't set up.
- [ ] An on/off switch in Settings.

**Goal photos**
- [ ] Add or change a goal's cover photo from the **camera or gallery** (`image_picker`).
- [ ] If permission is denied, explain why it's needed. If it's permanently denied, show an **"Open settings"** button.
- [ ] Resize the photo before saving it (not full camera resolution).
- [ ] The list shows small thumbnails (use `cacheWidth` so full-size images aren't loaded into memory).

**Reminders**
- [ ] Schedule a local notification **3 days before** each goal's deadline.
- [ ] Tapping the notification opens that goal (reuse your deep-link routes).
- [ ] Cancel or reschedule the reminder when the goal is edited, completed, or deleted.

**Native code (platform channel)**
- [ ] A `MethodChannel` named `flutterfund/device` with:
  - **Kotlin (Android):** `isDeviceSecure` (is a screen lock set?) and `getBatteryLevel`
  - **Swift (iOS):** the same two methods. Write them even if you can't build for iOS.
- [ ] Settings shows *"Your phone has no screen lock. We recommend setting one."* when relevant.
- [ ] Errors from native code are handled (no crash).

**Heavy work without freezing**
- [ ] A Settings → "Import demo data" button that loads a **20,000-goal JSON file** (generate it yourself).
- [ ] Parse it on a **background isolate** (`Isolate.run`). A spinner keeps spinning smoothly the whole time.

**Choose one more (optional but valuable)**
- [ ] A map of "nearby savings agents" using the user's location, or
- [ ] A **mock mobile-money payment**: start payment → "Waiting for approval…" → success / failed / timed out.

## Tests to write

- [ ] The lock appears after more than 60 s in the background and not after 10 s (simulate lifecycle changes in a widget test).
- [ ] Platform channel: a mocked native reply shows the warning; a native error doesn't crash.
- [ ] Isolate parsing returns the same result as normal parsing.
- [ ] Reminder scheduling: editing the deadline reschedules it; deleting the goal cancels it (using a fake notification service).

## Skills this task shows

App lifecycle · isolates · platform channels · Kotlin and Swift · permissions ·
biometric authentication · camera · local notifications · image memory.

## Questions (answer in `assessment/answers/task_07.md`)

1. What does this print, and why?
   ```dart
   void main() {
     print('A');
     Future(() => print('B'));
     scheduleMicrotask(() => print('C'));
     Future.value(1).then((_) => print('D'));
     print('E');
   }
   ```
2. What is an isolate, and how is it different from a thread? When is `Isolate.run` not worth using?
3. How does a platform channel work? When would you use Pigeon or FFI instead?
4. What's the difference between "denied" and "permanently denied" permissions, and how must the app handle each?
5. Name three things that behave differently on Android and iOS that you had to handle.

## Bonus (optional)

- Replace the hand-written channel with **Pigeon**.
- Stream battery changes with an `EventChannel`.
