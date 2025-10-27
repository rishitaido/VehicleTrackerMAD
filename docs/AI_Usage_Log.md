# AI Transparency Log — Vehicle Maintenance Tracker Project
**Team Members:** Nick Johnson, Rishi Raj  


## 1. Project Planning & Feature Scope
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Uploaded project proposal PDF and asked AI to help outline concrete implementation plan.
- AI generated a detailed feature breakdown covering: Maintenance Log, Vehicle Profiles, Smart Reminders, Expense Tracking, and Local Storage.
- Created milestone checklist documents in `.pdf` and `.docx` formats showing Day 1-4 tasks.

**How It Was Applied:**  
- Used the generated milestone plan to organize our 4-day sprint.
- Divided features into: Day 1 (planning), Day 2 (database + vehicles), Day 3 (maintenance + reminders), Day 4 (polish).
- The checklist became our daily reference for tracking progress.

**Reflection / What We Learned:**  
- AI was excellent at breaking down a large project into manageable daily goals.
- Having a clear roadmap prevented scope creep and kept us focused.

---

## 2. Technology Stack Decision
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked: "Should we use Hive or SQLite for offline vehicle data storage in Flutter?"
- AI explained trade-offs: Hive is simpler but SQLite offers better querying and relationships.
- Recommended SQLite with `sqflite` package for proper foreign keys and complex queries.

**How It Was Applied:**  
- Decided to use SQLite as our local database.
- This choice influenced our data model design and repository pattern.
- SQLite's support for CASCADE deletes made data management much simpler.

**Reflection / What We Learned:**  
- SQLite's relational capabilities were essential for linking vehicles → maintenance → reminders.
- AI's comparison of both options helped us make an informed technical decision.

---

## 3. Database Schema Design
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for database schema with three tables: vehicles, maintenance_logs, reminders.
- AI provided SQL CREATE statements with foreign key relationships.
- Suggested field types and CASCADE delete behavior.

**How It Was Applied:**  
- Designed three tables with proper relationships:
  - `vehicles` table: id, nickname, make, model, year, currentMileage, vin, licensePlate, imagePath, timestamps
  - `maintenance_logs` table: id, vehicleId (FK), type, date, mileage, cost, notes, timestamps
  - `reminders` table: id, vehicleId (FK), type, dueDate, dueMileage, isCompleted, timestamps
- Set up foreign keys with `ON DELETE CASCADE` so deleting a vehicle removes all related data.
- Planned for `PRAGMA foreign_keys = ON` to enforce referential integrity.

**Reflection / What We Learned:**  
- Proper database design at the start saved us from data consistency issues later.
- CASCADE deletes were crucial for clean data management.

---

## 4. Project Architecture & File Structure
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for a simplified Flutter project structure suitable for a small team.
- AI recommended: single files for models, db, repos; separate folder for screens; utility folder for helpers.
- Suggested avoiding over-engineering with too many abstraction layers.

**How It Was Applied:**  
- Created flat structure:
  - `lib/models.dart` - all data models
  - `lib/db.dart` - database setup
  - `lib/repos.dart` - all repositories
  - `lib/screens/` - all screen files
  - `lib/utility/` - validators, widgets, reminder_helper
  - `lib/theme.dart` & `lib/theme_provider.dart` - theming
  - `lib/app.dart` & `lib/main.dart` - app setup
- Kept it simple with minimal folders.

**Reflection / What We Learned:**  
- Flat structure made navigation easier during rapid development.
- Could find any file quickly without deep folder nesting.

---

## 5. Data Models Planning
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for Dart model classes matching the database schema.
- AI suggested: `toMap()` and `fromMap()` for database serialization, `copyWith()` for immutable updates.
- Recommended ServiceType enum with icons and labels for consistency.

