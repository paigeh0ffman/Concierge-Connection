
markdown

# Concierge Connection 🩺
### by Team 404 Not Found

> *"404: Health data not found. We fixed that."*

A migraine tracking platform where patients log daily symptoms, AI detects patterns, and doctors are notified when something actually needs attention — reducing unnecessary appointments, wait times, and medical costs.

---

## The Problem

- The average US patient waits **26+ days** to see a doctor
- Most appointments exist just to "check in" — not because something is wrong
- Patients have no way to communicate symptom trends between visits
- Small problems become expensive ones because patterns go unnoticed

## Our Solution

Concierge Connection gives migraine patients a daily 2-minute check-in. An AI pattern detection layer watches for trends — pain escalation, frequent aura, extended duration — and flags them automatically. Doctors only get notified when the data says something is actually wrong.

**Track daily → Detect patterns → Flag when needed → Book only when necessary.**

---

## Features

### Patient Side
- **Daily migraine check-in** — pain level, time elapsed, aura, tinnitus, nausea, photosensitivity
- **Health score** — automatically calculated from each log entry
- **Home dashboard** — health score, symptom breakdown bars, pattern flags, recent notes
- **Reminders** — medication and symptom-logging reminders

### Doctor Side
- **Patient list** — view all linked patients
- **Patient dashboard** — health score, pain trend chart, avg pain/nausea/duration
- **AI pattern detection** — flags for severe pain streaks, extended duration, frequent aura
- **Patient notes** — all free-text notes from patient logs
- **Flag for appointment** — send a message directly to the patient when intervention is needed

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter (Dart) — iOS, Android, Web |
| Database | PostgreSQL via Supabase |
| Auth | Supabase Auth with role-based routing |
| AI/Pattern Logic | Custom Dart pattern detection engine |
| Charts | fl_chart |
| Security | Row Level Security (RLS) policies |

---

## Getting Started

### Prerequisites
- Flutter SDK installed
- Dart SDK
- A Supabase account (free tier works)

### Run the app

```bash
# Clone the repo
git clone https://github.com/paigeh0ffman/Concierge-Connection.git
cd Concierge-Connection

# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android
```

### Database Setup

Create a Supabase project and run the following SQL:

```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  full_name TEXT,
  role TEXT CHECK (role IN ('patient', 'doctor')),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  date DATE DEFAULT CURRENT_DATE,
  pain INTEGER,
  time_elapsed DECIMAL(4,1) DEFAULT 0,
  aura BOOLEAN DEFAULT false,
  tinnitus BOOLEAN DEFAULT false,
  nausea INTEGER DEFAULT 0,
  photosensitivity INTEGER DEFAULT 0,
  notes TEXT,
  health_score INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE doctor_patients (
  doctor_id UUID REFERENCES profiles(id),
  patient_id UUID REFERENCES profiles(id),
  PRIMARY KEY (doctor_id, patient_id)
);

CREATE TABLE flags (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  doctor_id UUID REFERENCES profiles(id),
  patient_id UUID REFERENCES profiles(id),
  message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE invites (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  doctor_id UUID REFERENCES profiles(id),
  patient_email TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);
```

Update `lib/main.dart` with your Supabase URL and anon key:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

---

## AI Pattern Detection

The pattern detection engine in `lib/services/insights.dart` analyzes the last 4 days of logs and surfaces flags:

```dart
// Red flags — appointment recommended
- Pain rated 7+ for 3 consecutive days
- Pain rose 3+ points in 4 days

// Yellow flags — monitor closely  
- Aura in 3+ of last 4 logs
- High nausea for 3+ days
- 2+ migraines lasting 24+ hours
```

The health score is calculated per log:

```dart
score = 100
  - (pain × 6)
  - (nausea × 3)
  - (photosensitivity × 3)
  - (aura ? 10 : 0)
  - (tinnitus ? 5 : 0)
```

---

## Project Structure

```
lib/
  pages/
    doctor/
      DoctorHomePage.dart    — patient list + invite flow
      DoctorTracker.dart     — patient dashboard with charts
      DoctorChat.dart        — messaging
    patient/
      PatientHomePage.dart   — insights dashboard
      PatientTracker.dart    — daily migraine check-in
      PatientChat.dart       — messaging
    LoginPage.dart           — auth with role-based routing
  services/
    data_service.dart        — all Supabase fetch/save functions
    insights.dart            — AI pattern detection engine
  widgets/
    NavBar.dart              — bottom navigation
  main.dart                  — app entry + Supabase init
```

---

## Security

- Row Level Security (RLS) enabled on all tables
- Patients can only read and write their own logs
- Doctors can only read logs of their linked patients
- Role-based routing — doctor and patient see different dashboards after login

---

## Future Roadmap

| Phase | Feature |
|---|---|
| v1.1 | Push notifications for medication reminders |
| v1.2 | Wearable sync (Apple Health, Fitbit) |
| v2.0 | ML-based pattern detection replacing rule-based flags |
| v2.1 | Expand beyond migraines to other chronic conditions |
| v2.2 | Insurance integration — share summaries with providers |
| v3.0 | Subscription model — $20/month replaces routine check-in visits |

---

## Business Model

Concierge Connection operates on a **subscription model** rather than per-appointment billing.

- **Patient plan** — $20/month for continuous monitoring
- **Clinic plan** — per-patient licensing for healthcare providers
- **Impact** — one prevented unnecessary appointment pays for 6+ months of subscription

The average US doctor visit costs $300+. Concierge Connection targets the visits that didn't need to happen.

---

## Team 404 Not Found

| Name | Role | Skills |
|---|---|---|
| **Dhwani** | Data & AI lead | Python, SQL, Scikit-learn, Tableau, Dart |
| **Paige** | Frontend lead | Flutter, React, Python, Java |
| **Saikal** | Design | Figma, Python, Java |
| **Faraz** | Security lead | Cybersecurity, auth, privacy |

**Hackathon:** HackAugie
**Track:** Healthcare / AI
**Team name:** 404 Not Found

---

