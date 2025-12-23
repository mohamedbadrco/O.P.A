# Over Power Assistant (O.P.A) — AI Calendar Assistant 📅🤖

**Over Power Assistant (O.P.A)** is an AI-powered calendar and ai assistant  app that helps you organize your schedule, suggest optimizations, and provide concise summaries of your upcoming events. O.P.A integrates directly with your calendar to give smart recommendations, summarize meetings, and answer scheduling questions while still offering Day / Week / Month views, local persistence, and notifications.

---


---

## 🔧 Key Features

- **AI-powered assistant (Over Power Assistant / O.P.A)** that integrates with your calendar to:
  - Suggest schedule optimizations (best meeting times, time-blocking, conflict resolution)
  - Generate concise summaries and meeting highlights (daily briefings, meeting recaps)
  - Answer natural-language scheduling queries and give actionable recommendations
  - Propose rescheduling options and draft suggested updates to events
  - Prioritize tasks and provide focus recommendations based on your day
- Day / Week / Month views for easy navigation
- Create, edit, and delete events with full details and reminders
- Local notifications for scheduled events (`lib/notification_service.dart`)
- Persistent local storage using a database helper (`lib/database_helper.dart`)
- Event details and add-event flows (`lib/event_details_page.dart`, `lib/add_event_page.dart`)
- Assistant page to access AI features (`lib/assistant_page.dart`)
- Navigation drawer and UI helpers (e.g., `lib/app_drawer.dart`, `lib/weekend_days.dart`)

---

## 🔁 Quick start

1. Install Flutter (stable channel): https://flutter.dev/docs/get-started/install
2. From the project root, fetch dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app on a connected device or emulator:

   ```bash
   flutter run -d <device-id>
   ```

4. To run tests:

   ```bash
   flutter test
   ```

---

## 📁 Project structure (important files)

- `lib/main.dart` — app entry point
- `lib/add_event_page.dart` — UI to create events
- `lib/event_details_page.dart` — event details and edit
- `lib/database_helper.dart` — local database operations
- `lib/notification_service.dart` — notification scheduling
- `lib/assistant_page.dart` — scheduling assistant
- `lib/app_drawer.dart` — main app navigation

---

## 🛠 Development notes

- Database migrations and schema changes are handled in `lib/database_helper.dart`.
- Notifications are scheduled via `lib/notification_service.dart` — remember to request notification permissions on platforms that require it.
- Add platform-specific setup (Android/iOS) for notifications and permissions if you extend or publish the app.

---

## ✅ How to contribute

1. Fork the repo and create a feature branch: `git checkout -b feat/your-feature`
2. Make changes, add tests, and run `flutter test`
3. Open a pull request with a clear description of your changes

Please follow the project's code style and add tests for new behavior.

---


## 📜 License

This project can be licensed under the **MIT License**. Add a `LICENSE` file if you choose to use MIT.

---

## ✉️ Contact / Authors

- Your Name — your.email@example.com

---

If you'd like, I can also:

- Add badges (CI, license, Flutter version),
- Insert example screenshots, or
- Open a PR that updates README directly in your repo.

Let me know which of the above you'd like next! ✅
