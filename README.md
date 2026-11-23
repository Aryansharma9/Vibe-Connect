# 💖 VibeConnect

> **"Meet through moments, not swipes."**  
> A college-first, moments-based dating & connection app designed for students across Greater Noida and Noida campuses — completely free with zero paywalls.

Flagship Launch Campus: **Lloyd Institute of Engineering and Technology (LIET), Knowledge Park II, Greater Noida** 🎓

---

## 🌟 What Makes VibeConnect Different?

* **No Mindless Swipes:** Connection requests are tied to genuine answers and shared interests with an attached personal note (up to 140 chars).
* **The Daily Moment:** A daily question drops every day. You only see peer responses after you post your own answer (reciprocal unlock).
* **Verified Student Badges:** Anti-scam verification using institutional college emails (`@lloydcollege.in`, `@bennett.edu.in`, `@amity.edu`, etc.).
* **Hyper-Local Campus Scoping:** Toggle between **"My Campus Only"** and the **"Greater Noida Hub"** (Knowledge Park & Noida colleges).
* **100% Free Forever:** Core messaging and matching features are free for college students.

---

## 🏗️ System Architecture & Tech Stack

```
VibeConnect/
├── backend/          # Java 21 + Spring Boot 3.3.5 REST & WebSocket APIs
├── mobile/           # Flutter 3.x Cross-Platform Client (Riverpod + GoRouter)
└── docker-compose.yml# PostgreSQL 16 & Redis 7 services
```

* **Backend:** Java 21, Spring Boot 3.3+, Spring Data JPA, Spring Security (JWT), Flyway migrations, Spring WebSocket (STOMP).
* **Mobile Client:** Flutter 3.24+, Dart, Riverpod 2.x, Dio HTTP Client, GoRouter.
* **Databases & Cache:** PostgreSQL 16 (port `5433`), Redis 7 (port `6379`).
* **Containerization:** Docker & Docker Compose.

---

## 🚀 Quickstart Guide for Collaborators

Follow these 4 simple steps to run the complete app locally on your machine.

### Prerequisites

Ensure you have the following installed:
1. [Git](https://git-scm.com/)
2. [Docker Desktop](https://www.docker.com/products/docker-desktop/) (start the engine)
3. [Java 21 (Temurin / OpenJDK)](https://adoptium.net/)
4. [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) (added to your system PATH)

---

### Step 1: Clone the Repository
```bash
git clone https://github.com/Aryansharma9/Vibe-Connect.git
cd Vibe-Connect
```

---

### Step 2: Start PostgreSQL & Redis
Make sure Docker Desktop is open and running, then start the containers:
```bash
docker compose up -d
```
* **PostgreSQL** runs on `localhost:5433` (DB: `vibeconnect`, user: `vibeuser`, pass: `vibepassword`).
* **Redis** runs on `localhost:6379`.

---

### Step 3: Run the Spring Boot Backend
```bash
cd backend
# On Windows (PowerShell/CMD):
.\mvnw spring-boot:run

# On macOS/Linux:
./mvnw spring-boot:run
```
* The backend will automatically apply Flyway migrations, create all tables, and pre-seed Greater Noida colleges with **LIET** at the top.
* Server will be live at: `http://localhost:8080`

---

### Step 4: Run the Flutter Mobile App
Open a **new terminal tab** and run:
```bash
cd mobile
flutter pub get

# Run live in Google Chrome (fastest for UI development):
flutter run -d chrome
```

> 💡 **Mobile View in Chrome:** Press `F12` in Chrome, then press `Ctrl + Shift + M` (or click the device toggle icon) and select **iPhone 14 Pro** or **Pixel 7** to preview the exact phone dimensions.

---

## 📡 API Overview (Phase 1)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/colleges` | Lists Greater Noida campuses (LIET prioritized first) |
| `POST` | `/api/v1/auth/phone/otp` | Request 6-digit phone login OTP (dev code returned in response) |
| `POST` | `/api/v1/auth/phone/verify` | Verify OTP, create student profile, and receive JWT |
| `POST` | `/api/v1/auth/college-email/otp` | Send verification code to student college email (`@lloydcollege.in`) |
| `POST` | `/api/v1/auth/college-email/verify`| Activate **Verified Student Badge** |
| `GET` | `/api/v1/auth/me` | Fetch authenticated student profile |

---

## 🗺️ Project Roadmap

- [x] **Phase 0:** Project scaffolding, Docker Compose, Flyway, Maven & Flutter setups.
- [x] **Phase 1:** Phone OTP Auth, Greater Noida college catalog, LIET email verification badge.
- [x] **Phase 2:** Daily moments question engine & reciprocal answer feed.
- [x] **Phase 3:** Intentional connection requests with 140-char custom notes.
- [ ] **Phase 4:** Real-time 1-on-1 WebSocket chat (STOMP) & safety controls.
- [ ] **Phase 5:** Themed interest spaces & campus closed beta rollout at LIET.

---

## 👥 Contributors
* **Aryan Sharma** ([@Aryansharma9](https://github.com/Aryansharma9))
* Co-contributors & Campus Ambassadors welcome!
