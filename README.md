# 💖 VibeConnect

> **"Meet through moments, not swipes."**  
> A college-first, moments-based dating & connection app designed for students across Greater Noida and Noida campuses — completely free with zero paywalls.

Flagship Launch Campus: **Lloyd Institute of Engineering and Technology (LIET), Knowledge Park II, Greater Noida** 🎓

---

## 🌟 What Makes VibeConnect Different?

* **No Mindless Swipes:** Connection requests are tied to genuine answers and shared interests with an attached personal note (up to 140 chars).
* **The Daily Moment:** A daily question drops every day at 12:00 PM. You only see peer responses after you post your own answer (strict reciprocal unlock).
* **Themed Campus Spaces:** Connect in targeted communities:
  * 💻 **Coding & Hackathons** (LIET & Gr. Noida devs, leetcode grinders & hackathon squads)
  * 🏋️ **Gym & Fitness** (Workout partners, PR checks & morning runs at Knowledge Park)
  * 🎧 **Indie & Live Music** (Spotify blend swaps, concert buddies & jamming sessions)
  * 🎮 **Gaming & Esports** (Valorant 5-stacks, BGMI custom rooms & Steam co-op)
  * 📚 **Books & Cafe Crawls** (Exploring Sector 104 Noida cafes & peaceful library corners)
  * 🍕 **Late Night Foodies** (Paratha corners, Maggi points & highway late-night chai runs)
* **Verified Student Badges:** Anti-scam verification using institutional college emails (`@lloydcollege.in`, `@bennett.edu.in`, `@amity.edu`, etc.).
* **Hyper-Local Campus Scoping:** Toggle between **"My Campus Only (LIET)"** and the **"Greater Noida Hub"** (Knowledge Park & Noida colleges).
* **Campus Safety First:** Instant student report & block controls on moments, spaces, and private 1-on-1 chats.
* **100% Free Forever:** Core messaging and matching features are completely free with no paywalls or coin systems.

---

## 🏗️ System Architecture & Tech Stack

```
VibeConnect/
├── backend/          # Java 21 + Spring Boot 3.3.5 REST & WebSocket APIs
├── mobile/           # Flutter 3.x Cross-Platform Client (Riverpod + GoRouter)
└── docker-compose.yml# PostgreSQL 16 & Redis 7 services
```

* **Backend:** Java 21, Spring Boot 3.3.5, Spring Data JPA, Spring Security (JWT), Flyway migrations (`V1` - `V5`), Spring WebSocket (STOMP).
* **Mobile Client:** Flutter 3.24+, Dart 3.5+, Riverpod 2.x, Dio HTTP Client, GoRouter, Google Fonts (Plus Jakarta Sans).
* **Databases & Cache:** PostgreSQL 16 (port `5433:5432`), Redis 7 (port `6379`).
* **Containerization:** Docker & Docker Compose.

---

## 📱 Mobile App Navigation (4 Shell Tabs)

The Flutter mobile application features a persistent bottom navigation shell:
1. **🔥 Moments:** Daily Drop card, answer composer, reciprocal campus feed unlock, campus scope toggle (LIET vs Greater Noida), and dating intent filters.
2. **👥 Spaces:** 6 curated Greater Noida & LIET themed interest communities with real-time thought feeds, post creator, and note connection triggers.
3. **💬 Inbox:** Real-time badge counter for incoming connection requests (with 140-char icebreaker notes), accept/decline actions, and unlocked 1-on-1 chat threads.
4. **👤 Profile:** Student profile card with college identity, `@lloydcollege.in` verification badge, dating intent tag, safety guidelines, and account switch.

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
* The backend will automatically apply Flyway migrations (`V1` to `V5`), create all tables, and pre-seed Greater Noida colleges, daily questions, sample moments, and themed spaces.
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

## 📡 API Overview

### 1. Auth & Campus Verification
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/colleges` | Lists Greater Noida campuses (LIET prioritized first) |
| `POST` | `/api/v1/auth/phone/otp` | Request 6-digit phone login OTP (dev code returned in response) |
| `POST` | `/api/v1/auth/phone/verify` | Verify OTP and start student registration |
| `POST` | `/api/v1/auth/register` | Finalize profile creation and receive session |
| `POST` | `/api/v1/auth/college-email/otp` | Send verification code to student college email (`@lloydcollege.in`) |
| `POST` | `/api/v1/auth/college-email/verify`| Activate **Verified Student Badge** |
| `GET` | `/api/v1/auth/me` | Fetch authenticated student profile |

### 2. Daily Moments Engine
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/prompts/today` | Fetch today's prompt and answers (feed locked until you answer) |
| `POST` | `/api/v1/prompts/answer` | Post your answer to unlock the reciprocal campus feed |

### 3. Intentional Connections & Requests
| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/v1/connections/send` | Send connection request with up to 140-char custom note |
| `GET` | `/api/v1/connections/incoming` | View pending connection requests with context and notes |
| `GET` | `/api/v1/connections/count` | Get count of unreviewed pending requests |
| `POST` | `/api/v1/connections/respond` | Accept (creates match & unlocks chat) or decline request |
| `GET` | `/api/v1/connections/conversations` | Get all active matches and chat threads |

### 4. Real-time 1-on-1 Chat
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/chat/{convId}/messages` | Get message history for conversation |
| `POST` | `/api/v1/chat/{convId}/messages` | Send message (also broadcasts over WebSocket) |
| `WS` | `/ws` (STOMP) | Real-time WebSocket pub/sub for messages |

### 5. Campus Spaces & Community Moderation
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/spaces` | Get all 6 curated campus interest spaces |
| `GET` | `/api/v1/spaces/{spaceId}/posts` | Get posts inside a specific campus space |
| `POST` | `/api/v1/spaces/{spaceId}/posts` | Publish a thought / invite to a campus space |
| `POST` | `/api/v1/moderation/report` | Report user (harassment, scam, fake student profile, etc.) |
| `POST` | `/api/v1/moderation/block` | Immediately block user (hides profile, posts & messages) |

---

## 🗺️ Project Roadmap

- [x] **Phase 0:** Project scaffolding, Docker Compose (Postgres on `5433`, Redis on `6379`), Flyway, Maven & Flutter setups.
- [x] **Phase 1:** Phone OTP Auth, Greater Noida college catalog (LIET flagship), `@lloydcollege.in` verification badge.
- [x] **Phase 2:** Daily moments question engine & reciprocal answer feed with campus/vibe filters.
- [x] **Phase 3:** Intentional connection requests with 140-char custom notes & mutual matching.
- [x] **Phase 4:** Real-time 1-on-1 chat with STOMP WebSockets and polling fallback.
- [x] **Phase 5:** Themed interest spaces (Tech, Fitness, Music, Gaming, Books, Food), safety moderation & bottom navigation.

---

## 👥 Contributors
* **Aryan Sharma** ([@Aryansharma9](https://github.com/Aryansharma9))
* Co-contributors & Campus Ambassadors welcome!