**How It Was Applied:**  
- Planned three model classes: `Vehicle`, `MaintenanceLog`, `Reminder`.
- Decided on ServiceType enum with 7 types: oilChange, tireRotation, brakeService, inspection, batteryReplacement, airFilter, other.
- Each model would have serialization methods for database operations.
- Planned DateTime handling using ISO8601 strings for SQLite compatibility.

**Reflection / What We Learned:**  
- Planning data models before coding prevented restructuring later.
- Enum approach for service types ensured type safety and prevented typos.

---

## 6. Repository Pattern Design
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked about best practices for separating database logic from UI in Flutter.
- AI recommended Repository pattern with three separate classes.
- Suggested CRUD methods plus aggregate queries (count, sum).

**How It Was Applied:**  
- Planned three repository classes:
  - `VehiclesRepo` - CRUD operations for vehicles, search functionality
  - `MaintenanceRepo` - maintenance logs, statistics calculations
  - `RemindersRepo` - active reminders, completion tracking
- Each repo would access database through singleton DB instance.
- Planned to use SQLite aggregate functions for efficiency.

**Reflection / What We Learned:**  
- Repository pattern would keep database logic isolated and testable.
- Planning aggregate queries early prevented loading all data into memory.

## 7. Database Implementation
**Date:** 2025-10-23
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for complete SQLite setup code with schema creation.
- AI provided singleton pattern, version management, and schema upgrade strategy.
- Recommended debug print statements for tracking database operations.

**How It Was Applied:**  
- Implemented `db.dart` with `DB` singleton class.
- Created `_createSchema()` method with all three table definitions.
- Set up version 2 with `onUpgrade` callback (drops and recreates tables).
- Added `onConfigure` to enable foreign keys with `PRAGMA foreign_keys = ON`.
- Database file: `vehicle_tracker.db` in app's database directory.
- Included helper methods: `close()` and `deleteDatabase()` for development.

**Reflection / What We Learned:**  
- Singleton pattern prevented multiple database instances.
- Drop-and-recreate upgrade strategy is simple but loses data (acceptable for development).
- Foreign key enforcement was critical for maintaining data integrity.

---

## 8. Models Implementation
**Date:** 2025-10-23
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for implementation guidance on model classes with proper serialization.
- AI provided examples of `toMap()`, `fromMap()`, and `copyWith()` patterns.
- Suggested handling nullable fields carefully in serialization.

**How It Was Applied:**  
- Created `models.dart` with three classes: `Vehicle`, `MaintenanceLog`, `Reminder`.
- Implemented ServiceType enum with 7 values, each having `label` getter and `icon` getter.
- All models include: constructor, `toMap()` for database insert, `fromMap()` factory for retrieval.
- Added `copyWith()` methods for immutable updates.
- DateTime fields serialize to ISO8601 strings for SQLite TEXT storage.
- Nullable fields (vin, notes, completedAt) handled properly in serialization.

**Reflection / What We Learned:**  
- Consistent serialization pattern made database operations straightforward.
- Enum with getters eliminated hardcoded strings throughout the app.
- CopyWith pattern proved invaluable for state updates.

---

## 9. Repositories Implementation
**Date:** 2025-10-23
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for repository implementation with full CRUD operations.
- AI suggested additional helper methods: count, search, aggregate functions.
- Recommended using SQLite's built-in COUNT and SUM for performance.

**How It Was Applied:**  
- Created `repos.dart` with three repository classes.
- `VehiclesRepo` methods: `getAll()`, `getById()`, `add()`, `update()`, `delete()`, `count()`, `search()`.
- `MaintenanceRepo` methods: `getForVehicle()`, `add()`, `update()`, `delete()`, `getCountForVehicle()`, `getTotalCostForVehicle()`.
- `RemindersRepo` methods: `getActive()`, `getForVehicle()`, `add()`, `complete()`, `delete()`.
- Each repo accesses database via `DB.instance.db`.
- Used SQL aggregate functions (COUNT, SUM) instead of loading all records.

