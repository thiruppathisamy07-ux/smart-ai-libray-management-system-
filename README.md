# Smart AI Library Management System (Java Edition)

An enterprise-grade, lightweight modular monolith web application built with **Java 17/21 LTS**, **Spring Boot 3.3.4**, **MySQL 8.0**, **Spring Security 6**, **Thymeleaf**, **Bootstrap 5**, and a **RAG-based AI Assistant & Semantic Vector Search Engine**.

Designed specifically for 8 GB RAM laptop environments without requiring a GPU or secondary Python/Flask services.

---

## Architecture Overview

- **Backend**: Java 17/21 LTS & Spring Boot 3.3.4
- **ORM & Data Access**: Spring Data JPA & Hibernate 6 with Pessimistic Locking for atomic inventory management
- **Database**: MySQL 8.0 with Flyway automated migrations (`db/migration/V1__init_schema.sql`, `V2__seed_initial_data.sql`)
- **Authentication & Security**: Spring Security session-based authentication, BCrypt password hashing, role-based endpoint isolation, CSRF protection, and audit logging
- **AI & RAG Engine**:
  - Google Gemini API (`gemini-1.5-flash` / `gemini-1.5-pro` & `text-embedding-004`)
  - Deterministic high-dimensional vector hashing fallback for offline environments without an API key
  - Retrieval-Augmented Generation (RAG) grounded strictly in real-time MySQL database records
- **Digital Document Reader**: PDF.js with server-side access control and progress bookmarking
- **Study Productivity**: Full Pomodoro Study Timer with session logging
- **Testing**: JUnit 5, Mockito, Spring Boot Test (29 automated test cases)

---

## Role-Specific Portals

### 1. Student Portal (`/student/*`)
- **Browse & Filter Catalogue**: Keyword search, subject category filter, availability toggle.
- **Book Issue Requests**: Submit borrow requests with remarks; track approval status.
- **Loan History & Due Dates**: Monitor active loans, overdue alerts, and previous returns.
- **AI Library Assistant**: Natural-language RAG conversational chat backed by verified catalogue records.
- **Semantic Vector Search**: Concept-based book discovery using cosine similarity.
- **Digital PDF Reader**: View institutional PDF resources in-browser with automatic bookmarking.
- **Pomodoro Study Timer**: 25/5-minute focus intervals with automated session persistence.
- **Seat Reservations**: Reserve library study carrels by date and time slot with conflict checks.
- **Profile Management**: Update contact details and change portal password.

### 2. Staff Portal (`/staff/*`)
- **Circulation Desk**: Approve or reject pending student book issue requests.
- **Direct Issue**: Check out physical volumes over-the-counter to students in person.
- **Book Returns**: Process book returns, atomically restore inventory, and calculate overdue fines.
- **Overdue Management**: Track overdue loans and borrowers requiring contact.
- **Inventory Oversight**: Real-time stock counts and shelf locations.
- **Student Directory**: Search borrower profiles and circulation activity.
- **Seat Monitor**: Track carrel bookings by date and time slot.

### 3. Admin Portal (`/admin/*`)
- **User Management**: Create, edit, and suspend Student, Staff, and Admin accounts.
- **Catalogue Maintenance**: Add, edit, archive, and restore books with shelf coordinates.
- **Discipline Categories**: Create and organize library classification taxonomies.
- **Digital Resources**: Upload PDF papers, parse content with PDFBox, and generate vector chunks.
- **Circulation Ledger**: Master history of all transactions and seat reservations.
- **System & AI Settings**: Configure borrowing limits, loan days, fine rates, and Gemini API keys without frontend exposure.
- **Vector Index Maintenance**: Rebuild vector embeddings across all books and documents with one click.
- **Audit Logs**: Review immutable security and transaction audit trails.

---

## Pre-Configured Demo Accounts

The system automatically initializes standard demo accounts upon startup:

