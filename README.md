# Smart Study Planner & Exam Preparation Tracker

A beautifully designed, offline-first Flutter application that helps students plan subjects, schedule study sessions, track syllabus completion, and analyze preparation progress.

---

## 📸 Screenshots

Please save your screenshots in an `assets/screenshots/` folder (you can create this folder in your project root) and replace the placeholder paths below with your actual screenshot filenames (e.g., `assets/screenshots/dashboard.png`).

<div align="center">
  
### 1. Dashboard Screen
Provides a high-level overview of total subjects, completed topics, pending tasks, daily study progress, and suggests the next topic to study based on a priority algorithm.

<img src="assets/screenshots/dashboard_screen.png" width="300" alt="Dashboard Screen">

---

### 2. Subject & Topic Management
Allows users to add, edit, and manage their subjects and respective topics. Includes visual completion bars for each subject.

<img src="assets/screenshots/subject_management_screen.png" width="300" alt="Subject Management Screen">
<img src="assets/screenshots/topic_management_screen.png" width="300" alt="Topic Management Screen">

---

### 3. Study Scheduling
A calendar and timeline view to schedule study sessions with dates, times, and durations. Prevent overlaps and track daily goals.

<img src="assets/screenshots/study_scheduling_screen.png" width="300" alt="Study Scheduling Screen">

---

### 4. Progress Tracking
Detailed analytics screen showing topic status distribution (Donut Chart) and subject-wise completion rates to easily identify subjects needing attention.

<img src="assets/screenshots/progress_screen.png" width="300" alt="Progress Screen">

---

### 5. Search & Filter
Quickly find topics using real-time text search and filter by subject or completion status.

<img src="assets/screenshots/search_filter_screen.png" width="300" alt="Search and Filter Screen">

</div>

---

## ✨ Features
* **Offline-First Storage**: Uses Hive NoSQL database so the app works flawlessly without the internet.
* **Smart Priority Logic**: Automatically highlights subjects with the lowest completion percentage and recommends topics.
* **Interactive UI**: Dark glassmorphism theme with fluid animations and fl_chart visualizations.
* **Modular Architecture**: Built using Provider state management.

## 🛠️ Tech Stack
* **Framework**: Flutter
* **State Management**: Provider
* **Local Database**: Hive
* **Charts**: fl_chart
* **Calendar**: table_calendar