**Reflection / What We Learned:**  
- Repository pattern kept database queries organized and reusable.
- SQL aggregate functions are much more efficient than Dart calculations.
- Separation of concerns made testing individual operations easier.

---

## 10. App Setup & Routing
**Date:** 2025-10-24  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for Flutter app entry point with proper database initialization.
- AI recommended async main with `WidgetsFlutterBinding.ensureInitialized()`.
- Suggested named routes for clean navigation.

**How It Was Applied:**  
- Created `main.dart` with async main function.
- Called `WidgetsFlutterBinding.ensureInitialized()` before database init.
- Initialized database with `await DB.instance.init()` before running app.
- Created `app.dart` with `MaterialApp` and 6 named routes.
- Set up routes: `/` (garage), `/vehicle-form`, `/maintenance-list`, `/maintenance-form`, `/reminders`, `/settings`.

**Reflection / What We Learned:**  
- Database must initialize before app runs to prevent race conditions.
- Named routes made navigation cleaner than pushing anonymous routes.

---

## 11. Garage Screen (Home Screen)
**Date:** 2025-10-24  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for main screen design showing list of vehicles with statistics.
- AI suggested card layout with vehicle info and three key stats.
- Recommended pull-to-refresh and empty state handling.

**How It Was Applied:**  
- Created `garage_screen.dart` as home screen.
- Loads vehicles and calculates statistics (maintenance count, total cost) for each.
- Displays vehicles in cards showing: nickname, year/make/model, mileage, service count, total cost.
- AppBar has two action buttons: reminders and settings.
- Each card has PopupMenuButton with Edit and Delete options.
- Implemented pull-to-refresh with `RefreshIndicator`.
- Empty state shows message with "Add Vehicle" button.
- Floating action button for adding new vehicles.

**Reflection / What We Learned:**  
- Loading stats for each vehicle separately was simple but could be optimized later.
- Card-based design provides good visual hierarchy.
- Pull-to-refresh became a standard pattern we used throughout.

---

## 12. Vehicle Form Screen
**Date:** 2025-10-24  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for form design to add/edit vehicles with validation.
- AI suggested using Form widget with GlobalKey for validation.
- Recommended image picker for optional vehicle photos.

**How It Was Applied:**  
- Created `vehicle_form_screen.dart` for adding/editing vehicles.
- Form includes: nickname, make, model, year, mileage (required); VIN, license plate, photo (optional).
- Used 7 TextEditingControllers for form fields.
- Implemented image picker with size and quality limits.
- Applied input formatters: digits only for year/mileage, uppercase for VIN.
- Validation on all required fields with custom validators.
- Separate "Optional Information" section for VIN and license plate.
- Save button shows loading state during database operation.

**Reflection / What We Learned:**  
- Form widget with validation kept input handling clean.
- Image picker needs size/quality limits for mobile performance.
- Separating optional fields improved form clarity.

---

## 13. Maintenance List Screen
**Date:** 2025-10-24  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for screen to display maintenance history for a specific vehicle.
- AI suggested chronological card layout with service details.
- Recommended including vehicle context in the app bar.

**How It Was Applied:**  
- Created `maintenance_list_screen.dart` receiving vehicleId via route arguments.
- Loads vehicle details and all maintenance logs for that vehicle.
- AppBar shows "{VehicleName} Maintenance" as title.
- Each maintenance log displayed as card with: service icon, type, date, mileage, cost, optional notes.
- Cards show formatted numbers (currency with $, mileage with commas).
- Delete button on each card with confirmation dialog.
- Empty state when no logs exist with "Add Maintenance" action.
- Floating action button to add new maintenance.

**Reflection / What We Learned:**  
- Displaying vehicle name in title provides helpful context.
- Number formatting (currency, thousands separators) improved readability.
- Confirmation before delete prevented accidental data loss.

---

## 14. Maintenance Form Screen
**Date:** 2025-10-24  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for form to log maintenance with automatic reminder creation.
- AI suggested service type dropdown, date picker, and reminder checkbox.
- Recommended pre-filling current mileage from vehicle data.

