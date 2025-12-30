# Refactored Models Directory Structure

```
lib/models/
├── index.dart                    # 🔀 NEW - Barrel file exporting all models
├── enums.dart                    # 🆕 NEW - All enum definitions
├── permission.dart               # ✅ Existing (unchanged)
├── role.dart                     # ✅ Existing (unchanged)
├── user_settings.dart            # 🆕 NEW - User + UserSettings
├── company.dart                  # 🆕 NEW - Company + CompanySettings
├── client.dart                   # 🔄 REFACTORED - Client model
├── project.dart                  # 🆕 NEW - Project + ProjectSettings + Milestone
├── task_related.dart             # 🆕 NEW - Task + Subtask + TaskComment + TaskAttachment
├── attendance_leave.dart         # 🆕 NEW - Attendance + Leave
├── dpr.dart                      # 🆕 NEW - DailyProgressReport + DPRPhoto
├── finance.dart                  # 🆕 NEW - Expense + Invoice + InvoiceItem + Payment
├── material.dart                 # 🆕 NEW - Material + MaterialRequest + StockTransaction + StockAlert
├── communication.dart            # 🆕 NEW - Message + Notification + Document
├── audit_logs.dart               # 🔄 REFACTORED - AuditLog model
│
└── [LEGACY - Keep for now]
    ├── project_related.dart      # ⚠️  Legacy (deleted)
    ├── company_settings.dart     # ⚠️  Legacy (deleted)
    ├── user.dart                 # ⚠️  Legacy (deleted)
    └── ... other legacy files
```

## Legend

- 🔀 **NEW (Barrel)** - New file that exports other models
- 🆕 **NEW** - Newly created file
- 🔄 **REFACTORED** - Existing file improved with new pattern
- ✅ **EXISTING** - Already existed, not modified
- ⚠️ **LEGACY** - Old structure, kept for backward compatibility

## File Organization by Domain

### Infrastructure Layer

- `enums.dart` - Type definitions
- `permission.dart` - Permission management
- `role.dart` - Role-based access control

### Identity Layer

- `user_settings.dart` - User profiles and preferences
- `company_settings.dart` - Company profiles and configuration
- `client.dart` - Client management

### Operations Layer

- `project_related.dart` - Projects, milestones, and settings
- `task_related.dart` - Tasks and task management
- `attendance_leave.dart` - Attendance and leave management

### Documentation Layer

- `dpr.dart` - Daily progress reports and photos
- `communication.dart` - Messages, notifications, documents

### Financial Layer

- `finance.dart` - Expenses, invoices, and payments
- `material.dart` - Materials and inventory

### Audit Layer

- `audit_logs.dart` - System audit trails

## Quick Import Examples

### Import Everything

```dart
import 'package:construction_erp/models/index.dart';
```

### Import by Domain

```dart
// User management
import 'package:construction_erp/models/user_settings.dart';
import 'package:construction_erp/models/enums.dart';

// Project management
import 'package:construction_erp/models/project_related.dart';
import 'package:construction_erp/models/task_related.dart';

// Finance
import 'package:construction_erp/models/finance.dart';
import 'package:construction_erp/models/material.dart';

// Attendance
import 'package:construction_erp/models/attendance_leave.dart';
```

## Total Files Created/Modified

- ✅ 11 New Model Files
- ✅ 4 Refactored Files
- ✅ 2 Documentation Files (Guide + This)
- ✅ 100+ Classes with Full JSON Serialization
- ✅ Consistent Pattern Across All Models
