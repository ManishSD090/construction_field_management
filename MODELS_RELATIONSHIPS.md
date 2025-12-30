# Models Relationship Map

## Core Relationships Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    SYSTEM INFRASTRUCTURE                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │   Enums      │  │ Permission   │  │   Role               │  │
│  │ (12 types)   │──│  (codes)     │──│ (System + Custom)    │  │
│  └──────────────┘  └──────────────┘  └──────┬───────────────┘  │
│                                              │                   │
│                                              │ RolePermission    │
│                                              │                   │
└──────────────────────────────────────────────┼───────────────────┘
                                               │
                                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                   IDENTITY & TENANCY                            │
│  ┌──────────────┐         ┌──────────────┐                      │
│  │    User      │◄────┬───│   Company    │                      │
│  │  + Settings  │     │   │ + Settings   │                      │
│  │  (40+ props) │     │   │              │                      │
│  └──┬───────────┘     │   └──────────────┘                      │
│     │                 │                                          │
│     │                 └───► Has Role ──► Has Permissions        │
│     │                                                            │
│     └────► Created By (User) ──► Self Relation                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
  │
  │ companyId
  ▼
┌─────────────────────────────────────────────────────────────────┐
│                 OPERATIONS & MANAGEMENT                         │
│                                                                  │
│  ┌─────────────────┐      ┌──────────────┐    ┌─────────────┐  │
│  │    Project      │◄────┐│   Client     │    │ Milestone   │  │
│  │ + Settings      │     ││              │    │             │  │
│  │ (Geofenced)     │     │└──────────────┘    └─────────────┘  │
│  └────┬────────────┘     │                                      │
│       │                  │                                      │
│       ├──►Project Settings (CheckIn/Out times)                 │
│       └──►Milestones (Deliverables)                             │
│                                                                  │
│  ┌─────────────────┐                                            │
│  │    Task         │───► Subtask                                │
│  │ (Assigned User) │───► TaskComment                            │
│  └─────────────────┘───► TaskAttachment (Files)                 │
│                                                                  │
│  ┌─────────────────┐                                            │
│  │   Attendance    │ (GPS Verified, Geofenced)                 │
│  │   + Leave       │ (With Approval Workflow)                   │
│  └─────────────────┘                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              DOCUMENTATION & PROGRESS                           │
│                                                                  │
│  ┌─────────────────────────────────────┐                       │
│  │  DailyProgressReport (DPR)          │                       │
│  │  ├── Weather info                    │                       │
│  │  ├── Equipment used                  │                       │
│  │  ├── Materials tracking              │                       │
│  │  ├── Safety observations             │                       │
│  │  ├── Quality checks                  │                       │
│  │  └──► DPRPhoto (Multiple)           │                       │
│  └─────────────────────────────────────┘                       │
│                                                                  │
│  ┌──────────────────┐   ┌──────────────┐   ┌───────────────┐  │
│  │  Message         │   │ Notification │   │   Document    │  │
│  │ (User to User)   │   │ (System)     │   │  (Versioned)  │  │
│  │ (Async comms)    │   │ (Real-time)  │   │  (Archived)   │  │
│  └──────────────────┘   └──────────────┘   └───────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   FINANCE & BILLING                             │
│                                                                  │
│  ┌──────────────────┐                                           │
│  │    Expense       │  (By Category: Material, Labor, etc)     │
│  │  ├── Amount      │                                           │
│  │  ├── Category    │                                           │
│  │  └── Approval    │                                           │
│  └──────────────────┘                                           │
│                                                                  │
│  ┌──────────────────┐      ┌──────────────┐                    │
│  │    Invoice       │─────►│InvoiceItem   │                    │
│  │  ├── Issue Date  │      │ (Line items) │                    │
│  │  ├── Line Items  │      │ (with taxes) │                    │
│  │  ├── Taxes       │      └──────────────┘                    │
│  │  ├── Status      │                                           │
│  │  └── Client      │                                           │
│  └────┬─────────────┘                                           │
│       │                                                         │
│       └──► Payment (Multiple per Invoice)                      │
│           ├── Amount                                            │
│           ├── Method (Cash/Bank/UPI/etc)                       │
│           └── Status                                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│              INVENTORY & STOCK MANAGEMENT                       │
│                                                                  │
│  ┌─────────────────┐                                            │
│  │   Material      │ (Name, Unit, Min Stock)                   │
│  │  ├── Stock Qty  │                                            │
│  │  ├── Min Level  │                                            │
│  │  └── Alert      │─────┐                                      │
│  └────┬────────────┘     │                                      │
│       │                  ▼                                      │
│       │            ┌──────────────┐                             │
│       │            │  StockAlert  │ (Threshold alerts)         │
│       │            │  ├── Status  │                             │
│       │            │  └── Notify  │                             │
│       │            └──────────────┘                             │
│       │                                                         │
│       ├──► MaterialRequest (Procurement)                       │
│       │    ├── Quantity                                        │
│       │    ├── Approval Workflow                               │
│       │    ├── Supplier                                        │
│       │    └── Delivery Tracking                               │
│       │                                                         │
│       └──► StockTransaction (Movement)                         │
│            ├── Previous Stock                                  │
│            ├── New Stock                                       │
│            ├── Type (In/Out)                                   │
│            └── Reference                                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                   AUDIT & LOGGING                               │
│                                                                  │
│  ┌──────────────────────────────────────┐                      │
│  │     AuditLog                         │                      │
│  │  ├── User (Who made change)          │                      │
│  │  ├── Action (What was done)          │                      │
│  │  ├── EntityType (What was changed)   │                      │
│  │  ├── OldData (Previous values)       │                      │
│  │  ├── NewData (Updated values)        │                      │
│  │  └── Timestamp (When)                │                      │
│  └──────────────────────────────────────┘                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow Scenarios

