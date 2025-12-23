# Over Power Assistant (O.P.A) — AI Calendar Assistant 📅🤖

**Over Power Assistant (O.P.A)** is an AI-powered calendar and scheduling assistant that helps you organize your day, suggest optimal meeting times, summarize events, and answer scheduling questions in natural language. It integrates directly with your calendar while providing Day / Week / Month views, local persistence, and notifications.

---

## 🚀 Quick overview

- Platforms: Android, iOS, macOS, Web, Windows, Linux (where Flutter is supported)
- Core idea: combine a familiar calendar UI with an AI assistant (O.P.A) to make scheduling faster and less stressful.

---

## 🔧 Key features

- **AI assistant — Over Power Assistant (O.P.A)** (`lib/assistant_page.dart`)
  - Suggests schedule optimizations (best meeting times, conflict resolution, time-blocking)
  - Generates concise summaries and meeting highlights (daily briefings, meeting recaps)
  - Answers natural-language scheduling queries and provides actionable recommendations
  - Proposes rescheduling options and can draft suggested updates to events
  - Prioritizes tasks and offers focus recommendations based on your day
- Day / Week / Month views for easy navigation
- Create, edit, and delete events with full details and reminders
- Local notifications for scheduled events (`lib/notification_service.dart`)
- Persistent local storage using a database helper (`lib/database_helper.dart`)
- Event details and add-event flows (`lib/event_details_page.dart`, `lib/add_event_page.dart`)
- Navigation drawer and UI helpers (`lib/app_drawer.dart`, `lib/weekend_days.dart`)

---

## 🔁 Quick start

1. Install Flutter (stable channel): https://flutter.dev/docs/get-started/install
2. From the project root:

```bash
flutter pub get
```

3. Run the app on a connected device or emulator:

```bash
flutter run -d <device-id>
```

4. Run tests:

```bash
flutter test
```

---

## 🗂 Project structure (important files)

- `lib/main.dart` — app entry point
- `lib/add_event_page.dart` — UI to create events
- `lib/event_details_page.dart` — event details and edit
- `lib/database_helper.dart` — local database operations
- `lib/notification_service.dart` — notification scheduling
- `lib/assistant_page.dart` — scheduling assistant (AI features)
- `lib/app_drawer.dart` — app navigation

---

## 🔐 Privacy & data

- O.P.A uses only the calendar data necessary to provide scheduling recommendations and summaries.
- The app can be configured to process AI tasks **on-device** where feasible; if cloud-based processing is added later, explicit consent and clear configuration will be required.
- No calendar data is shared externally by default. Add a clear privacy policy before publishing if you integrate third-party AI services.

---

## 🛠 Development notes

- Database schema and migrations are managed in `lib/database_helper.dart`.
- Notifications are scheduled via `lib/notification_service.dart`; ensure platform-specific permissions are requested (Android/iOS).
- The assistant logic is concentrated in `lib/assistant_page.dart` — expand or replace the implementation to connect to your chosen AI backend.

---

## ✅ Contributing

1. Fork the repo and create a branch: `git checkout -b feat/your-feature`
2. Make changes, add tests, and run `flutter test`
3. Open a pull request with a clear description and screenshots if applicable

Please follow existing code style and add tests for new behavior.

---

## 📸 Screenshots

Add screenshots to `assets/` and reference them here to showcase Day/Week/Month views and the assistant UI.

> Example:
> ![Screenshot](assets/screenshot.png)

---

## 📜 License

This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International (**CC BY‑NC 4.0**). See `LICENSE` for full terms.

**Commercial use is prohibited** without explicit permission — contact the author if you need a commercial license.

> Note: CC licenses are commonly used for content (docs, images). If you want a software-specific non-commercial license (or a proprietary "all rights reserved" approach) for the code itself, consider PolyForm Noncommercial or a custom proprietary license and consult legal counsel.

---

## ✉️ Contact

- Mohamed badr mo
- Email: mohamedbadrco@gmail.com
- GitHub: [@mohamedbadrco](https://github.com/mohamedbadrco)