**How It Was Applied:**  
- Created `maintenance_form_screen.dart` for adding/editing maintenance logs.
- Form fields: service type (dropdown), date (picker), mileage, cost, notes (optional).
- Loads vehicle data to display context and pre-fill mileage field.
- Service type dropdown shows all 7 types with icons and labels.
- Date picker using custom InputDecorator styling to match other fields.
- Mileage validation prevents exceeding vehicle's current mileage.
- Cost input formatted to 2 decimal places with regex input formatter.
- "Create Reminder" checkbox (only when adding, not editing) with explanation subtitle.
- When saved, creates maintenance log and optionally calls reminder engine.

**Reflection / What We Learned:**  
- Pre-filling mileage saved users time and reduced errors.
- Custom date picker styling maintained form consistency.
- Automatic reminder creation after maintenance was a key feature users would appreciate.

---

## 15. Reminder Engine
**Date:** 2025-10-24  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for logic to calculate when next service is due based on intervals.
- AI suggested maintaining separate mileage and time intervals for each service type.
- Recommended creating both date-based and mileage-based reminders.

**How It Was Applied:**  
- Created `reminder_helper.dart` with `ReminderEngine` class.
- Defined mileage intervals map: Oil Change (5000), Tire Rotation (7500), Brake Service (30000), Inspection (12000), Battery (50000), Air Filter (15000), Other (10000).
- Defined time intervals map (in months): Oil Change (6), Tire Rotation (6), Brake Service (24), Inspection (12), Battery (48), Air Filter (12), Other (12).
- Method `createReminderAfterMaintenance()` calculates due mileage and due date based on intervals.
- Saves new reminder to database with both mileage and date criteria.
- Implemented helper methods: `isDueSoon()`, `isOverdue()`, `getStatus()`.
- Created ReminderStatus enum: upcoming, dueSoon, overdue, completed.

**Reflection / What We Learned:**  
- Different service types need different intervals based on best practices.
- Supporting both date AND mileage criteria covers different driving patterns.
- Status calculation requires both reminder data and current vehicle mileage.

---

## 16. Reminders Screen
**Date:** 2025-10-24  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for screen to display all active reminders with visual priority indicators.
- AI suggested color-coding by urgency and including status badges.
- Recommended showing both date and mileage information.

**How It Was Applied:**  
- Created `reminders_screen.dart` showing all active (incomplete) reminders.
- Loads all vehicles first to enable status calculation for each reminder.
- Each reminder card shows: colored avatar (red/orange/green), service type, due date, due mileage, status badge.
- Status determined using `ReminderEngine.getStatus(reminder, vehicle)`.
- Colors: overdue (red), due soon (orange), upcoming (green).
- Icons: warning for overdue, notifications_active for due soon, notifications for upcoming.
- Status labels from enum: "OVERDUE", "DUE SOON", "UPCOMING".
- Pull-to-refresh reloads reminders.
- Empty state when no active reminders.
- Tapping reminder navigates to maintenance form to complete the service.

**Reflection / What We Learned:**  
- Color coding provided instant visual feedback on urgency.
- Status calculation required loading vehicle data for mileage comparison.
- Combining date and mileage information gave complete picture.

---

## 17. Theme System
**Date:** 2025-10-25  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for professional light and dark theme implementation.
- AI suggested Material 3 with custom color scheme.
- Recommended consistent styling across all components.