### 1. Project Creation Flow
```
User (SUPER_ADMIN or COMPANY_ADMIN)
  ├─ Creates Project
  │   ├── Links Company
  │   ├── Links Client
  │   └── Sets Location (Geofence)
  ├─ Creates ProjectSettings
  │   ├── Check-in/Check-out times
  │   └── Notification preferences
  ├─ Creates Milestones
  └─ Logs AuditLog (CREATE_PROJECT action)
```

### 2. Task Management Flow
```
User (COMPANY_ADMIN)
  ├─ Creates Task
  │   ├── Assigns to User
  │   ├── Sets Priority
  │   └── Links to Project
  ├─ Creates Subtasks
  ├─ Adds TaskComments
  ├─ Uploads TaskAttachments
  └─ Updates TaskStatus (TODO → IN_PROGRESS → REVIEW → COMPLETED)
```

### 3. Attendance Tracking Flow
```
User (SITE_WORKER)
  ├─ CheckIn (GPS + Time recorded)
  │   ├── Location captured (checkInLatitude, checkInLongitude)
  │   ├── Accuracy recorded
  │   └── Distance from geofence calculated
  ├─ Work at Site
  └─ CheckOut (GPS + Time recorded)
      ├── Calculate workingHours
      ├── Calculate overtimeHours
      └── Manager verifies attendance
```

### 4. Invoice & Payment Flow
```
User (FINANCE)
  ├─ Creates Invoice
  │   ├── Links Project & Client
  │   ├── Adds InvoiceItems (with taxes)
  │   └── Sets Terms & DueDate
  ├─ Sends to Client
  └─ Receives Payments (one or multiple)
      └─ Updates Invoice Status
          ├── ISSUED
          ├── PARTIALLY_PAID
          └── PAID
```

### 5. Material Request Flow
```
User (SITE_MANAGER)
  ├─ Creates MaterialRequest
  │   ├── Specifies Material & Quantity
  │   ├── Sets Urgency
  │   └── Links to Project
  ├─ Awaits Approval (REQUESTED)
  ├─ If Approved → Order (APPROVED)
  ├─ Track Delivery (IN_TRANSIT)
  └─ Confirm Receipt (DELIVERED)
      └── StockTransaction created
          └── Stock levels updated
```

### 6. DPR Creation Flow
```
User (SITE_ENGINEER)
  ├─ Creates DailyProgressReport
  │   ├── Weather & Temperature
  │   ├── Work description
  │   ├── Equipment & Materials
  │   ├── Safety observations
  │   └── Quality checks
  ├─ Uploads DPRPhotos (Multiple)
  ├─ Submits for Approval
  └─ Manager Approves/Rejects
      └── Send Notification
```

---

## Entity Relationship Summary

| Entity | Belongs To | Has Many | References |
|--------|-----------|----------|-----------|
| User | Company, Role | Tasks, Attendance, Leave, Messages | - |
| Company | - | Users, Clients, Projects, Roles | - |
| Client | Company | Projects, Invoices, Payments | CreatedBy User |
| Project | Company, Client | Tasks, DPRs, Expenses, Attendance, Materials | CreatedBy User |
| Task | Project | Subtasks, Comments, Attachments | CreatedBy, AssignedTo User |
| Attendance | User, Project | - | MarkedBy User |
| Leave | User | - | ApprovedBy User |
| DPR | Project | DPRPhotos | PreparedBy, ApprovedBy User |
| Expense | Project | - | CreatedBy, ApprovedBy User |
| Invoice | Project, Client | InvoiceItems, Payments | CreatedBy, ApprovedBy User |
| Material | Company | MaterialRequests, StockTransactions, StockAlerts | CreatedBy User |
| MaterialRequest | Project, Material | - | RequestedBy, ApprovedBy, OrderedBy User |
| Document | Project | - | UploadedBy User |
| Message | - | - | Sender, Receiver User, Project |
| Notification | User | - | - |
| AuditLog | - | - | User |

---

## Import Dependencies

When importing models, remember these file dependencies:

```
enums.dart (No dependencies - import first)
  ├─► permission.dart
  ├─► role.dart
  ├─► user_settings.dart
  │   ├─► company_settings.dart
  │   └─► Needs User from user_settings
  ├─► project_related.dart
  │   └─► Needs User, Project
  ├─► task_related.dart
  │   └─► Needs User, Task
  ├─► attendance_leave.dart
  │   └─► Needs User, Enums
  ├─► dpr.dart
  │   └─► Needs User, Project
  ├─► finance.dart
  │   └─► Needs User, Project, Client
  ├─► material.dart
  │   └─► Needs User, Project, Material
  ├─► communication.dart
  │   └─► Needs User, Project
  └─► audit_logs.dart
      └─► Needs User
```

**Best Practice:** Use `index.dart` to avoid managing dependencies manually!

```dart
import 'package:construction_erp/models/index.dart';
```

---

## Circular Dependency Avoidance

To prevent circular imports, relationships are handled as:
- **Forward references**: Users are referenced by ID and User object
- **No reverse collections**: Projects don't list their Tasks (prevent circular)
- **Provider pattern**: Use providers to load related data
- **Optional nulls**: Related objects are nullable, allowing lazy loading

Example:
```dart
// ✅ Good: User is referenced
class Task {
  final String assignedToId;
  final User? assignedTo;  // Optional, can be null
}

// ❌ Avoid: Circular reference
// class User {
//   final List<Task> assignedTasks;  // Use provider instead
// }
```

---

*This relationship map helps understand how models interact and depend on each other.*
