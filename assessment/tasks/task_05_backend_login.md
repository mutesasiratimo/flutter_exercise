# Task 5: Backend & login

**Goal:** Connect the app to the FlutterFund REST API: users log in, goals are loaded and saved on the server, sessions refresh automatically, and every error is handled cleanly.

**Builds on:** Task 4 · **Time:** 3 hours

## What you're building

A **login screen**. After logging in, the goals come from the server, 20 at a time
as the user scrolls, with a **search box**. Creating goals and adding contributions
save to the server. When the session expires, the app renews it silently, and when
something fails the user sees a clear message.

## The backend

Start the mock server (it's already in the project):

```bash
dart run assessment/mock_server/server.dart --token-ttl=20 --failure-rate=0.1
```

- Login: `demo@flutterfund.test` / `Passw0rd!`
- Android emulator URL: `http://10.0.2.2:8080`. On a real phone, use your computer's local IP.
- `--token-ttl=20` makes the login token expire after 20 seconds, so you can test auto-refresh.
- `--failure-rate=0.1` makes 10% of requests fail with a 503, so you can test error handling.

| Action | Request | Response |
|---|---|---|
| Log in | `POST /v1/auth/login` `{"email","password"}` | `{"accessToken","refreshToken","expiresIn","user"}` |
| Refresh session | `POST /v1/auth/refresh` `{"refreshToken"}` | New tokens. **Each refresh token works only once.** |
| Log out | `POST /v1/auth/logout` | 204 |
| List goals | `GET /v1/goals?page=1&pageSize=20&q=laptop` | `{"data":[…],"page","total","hasMore"}` |
| One goal | `GET /v1/goals/{id}` | The goal, or 404 |
| Create goal | `POST /v1/goals` `{"title","target":{"amountMinor","currency"},"deadline"}` | 201, or 422 with field errors |
| Contribute | `POST /v1/goals/{id}/contributions` + header `Idempotency-Key: <uuid>`, body `{"amount":{"amountMinor","currency"}}` | 201. Sending the same key again returns the same result without charging twice |
| History | `GET /v1/goals/{id}/contributions` | `{"data":[…]}` |

Every request except login and refresh needs the header `Authorization: Bearer <accessToken>`.
An expired token returns `401` with `{"error":{"code":"token_expired"}}`.
All errors look like `{"error":{"code","message","fields"?}}`.

## Requirements

**Login**
- [ ] A login screen with email and password validation, a loading state, and server messages ("Email or password is incorrect").
- [ ] Logged-out users are sent to login. After login, the user returns to where they were heading.
- [ ] Logout in Settings.

**API connection**
- [ ] Use `dio` or `http`. The server URL is passed in with `--dart-define=API_BASE_URL=…`.
- [ ] Debug logs of requests **hide tokens and passwords**.
- [ ] Add an `ApiGoalsRepository`. Switching from the in-memory repository to it is a change in **one place only** (your DI setup).

**Goals list**
- [ ] **Infinite scroll:** load 20 goals, then load the next page near the bottom, with a spinner at the end and a "Retry" button if a page fails.
- [ ] **Search box:** only searches after the user stops typing for about 350 ms.
  Older results must never replace newer ones.
- [ ] Pull-to-refresh starts again from page 1.

**Contributions**
- [ ] Each contribution sends an `Idempotency-Key` (a UUID). If the request is retried,
  it uses the **same** key, so the user is never charged twice.

**Session refresh**
- [ ] When a request gets `token_expired`, the app refreshes the token and retries the request. The user notices nothing.
- [ ] If **several** requests expire at the same time, only **one** refresh call is made.
- [ ] If the refresh fails, the user is logged out and sent to the login screen.

**Error handling**
- [ ] Friendly messages for: no internet, session expired, not found, invalid input
  (shown **next to the right form field**), and server error.
- [ ] Loading data (GET) automatically retries up to 3 times, waiting longer each time, on network errors and 503s.

## Tests to write

- [ ] Repository tests with a mocked HTTP client: goals parse correctly; 404 → not found; 422 → field errors.
- [ ] **Three requests fail with `token_expired` at the same time → exactly one refresh call**, and all three succeed.
- [ ] A failed refresh logs the user out.
- [ ] A retried contribution sends the same `Idempotency-Key`.
- [ ] Search: a slow old response doesn't overwrite a newer one.
- [ ] Paging: the next page is appended, and scrolling fast doesn't load the same page twice.

## Skills this task shows

REST API integration · authentication and authorisation · token refresh ·
error handling · async programming (debounce, cancellation, retries) ·
safe payments (idempotency) · environment configuration.

## Questions (answer in `assessment/answers/task_05.md`)

1. What is an idempotency key, and what happens without one if the network drops right after the server saves a contribution?
2. How should a mobile app log in with OAuth 2.0 (Authorization Code + PKCE)? Why must the app never contain a client secret?
3. Where should the access token and refresh token be kept, and why?
4. What's inside a JWT? Why shouldn't the app trust it to decide what the user is allowed to do?
5. What is certificate pinning? What's the risk of using it?

## Bonus (optional)

- Parse large responses on a background isolate.
- Handle `429 Too Many Requests` using the `Retry-After` header.