**How It Was Applied:**  
- Created `theme.dart` with custom light and dark themes.
- Light theme: indigo primary (#4F46E5), amber accent, light gray surface.
- Dark theme: lighter indigo primary (#818CF8), lighter amber accent, dark gray surface.
- Configured Material 3 component themes: AppBar (centered, no elevation), Card (12px radius), InputDecoration (8px radius, filled), ElevatedButton (rounded, consistent padding).
- Defined animation constants for consistent transitions throughout app.
- Both themes use Roboto font family.

**Reflection / What We Learned:**  
- Centralized theme configuration ensured visual consistency.
- Material 3 provided good defaults but benefited from customization.
- Defining animation constants helped maintain consistent timing.

---

## 18. Theme Provider with Persistence
**Date:** 2025-10-25  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked how to persist theme preference across app restarts.
- AI recommended ChangeNotifier with SharedPreferences.
- Suggested supporting light, dark, and system theme modes.

**How It Was Applied:**  
- Created `theme_provider.dart` with `ThemeProvider` class extending `ChangeNotifier`.
- Stores theme preference in SharedPreferences with key 'theme_mode'.
- Supports three modes: light, dark, system (follows device setting).
- Method `init()` loads saved preference on app start.
- Method `setThemeMode()` updates preference and notifies listeners.
- Integrated into `app.dart` using `ChangeNotifierProvider` wrapper.
- App's `themeMode` bound to provider's value.

**Reflection / What We Learned:**  
- ChangeNotifier is lightweight and perfect for simple state like themes.
- SharedPreferences provides reliable persistence.
- System theme option respects user's device-wide preference.

---

## 19. Settings Screen
**Date:** 2025-10-25  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for settings screen with theme selection and app statistics.
- AI suggested radio buttons for theme choice and dialog for statistics.
- Recommended organizing with section headers.

**How It Was Applied:**  
- Created `settings_screen.dart` with three sections: Appearance, Data, About.
- Appearance section: RadioListTiles for Light Mode and Dark Mode selection.
- Removed system theme option to keep UI simple (binary choice).
- Data section: "App Statistics" button that shows dialog with totals.
- Statistics dialog calculates: total vehicles, total services, total cost, total mileage.
- About section: version number, help dialog with feature list.
- Section headers styled with primary color and bold font.

**Reflection / What We Learned:**  
- Radio buttons provided clear visual feedback for theme selection.
- Statistics aggregation gave users high-level insights.
- Clear sections made settings easy to navigate.

---

## 20. Input Validators
**Date:** 2025-10-25  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked for comprehensive form validation functions.
- AI provided validators with specific error messages.
- Suggested organizing as static methods.

**How It Was Applied:**  
- Created `validators.dart` with `Validators` class containing static methods.
- Core validators: `required()`, `year()`, `mileage()`, `mileageIncrease()`, `mileageWithMax()`, `cost()`, `vin()`.
- Additional validators for future use: `email()`, `phone()`, `minLength()`, `maxLength()`, optional variants.
- All validators return `String?` (null if valid, error string if invalid).
- VIN validator: checks 17 characters, alphanumeric excluding I, O, Q.
- Used in vehicle and maintenance forms for input validation.

**Reflection / What We Learned:**  
- Centralized validators improved code organization and testability.
- Specific error messages helped users fix issues quickly.
- Context-aware validators (like mileageWithMax) prevented data inconsistencies.

---

## 21. Error Handling & Testing
**Date:** 2025-10-25  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked about error handling best practices in Flutter.
- AI recommended try-catch blocks, mounted checks, and user feedback.
- Suggested testing common user flows and edge cases.

**How It Was Applied:**  
- Added try-catch blocks around all async operations.
- Implemented mounted checks before setState() after async operations.
- Used SnackBar consistently for success/error messages.
- Added confirmation dialogs before all destructive actions.
- Tested user flows: add vehicle → add maintenance → view reminder → delete vehicle.
- Verified empty states work correctly on all list screens.
- Tested cascade deletes ensure related data is removed.
- Verified theme switching updates all screens immediately.
- Tested form validation catches all invalid inputs.
- Verified pull-to-refresh works on all list screens.

**Reflection / What We Learned:**  
- Mounted checks prevented "setState after dispose" crashes.
- Systematic testing revealed edge cases we hadn't considered.
- Confirmation dialogs prevented accidental data loss.
- CASCADE delete simplified data management significantly.


