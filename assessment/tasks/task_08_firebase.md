# Task 8: Firebase

**Goal:** Connect the app to Firebase so you can send push notifications that open the right screen, see crashes and usage in production, and turn features on or off without releasing a new version.

**Builds on:** Task 7 · **Time:** 2 hours

## What you're building

When the server (or you, from the Firebase console) sends a push notification like
*"Your Laptop goal is 90% complete!"*, tapping it opens that goal. Crashes and
unexpected errors show up in Crashlytics. Key actions show up in Analytics, but only
if the user agreed. You can hide the Summary tab, or force users to update, from
Remote Config.

> No Firebase account? Build everything behind interfaces with fake implementations,
> explain what the real setup needs, and tell me. The "Works" score is then capped at 3.

## Requirements

**Setup**
- [ ] Create a free Firebase project and connect the app with `flutterfire configure`.
- [ ] Put Firebase **behind your own interfaces** (`PushService`, `AnalyticsService`, `CrashReporter`, `RemoteConfigService`).
  Screens never import Firebase directly, and tests use fakes.

**Push notifications (FCM)**
- [ ] Before the system prompt, explain why the app wants to send notifications, then ask for permission.
- [ ] Notifications appear when the app is **open**, **in the background**, and **closed**.
- [ ] A notification with data `{"route": "/goals/g2"}` opens that goal when tapped, from any of those states.
  If the user is logged out, they log in first and then land on the goal.
- [ ] Log the device token and handle token refresh.

**Crash reporting (Crashlytics)**
- [ ] All uncaught Flutter and Dart errors are reported.
- [ ] Unexpected API errors are reported as **non-fatal**. Normal ones (wrong password, offline) are **not** reported.
- [ ] No personal data (email, names, exact amounts) in reports.
- [ ] A hidden "Test crash" button in debug builds.

**Analytics**
- [ ] Track screen views automatically.
- [ ] Log events: `login`, `goal_created`, `contribution_added` (send an amount **range**, like "10k–50k", not the exact amount).
- [ ] An analytics consent switch in Settings. **Nothing is sent before the user agrees.**

**Remote Config**
- [ ] `summary_tab_enabled`: hides or shows the Summary tab without a new release.
- [ ] `min_supported_version`: if the app is older, show a blocking **"Please update"** screen with a store link.
- [ ] Sensible defaults built into the app for when Remote Config can't be reached.

## Tests to write

- [ ] No analytics events before consent; events after consent.
- [ ] A wrong password is not reported as a crash, and an unexpected error is.
- [ ] Version check: `1.10.0` is newer than `1.9.9`; equal versions pass.
- [ ] Notification tap with a valid route → navigates; an invalid route → ignored safely.

## Skills this task shows

Firebase · push notifications · deep linking from notifications · analytics ·
crash reporting · remote configuration · privacy · third-party SDK integration.

## Questions (answer in `assessment/answers/task_08.md`)

1. How does a push notification travel from your server to an iPhone? What must be set up for iOS?
2. "Notification" messages vs "data" messages: how do they behave when the app is open, in the background, or closed?
3. Why must the background message handler be a top-level function?
4. Which numbers would you watch after a release (e.g. crash-free users), and what would make you stop the rollout?
5. What does Uganda's Data Protection and Privacy Act (or GDPR) mean for your analytics?
