# 🏗️ Construction Field Manager

A **full-fledged, scalable Flutter ERP application** built using **modern industry best practices** for managing projects, workers, and tasks in real-world construction workflows.

This app supports:
- Offline-first functionality
- Custom role-based access (RBAC)
- OTP-based authentication
- Multilingual interface
- Real-time notifications via backend webhooks

> ⚙️ Backend stack: **Node.js + PostgreSQL + Prisma** (handled by a separate backend team).  
> This repository focuses exclusively on **Flutter development**.

---

## 🧠 Technology Stack

| Service / Feature        | Technology Used                |
| ------------------------- | ------------------------------ |
| **State Management**      | Riverpod                       |
| **Networking**            | Dio                            |
| **Offline Database**      | Drift (SQLite)                 |
| **Authentication / OTP**  | Twilio Verify API              |
| **Localization**          | easy_localization + intl       |
| **Connectivity Detection**| connectivity_plus              |
| **Secure Storage**        | flutter_secure_storage         |
| **Charts / Reports**      | fl_chart / syncfusion          |
| **Notifications**         | Backend Webhooks + Polling     |

---

## 📂 Folder Structure
<img width="468" height="666" alt="image" src="https://github.com/user-attachments/assets/6e1f3a26-d434-48fe-8c18-59544cb6d7be" />


---

## 🧩 Core Modules

### 📌 Project & Task Management

**Purpose:**  
Centralized control for projects, tasks, and worker assignments.

#### Workflow
**Admin / Manager**
- Create projects  
- Define tasks  
- Assign workers / managers  

**Worker**
- View assigned tasks  
- Update task status  

**System**
- Track progress  
- Feed dashboard KPIs  

#### Approach
- Project & Task tables implemented in **Drift** (mirroring **Prisma** models).  
- Status flow: `Pending → In Progress → Complete`.  
- Offline updates queued and auto-synced when online.

---

## 🔐 Role & Permission System (RBAC)

### Permission-Based Access (No Hardcoded Roles)

#### Workflow
- Admin creates **custom roles** dynamically via UI.  
- Admin selects allowed services/features.  
- Backend sends permissions during login.


#### Flutter Behavior
- Same screens reused across all user roles.  
- UI, actions, and routes are **permission-guarded**.  
- Permissions cached locally for **offline access**.

---

## 💾 Offline Support Strategy

### Local Database
- Built on **Drift (SQLite)**, mirroring PostgreSQL + Prisma models.  
- Supports **relations, joins, and column migrations**.

### Offline Flow
1. Read & write data locally.  
2. Mark unsynced records with `syncPending`.  
3. Queue API updates while offline.  
4. Auto-sync on connectivity restoration.  
5. Backend resolves data conflicts using timestamps.

---

## 🔔 Notifications

- Backend emits event-based updates (approvals, alerts, task changes).  
- Flutter retrieves notifications via **polling APIs**.  
- All notifications are **stored locally** for offline visibility.  
- Shown via a **built-in notification center**.

---

## 🌍 Localization

- Integrated using **easy_localization** + **intl**.  
- JSON-based translation files for scalable i18n.  
- Supports **runtime language switching**.

---

## 🚀 Summary

A modular and production-ready **Flutter ERP** solution designed for the construction industry.  
With powerful **offline capabilities**, **flexible permissions**, and **clean architecture**, this project provides a future-ready foundation for enterprise-grade mobile systems.

---

### 🧩 Contributors
- **Frontend (Flutter)**: Your Team  
- **Backend (Node.js, Prisma)**: Partner Team  

---

> Built using Flutter & Riverpod.
