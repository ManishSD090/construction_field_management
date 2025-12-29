# Models Folder Refactoring - Summary

## Overview
The models folder has been reorganized to follow a clean, modular structure. Each file is organized by logical domain/feature, with related models grouped together.

## File Structure

### Core & Infrastructure
- **enums.dart** - All enum types used throughout the app
  - UserType, AttendanceLocation, ProjectStatus, Priority, TaskStatus
  - AttendanceStatus, LeaveType, MaterialStatus, PaymentMethod
  - InvoiceStatus, DocumentType, ExpenseCategory, EmployeeStatus, SalaryType

- **permission.dart** - Permission system (existing file)
  - Permission class with permission codes and modules
  - PermissionManager for checking user permissions

- **role.dart** - Role & Permission linking (existing file)
  - Role class (System admin roles and company-specific roles)
  - RolePermission class for granular permission control

### Identity & Settings
- **user_settings.dart** - User model and settings
  - User class (complete user profile with all relationships)
  - UserSettings class (user preferences, theme, language)

- **company_settings.dart** - Company model and settings
  - Company class (company profile and details)
  - CompanySettings class (company configuration and prefixes)

### Projects & Management
- **project_related.dart** - Project management models
  - Project class (main project entity with locations, budgets, dates)
  - ProjectSettings class (checkin/out times, geofencing, notifications)
  - Milestone class (project milestones and deliverables)

- **client.dart** - Client management (existing file, refactored)
  - Client class (client company and contact information)

### Tasks & Work Items
- **task_related.dart** - Task management models
  - Task class (main task with assignments, priorities, status)
  - Subtask class (task breakdowns)
  - TaskComment class (task comments and discussions)
  - TaskAttachment class (file uploads for tasks)

### Attendance & Leave Management
- **attendance_leave.dart** - Attendance and leave models
  - Attendance class (daily attendance with geolocation, verification)
  - Leave class (leave requests with approval workflow)

### Daily Progress & Documentation
- **dpr.dart** - Daily Progress Report models
  - DailyProgressReport class (comprehensive DPR with weather, materials, safety)
  - DPRPhoto class (photos uploaded for DPRs)

### Finance & Billing
- **finance.dart** - Financial management models
  - Expense class (project expenses with categories)
  - Invoice class (client invoices with line items)
  - InvoiceItem class (invoice line items with taxes)
  - Payment class (payment receipts and tracking)

### Inventory Management
- **material.dart** - Material and stock management
  - Material class (material catalog and stock levels)
  - MaterialRequest class (material procurement requests)
  - StockTransaction class (stock movement tracking)
  - StockAlert class (low stock alerts)

### Communication & Documentation
- **communication.dart** - Communication models
  - Message class (user-to-user messages)
  - Notification class (system notifications)
  - Document class (project documents with versioning)

### Auditing
- **audit_logs.dart** - Audit and logging (existing file, refactored)
  - AuditLog class (system audit trails)

### Legacy Files (Still Present)
- **project.dart** - Contains Project and ProjectSettings (kept for backward compatibility)
- **company.dart** - Contains Company and CompanySettings (kept for backward compatibility)
- **user.dart** - Old monolithic user file (can be deprecated)

### New Export File
- **index.dart** - Barrel file that exports all models for easy importing

## Usage Example

### Old way:
```dart
import 'package:construction_erp/models/permission.dart';
import 'package:construction_erp/models/role.dart';
import 'package:construction_erp/models/user.dart';
import 'package:construction_erp/models/project.dart';
// ... many more imports
```

### New way:
```dart
import 'package:construction_erp/models/index.dart';
// Now all models are available
```

Or import specific modules:
```dart
import 'package:construction_erp/models/user_settings.dart';
import 'package:construction_erp/models/project_related.dart';
import 'package:construction_erp/models/enums.dart';
```

## Key Design Patterns

### 1. Common Model Structure
Each model follows this pattern:
```dart
class ModelName {
  final String id;
  // ... properties
  
  ModelName({
    required this.id,
    // ... constructor parameters
  });
  
  factory ModelName.fromJson(Map<String, dynamic> json) {
    return ModelName(
      id: json['id'] as String,
      // ... parsing logic
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // ... serialization logic
    };
  }
  
  @override
  String toString() => 'ModelName(id: $id, ...)';
}
```

### 2. Related Models in One File
- User + UserSettings
- Company + CompanySettings
- Project + ProjectSettings + Milestone
- Task + Subtask + TaskComment + TaskAttachment
- Attendance + Leave
- DailyProgressReport + DPRPhoto
- Invoice + InvoiceItem + Payment + Expense
- Material + MaterialRequest + StockTransaction + StockAlert

### 3. Enum-Driven Design
- All enums are centralized in enums.dart
- Models use proper enum types instead of strings
- Parsing includes fallback to default values for safety

## Migration Path

1. Update imports in screens to use new model files
2. Gradually migrate from old imports to new structure
3. Use index.dart for convenience imports
4. Keep legacy files for backward compatibility temporarily
5. Remove legacy files once migration is complete

## Benefits

✅ **Better Organization** - Models grouped by business domain
✅ **Easier Maintenance** - Related models together, easier to find
✅ **Improved Scalability** - Easy to add new models to appropriate files
✅ **Cleaner Imports** - Use index.dart for convenient access
✅ **Type Safety** - Proper enum usage instead of strings
✅ **Consistent Pattern** - All models follow the same structure
✅ **JSON Serialization** - All models support fromJson/toJson