| Portal | Username | Password | Role | Permissions |
|---|---|---|---|---|
| **Admin Portal** | `admin` | `admin123` | `ROLE_ADMIN` | Full administrative control, system settings, user management |
| **Staff Portal** | `staff` | `staff123` | `ROLE_STAFF` | Circulation desk, approvals, returns, inventory |
| **Student Portal** | `student` | `student123` | `ROLE_STUDENT` | Catalogue, borrowing, AI assistant, Pomodoro, seats |
| **Student Portal** | `student2` | `student123` | `ROLE_STUDENT` | Secondary student account for multi-user testing |

*(Quick-fill buttons are provided on `/login` to switch between portals effortlessly)*

---

## Prerequisites

- **Java**: Java 17 LTS or Java 21 LTS installed (`java -version`).
- **MySQL**: MySQL Server 8.0 running on `localhost:3306`.
- **Maven**: Maven 3.8+ (A Maven wrapper `.\mvnw.cmd` is included in the project root).

---

## Database Configuration

1. Create the MySQL database:
```sql
CREATE DATABASE IF NOT EXISTS smart_library_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. Verify or customize credentials in `src/main/resources/application.properties` (or via environment variables):
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/smart_library_db?createDatabaseIfNotExist=true&useUnicode=true&characterEncoding=utf-8&serverTimezone=UTC
spring.datasource.username=${DB_USERNAME:root}
spring.datasource.password=${DB_PASSWORD:root123}
```

Flyway will automatically execute migrations `V1__init_schema.sql` and `V2__seed_initial_data.sql` on first run.

---

## Environment Variables

| Variable | Default Value | Description |
|---|---|---|
| `DB_USERNAME` | `root` | MySQL database username |
| `DB_PASSWORD` | `root123` | MySQL database password |
| `GEMINI_API_KEY` | *(Optional)* | Google Gemini API key for cloud LLM reasoning and embeddings |
| `GEMINI_MODEL` | `gemini-1.5-flash` | Gemini model name (`gemini-1.5-flash` or `gemini-1.5-pro`) |
| `EMBEDDING_MODEL`| `text-embedding-004` | Google embedding model name |
| `APP_UPLOAD_DIR` | `uploads` | Directory for uploaded digital PDF documents |

> **Note on AI Fallback**: If `GEMINI_API_KEY` is not provided, the system seamlessly uses its high-dimensional local term vectorizer and grounded catalogue search engine. Core library operations, semantic search, and the AI assistant continue to function with transparent fallback indicators.

---

## Running the Application

### One-Touch Launch (Recommended)
You can launch the entire application with a single command or double-click:

- **Windows Batch / Double-Click**:
  ```cmd
  run.bat
  ```
  *(or `launch.bat`)*

- **PowerShell**:
  ```powershell
  .\run.ps1
  ```

This one-touch launcher automatically:
1. Validates the Java 17+ environment.
2. Checks for the pre-packaged executable JAR (builds it automatically if needed).
3. Boots the Spring Boot application and indexes the local vector store.
4. Automatically opens your default web browser to **http://localhost:8080/login** as soon as the server is ready.

### Standard Maven Command
Alternatively, run with Maven:

```powershell
.\mvnw.cmd spring-boot:run
```

---

## Executing Automated Tests

The application includes 29 automated tests verifying circulation workflows, atomic inventory locks, seat reservation conflict prevention, semantic search cosine distances, and Spring Security role-based authorization:

```powershell
.\mvnw.cmd test
```

Expected output:
```
[INFO] Results:
[INFO] Tests run: 29, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

---

## Troubleshooting

1. **MySQL Access Denied (1045)**:
   - Ensure MySQL 8.0 is running (`Get-Service MySQL80`).
   - If your root password differs from `root123`, pass it via environment variable:
     `$env:DB_PASSWORD="your_password"; .\mvnw.cmd spring-boot:run`

2. **Port 8080 Already in Use**:
   - Change `server.port` in `src/main/resources/application.properties` or run:
     `.\mvnw.cmd spring-boot:run -Dspring-boot.run.arguments="--server.port=8081"`

3. **Rebuilding Vector Index**:
   - Log in as Admin (`admin` / `admin123`), navigate to **System & AI Settings** (`/admin/settings`), and click **Rebuild Vector Index**.
