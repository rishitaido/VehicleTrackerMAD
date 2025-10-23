# AI Transparency Log — Vehicle Maintenance Tracker Project
**Date:** 2025-10-23 19:56  
**Team Members:** Nick Johnson, Rishi Raj  
**AI Tool Used:** ChatGPT (GPT-5)

---

## 🧠 Purpose
This log documents all uses of AI assistance throughout the development of the *Vehicle Maintenance Tracker* mobile app, in compliance with the course transparency requirement.

---

## 1. Project Planning & Structure
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  
**What Was Asked / Generated:**  
- Helped outline project goals, features, and milestones based on the uploaded proposal PDF.  
- Generated a detailed feature plan (Maintenance Log, Vehicle Profiles, Smart Reminders, Expense Tracking, Local Storage).  
- Created milestone checklist documents in `.pdf` and `.docx` formats.  

**How It Was Applied:**  
- Used to plan the project scope, organize the UI/UX, and define what will be developed in Milestone 1 and Milestone 2.  
- The generated checklist became the reference for the team’s development plan.  

**Reflection / What We Learned:**  
- AI was very effective for organizing large ideas quickly.  
- It helped translate general project goals into actionable tasks and deliverables.

---

## 2. Database Decision (Hive → SQLite)
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  
**What Was Asked / Generated:**  
- Asked to replace Hive with SQLite for offline data storage.  
- Generated revised file structure, schema overview, and migration strategy.  

**How It Was Applied:**  
- Adopted SQLite (`sqflite`) as the final database choice.  
- The provided schema and DAO layout were used to plan table creation and data flow.  

**Reflection / What We Learned:**  
- SQLite offered better alignment with course requirements.  
- AI explained trade-offs clearly and simplified schema design for faster implementation.

---

## 3. Simplified Architecture
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  
**What Was Asked / Generated:**  
- Asked to condense project structure for efficient development and clarity.  
- Generated a minimal architecture using single `models.dart`, `db.dart`, `repos.dart`, and `screens/` folders.  

**How It Was Applied:**  
- This became the official structure implemented in the repository.  
- Reduced folder complexity and allowed quicker setup.  

**Reflection / What We Learned:**  
- AI can effectively prioritize essential files over unnecessary abstraction.  
- Simplicity improves productivity and makes the project easier to maintain.

---

## 4. Code Skeleton & Theming
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  
**What Was Asked / Generated:**  
- Requested lightweight Flutter skeleton using the simplified structure.  
- AI generated base code for app setup, router, theme, SQLite integration, and placeholder screens.  

**How It Was Applied:**  
- The skeleton was used as a base to start the Flutter project.  
- Provided consistency in naming and layout across all files.  

**Reflection / What We Learned:**  
- Using AI-generated boilerplate saves setup time and enforces consistent patterns.  
- We gained better understanding of how to structure small Flutter apps cleanly.

---

## 5. Documentation & Transparency
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  
**What Was Asked / Generated:**  
- Created multiple project documents (`.pdf`, `.docx`, `.md`) for milestones and structure.  
- Generated this AI transparency log template.  

**How It Was Applied:**  
- All generated files are stored in the `docs/` directory of the GitHub repo.  
- The AI_Usage_Log.md serves as the record of all AI involvement.  

**Reflection / What We Learned:**  
- Clear documentation makes collaboration easier and shows transparency in AI-assisted work.  
- Maintaining a running AI log helps track progress and ethical use of AI tools.

---

## ✅ Summary Reflection
- **AI was used responsibly** to accelerate planning, documentation, and setup—not to replace student understanding.  
- **All generated code and structures were reviewed, simplified, and modified** by team members before implementation.  
- **Main value:** organization, clarity, and time savings.  
- **Main lesson:** AI is most useful as a design and planning partner, not a substitute for coding or learning.

---

**Prepared by:** Nick Johnson & Rishi Raj  
**Project:** Vehicle Maintenance Tracker  
**Date:** 2025-10-23 19:56


# AI Transparency Log — Vehicle Maintenance Tracker Project
**Team Members:** Nick Johnson, Rishi Raj  
**AI Tool Used:** ChatGPT (GPT-5)

---

Previous entries retained...



## 6. Next Development Focus Guidance  
**Date:** 2025-10-23  
**AI Tool Used:** ChatGPT (GPT-5)  

**What Was Asked / Generated:**  
- Asked which files to focus on next after completing core UI files (`main.dart`, `app.dart`, `theme.dart`, `widgets.dart`, `garage_screen.dart`, `reminders_screen.dart`, `settings_screen.dart`).  
- AI provided a clear, prioritized list of next development tasks and files to create:  
  1. `db.dart` – SQLite setup and table creation  
  2. `models.dart` – data classes and enums  
  3. `repos.dart` – database access layer  
  4. `reminder_engine.dart` – logic for “due soon” reminders  
  5. `maintenance_list_screen.dart` & `maintenance_form_screen.dart` – for maintenance CRUD  
  6. `vehicle_form_screen.dart` – for adding/editing vehicles  

**How It Was Applied:**  
- Used as a guide for upcoming development steps and to plan workload distribution between team members.  
- This plan now defines the next milestone phase in the project timeline.

**Reflection / What Was Learned:**  
- Breaking development into small, specific file goals helps maintain consistent progress.  
- Using AI for roadmap refinement provides clarity and reduces the risk of scope creep.  
- Having a logical file order ensures the database and UI connect smoothly.

---
