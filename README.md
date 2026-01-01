# Swift Server-Side Task Manager

An educational example project demonstrating **server-side Swift development** with **Vapor + Leaf templating**. Designed for university students learning Swift and iOS patterns on any platform (Windows/Linux/macOS) using GitHub Codespaces.

## 🎯 Project Purpose

This project teaches:

- **Server-Side Swift**: Build web applications using Swift outside of iOS
- **iOS-Relevant Patterns**: Repository pattern, ViewModels, MVC architecture familiar to iOS developers
- **Zero Setup**: Works instantly in GitHub Codespaces - no local Swift installation required
- **Database Management**: Learn Fluent ORM (similar to Core Data) with SQLite

Perfect for students who want to learn Swift without needing a Mac, while still using patterns applicable to iOS development.

---

## 🏗️ Architecture

This is a **single-server architecture** using Vapor's server-side rendering:

```
┌─────────────────────────────────────────────────┐
│  Browser                                        │
│  • HTML forms POST to server                    │
│  • Server renders Leaf templates → HTML        │
└─────────────────────────────────────────────────┘
                      ↓ HTTP
┌─────────────────────────────────────────────────┐
│  Vapor Server (Port 8080)                       │
│  • Leaf templates (server-side rendering)       │
│  • SwiftUI-like ViewHelper patterns            │
│  • Repository pattern for database access       │
│  • Fluent ORM with SQLite                      │
└─────────────────────────────────────────────────┘
                      ↓ SQL
┌─────────────────────────────────────────────────┐
│  SQLite Database (tasks.sqlite)                 │
│  • File-based, zero configuration               │
│  • Persists across restarts                    │
└─────────────────────────────────────────────────┘
```

### Directory Structure

```
Sources/
  ├── Shared/                    # Data Transfer Objects (DTOs)
  │   └── Model.swift           # TaskItem struct shared across layers
  │
  └── Backend/                   # Vapor server application
      ├── main.swift            # Server configuration & routes
      ├── ViewHelpers.swift     # SwiftUI-like context builders
      │
      ├── Models/               # Database models (Fluent)
      │   └── TaskModel.swift   # Database entity with @Field, @Timestamp
      │
      ├── Repositories/         # Repository pattern (like iOS)
      │   └── TaskRepository.swift  # Database abstraction layer
      │
      ├── Migrations/           # Database schema (like Core Data versions)
      │   └── CreateTask.swift  # Table definitions
      │
      └── Resources/Views/      # Leaf HTML templates
          ├── base.leaf         # Base layout with CSS
          └── tasks.leaf        # Task list view
```

---

## 🚀 Quick Start

### 1. Open in Codespaces

Click the **Code** button → **Codespaces** → **Create codespace on main**

GitHub will automatically:

- Set up a Swift development environment
- Install all dependencies
- Configure VS Code with Swift extensions

### 2. Build the Project

```bash
./build.sh
```

This compiles the Vapor server with all dependencies.

### 3. Run the Server

```bash
./run_backend.sh
```

The server starts on **port 8080**.

### 4. Open in Browser

Open [http://localhost:8080](http://localhost:8080) in your browser (or use the Ports tab in Codespaces to open the forwarded URL).

You'll see the Task Board interface with:

- ✅ Add new tasks with due dates
- ✅ Filter tasks (All, Active, Completed, Archived, Overdue)
- ✅ Mark tasks complete/incomplete
- ✅ Archive/unarchive tasks
- ✅ Delete tasks

---

## 📚 Learning Path

### 1. **Start with the Models** ([Sources/Shared/Model.swift](Sources/Shared/Model.swift))

The `TaskItem` struct is a **Data Transfer Object** (DTO) - it's what gets sent between layers:

```swift
public struct TaskItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var isCompleted: Bool
    public var isArchived: Bool
    public var createdAt: Date
    public var dueDate: Date?
    public var completedAt: Date?
}
```

**iOS Connection**: Just like structs used in SwiftUI apps or as API response models.

### 2. **Understand the Database Layer** ([Sources/Backend/Models/TaskModel.swift](Sources/Backend/Models/TaskModel.swift))

The `TaskModel` class is a **Fluent model** - the database entity:

```swift
final class TaskModel: Model {
    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "is_completed")
    var isCompleted: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
}
```

**iOS Connection**:

- Property wrappers (`@Field`, `@Timestamp`) work like SwiftUI's `@State`, `@Published`
- Fluent models are like `NSManagedObject` in Core Data
- Migrations are like Core Data model versions

### 3. **Study the Repository Pattern** ([Sources/Backend/Repositories/TaskRepository.swift](Sources/Backend/Repositories/TaskRepository.swift))

The repository abstracts database operations:

```swift
final class TaskRepository {
    let database: Database

    func findAll() async throws -> [TaskItem]
    func findActive() async throws -> [TaskItem]
    func create(_ dto: TaskItem) async throws -> TaskItem
    func update(id: UUID, with dto: TaskItem) async throws -> TaskItem
    func delete(id: UUID) async throws
}
```

**iOS Connection**:

- Like creating a `DataManager` or `NetworkService` in iOS apps
- Separates business logic from data access
- Makes code testable (can mock repositories)

### 4. **Explore Server-Side Rendering** ([Sources/Backend/Resources/Views/](Sources/Backend/Resources/Views/))

Leaf templates use familiar syntax:

```leaf
#for(task in tasks):
    <div class="task-row">
        <p>#(task.title)</p>
        #if(task.isCompleted):
            <span>✓ Done</span>
        #endif
    </div>
#endfor
```

**iOS Connection**:

- `#for` is like SwiftUI's `ForEach`
- `#if` is like SwiftUI conditionals
- Server generates HTML instead of native UI

### 5. **Learn the SwiftUI-Like Helpers** ([Sources/Backend/ViewHelpers.swift](Sources/Backend/ViewHelpers.swift))

ViewModels prepare data for presentation:

```swift
struct TaskViewModel: Codable {
    let id: String
    let title: String
    let createdAgo: String      // "5m ago" - presentation logic
    let isOverdue: Bool         // computed from dueDate
}

struct TaskListContext {
    static func build(tasks: [TaskItem]) -> TaskListContext {
        // Transform models into view-ready data
    }
}
```

**iOS Connection**: Exactly like ViewModels in MVVM or cell configuration logic in UITableView.

---

## 🎓 Educational Exercises

### Exercise 1: Add Task Priority

1. Add `priority` field to [TaskItem](Sources/Shared/Model.swift) (`enum Priority: String, Codable`)
2. Update [TaskModel](Sources/Backend/Models/TaskModel.swift) with `@Field(key: "priority")`
3. Create migration to add column
4. Update [tasks.leaf](Sources/Backend/Resources/Views/tasks.leaf) to show priority badge
5. Add filter route in [main.swift](Sources/Backend/main.swift): `GET /tasks/high-priority`

### Exercise 2: Add Task Categories

1. Create new `Category` model with name and color
2. Add many-to-one relationship (`TaskModel` → `Category`)
3. Update forms to select category
4. Add repository methods for filtering by category

### Exercise 3: Add User Authentication

1. Create `User` model with username/password
2. Implement session-based authentication middleware
3. Associate tasks with users (owner relationship)
4. Add login/logout routes and forms

---

## 🔧 Technology Stack

| Component         | Technology      | iOS Equivalent                |
| ----------------- | --------------- | ----------------------------- |
| **Web Framework** | Vapor 4         | UIKit/SwiftUI (app framework) |
| **Templating**    | Leaf            | Storyboards/XIBs (UI markup)  |
| **ORM**           | Fluent          | Core Data                     |
| **Database**      | SQLite          | Core Data (SQLite store)      |
| **HTTP Server**   | SwiftNIO        | URLSession (but reversed)     |
| **Patterns**      | MVC, Repository | MVC, MVVM                     |

---

## 📖 API Reference

### REST Endpoints (JSON)

These endpoints return JSON and are useful for testing with `curl` or building a mobile app:

| Method   | Endpoint               | Description                 |
| -------- | ---------------------- | --------------------------- |
| `GET`    | `/tasks`               | Get all tasks               |
| `GET`    | `/tasks/active`        | Get non-archived tasks      |
| `GET`    | `/tasks/completed`     | Get completed tasks         |
| `GET`    | `/tasks/archived`      | Get archived tasks          |
| `GET`    | `/tasks/overdue`       | Get overdue tasks           |
| `POST`   | `/tasks`               | Create new task (JSON body) |
| `PUT`    | `/tasks/:id`           | Update task (JSON body)     |
| `PATCH`  | `/tasks/:id/complete`  | Toggle completion           |
| `PATCH`  | `/tasks/:id/archive`   | Archive task                |
| `PATCH`  | `/tasks/:id/unarchive` | Unarchive task              |
| `DELETE` | `/tasks/:id`           | Delete task                 |

### HTML Routes (Server-Rendered)

These render HTML pages:

| Method | Route                | Description                   |
| ------ | -------------------- | ----------------------------- |
| `GET`  | `/?filter=active`    | Main task board (with filter) |
| `POST` | `/tasks/create`      | Create task from form         |
| `POST` | `/tasks/:id/toggle`  | Toggle completion             |
| `POST` | `/tasks/:id/archive` | Archive task                  |
| `POST` | `/tasks/:id/delete`  | Delete task                   |

---

## 🛠️ Development Tips

### Rebuilding After Changes

```bash
./build.sh
```

### Viewing Server Logs

The server logs appear in the terminal where you ran `./run_backend.sh`:

```
2026-01-01T12:00:00+0000 info codes.vapor.application: [Vapor] GET /
2026-01-01T12:00:01+0000 info codes.vapor.application: [Vapor] POST /tasks/create
```

### Database Inspection

The SQLite database is stored in `tasks.sqlite`. You can inspect it:

```bash
sqlite3 tasks.sqlite
.tables              # List tables
.schema tasks        # Show table structure
SELECT * FROM tasks; # View all tasks
```

### Resetting the Database

```bash
rm tasks.sqlite
# Restart server - it will recreate the database
```

---

## 🤝 Contributing

This is an educational project. Students are encouraged to:

- Fork and experiment
- Add new features (see exercises above)
- Improve the UI/styling
- Share improvements via pull requests

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file.

---

## 🔗 Related Resources

- [Vapor Documentation](https://docs.vapor.codes/) - Official Vapor framework docs
- [Leaf Documentation](https://docs.vapor.codes/leaf/overview/) - Templating syntax reference
- [Fluent Documentation](https://docs.vapor.codes/fluent/overview/) - ORM guide
- [Swift.org](https://www.swift.org/) - Swift language documentation

---

**Built for educational purposes** | Based on [swift-env-template](https://github.com/AOShei/swift-env-template) for zero-setup Codespaces environments

## 🎯 Project Purpose

This project enables university students to:

- Learn Swift and iOS development patterns **without requiring macOS or Xcode**
- Practice pair programming (backend + frontend roles)
- Build fullstack applications using iOS-familiar frameworks
- Understand real-world app architecture (API + UI + Database)

Built on the [swift-env-template](https://github.com/AOShei/swift-env-template) for zero-setup Codespaces environments.

## 🏗️ Architecture

### Three-Layer Fullstack Design

```
┌─────────────────────────────────────────────────┐
│  Frontend (Port 8081)                           │
│  • Tokamak (SwiftUI-like) → WebAssembly        │
│  • Runs in browser, communicates via fetch API │
└─────────────────────────────────────────────────┘
                      ↓ HTTP
┌─────────────────────────────────────────────────┐
│  Backend (Port 8080)                            │
│  • Vapor REST API with Repository pattern      │
│  • Fluent ORM for database operations          │
└─────────────────────────────────────────────────┘
                      ↓ SQL
┌─────────────────────────────────────────────────┐
│  Database (SQLite)                              │
│  • File-based, zero configuration               │
│  • Persists in Codespaces workspace            │
└─────────────────────────────────────────────────┘
```

### Directory Structure

```
Sources/
  ├── Shared/              # Data models (DTO layer)
  │   └── Model.swift     # TaskItem struct shared by both targets
  ├── Backend/            # Vapor server (native Swift)
  │   ├── main.swift      # App configuration, routes
  │   ├── Models/         # Fluent database models
  │   ├── Repositories/   # Database abstraction layer
  │   └── Migrations/     # Database schema definitions
  └── Frontend/           # Tokamak UI (compiled to WebAssembly)
      └── App.swift       # SwiftUI-like components

ios-theme.css              # Reusable iOS design system styling
index.html                 # Custom HTML shell for frontend
Package.swift              # Dependencies and build configuration
```

## 🚀 Getting Started

### 1. Fork and Open in Codespaces

1. Fork this repository to your GitHub account
2. Click **Code** → **Codespaces** → **Create codespace on main**
3. Wait for the devcontainer to build (automatic Swift toolchain setup)

### 2. Build the Project

```bash
./build.sh
```

This script:

- Resolves dependencies with exact version pinning (prevents hangs)
- Builds Backend with memory constraints (`--jobs 1` for free-tier Codespaces)
- Builds Frontend via Carton (WebAssembly cross-compilation)

**⚠️ Never run `swift build` without `--product` flag** - builds both targets simultaneously and will hang.

### 3. Run Backend and Frontend

**Terminal 1 - Backend:**

```bash
./run_backend.sh
```

Starts Vapor server on port 8080 (uses `--skip-build` for fast restart)

**Terminal 2 - Frontend:**

```bash
./run_frontend.sh
```

Starts Carton dev server on port 8081 with live reload

### 4. Configure Port Forwarding (Codespaces Only)

1. Go to **Ports** tab in VS Code
2. Right-click port **8080** → **Port Visibility** → **Public**
3. Copy the "Local Address" (e.g., `https://xxx-8080.app.github.dev`)
4. Update `backendURL` in `Sources/Frontend/App.swift` (line 38)

### 5. Open the App

- Click the globe icon next to port **8081** in Ports tab
- Or open the forwarded URL in your browser

## ✨ Features

### Task Management

- ✅ Create tasks with titles and optional due dates
- ✅ Mark tasks as complete/incomplete (with completion timestamps)
- ✅ Archive tasks (soft delete pattern)
- ✅ Permanently delete tasks
- ✅ Filter views: All, Active, Completed, Archived, Overdue
- ✅ Relative timestamps ("2 hours ago")
- ✅ Overdue task highlighting

### Backend (Vapor + Fluent)

- RESTful API with full CRUD operations
- Repository pattern for database abstraction
- SQLite persistence with automatic migrations
- Async/await throughout (modern Swift concurrency)
- CORS middleware for browser access

### Frontend (Tokamak)

- SwiftUI-like declarative syntax
- iOS-style segmented control for filtering
- Task rows with completion checkmarks
- Archive and delete actions
- Empty state messages
- iOS design system styling via `ios-theme.css`

## 📚 iOS Patterns & Teaching Notes

This project teaches iOS development patterns that transfer directly to native Xcode:

### Repository Pattern

**File**: `Sources/Backend/Repositories/TaskRepository.swift`

Like creating a `CoreDataManager` in iOS apps:

```swift
// iOS equivalent
class CoreDataManager {
    func fetchTasks() -> [Task] { ... }
    func createTask(_ task: Task) { ... }
}
```

Teaches:

- Separation of concerns (database logic outside ViewControllers)
- Dependency injection (passing repository to routes)
- Testability (can mock repositories)

### Fluent ORM ≈ Core Data

**Files**: `Sources/Backend/Models/TaskModel.swift`, `Migrations/CreateTask.swift`

| Fluent                | Core Data                        |
| --------------------- | -------------------------------- |
| `@Field`              | `@NSManaged` property            |
| `@Timestamp`          | Automatic timestamp attributes   |
| `Model` protocol      | `NSManagedObject` subclass       |
| Migrations            | Model versions & mapping         |
| Queries with KeyPaths | `NSFetchRequest` with predicates |

### DTO Pattern

**Fluent Model** (`TaskModel`) ↔ **Shared Struct** (`TaskItem`)

Teaches:

- Separating database entities from API contracts
- Converting between persistence and view layers
- Like passing structs to SwiftUI views instead of managed objects

### Date Handling

**Teaching Note**: See `// DEVIATION FROM iOS` comments in `App.swift`

- **Native iOS**: `DatePicker`, `UIDatePicker`
- **This Project**: HTML5 `<input type="datetime-local">` via JavaScriptKit
- **Reason**: WebAssembly limitations, Tokamak missing DatePicker

### Network Layer

**All network methods use JavaScriptKit fetch**

- **Native iOS**: `URLSession.shared.dataTask`
- **This Project**: `JSObject.global.fetch` with promises
- **Reason**: URLSession doesn't work in WebAssembly

## 🎨 iOS Design System

`ios-theme.css` provides reusable iOS-style components:

- **Colors**: System blue (#007AFF), semantic colors, label hierarchy
- **Typography**: SF Pro font stack, iOS text styles
- **Inputs**: Rounded rectangles matching UITextField
- **Buttons**: Primary, secondary, destructive, icon styles
- **Lists**: UITableView-style rows with separators
- **Segmented Control**: UISegmentedControl appearance
- **Cards**: Grouped table view section styling

Students can use this stylesheet in their own projects to maintain iOS visual consistency.

## 🛠️ API Endpoints

| Method | Endpoint               | Description                    |
| ------ | ---------------------- | ------------------------------ |
| GET    | `/tasks`               | Fetch all tasks                |
| GET    | `/tasks/active`        | Non-archived tasks             |
| GET    | `/tasks/completed`     | Completed (non-archived) tasks |
| GET    | `/tasks/archived`      | Archived tasks                 |
| GET    | `/tasks/overdue`       | Overdue incomplete tasks       |
| POST   | `/tasks`               | Create new task                |
| PUT    | `/tasks/:id`           | Update task                    |
| PATCH  | `/tasks/:id/complete`  | Toggle completion status       |
| PATCH  | `/tasks/:id/archive`   | Archive task                   |
| PATCH  | `/tasks/:id/unarchive` | Restore from archive           |
| DELETE | `/tasks/:id`           | Permanently delete task        |

## ⚠️ Known Limitations

### Tokamak Framework

- **Status**: Seeking maintainers, not actively developed
- **Impact**: Limited SwiftUI API coverage
- **Use Case**: Good for teaching Swift/iOS patterns, but students will encounter differences in native iOS

### WebAssembly Constraints

- **No URLSession**: Must use JavaScriptKit fetch API
- **No DatePicker**: Use HTML5 datetime-local inputs
- **Performance**: Slower than native (interpreted WebAssembly)

### Development Workflow

- **Two terminals required**: Backend and frontend must run separately
- **Port forwarding**: Codespaces requires manual Public visibility setup
- **Memory constraints**: Free-tier Codespaces limit parallel builds

### Differences from Native iOS

| Feature     | Native iOS                                   | This Project                          |
| ----------- | -------------------------------------------- | ------------------------------------- |
| Date Picker | `DatePicker` / `UIDatePicker`                | HTML5 `<input type="datetime-local">` |
| Network     | `URLSession`                                 | `JSObject.global.fetch`               |
| Styling     | SwiftUI modifiers / UIAppearance             | Custom CSS (`ios-theme.css`)          |
| Database    | Core Data                                    | Fluent ORM (similar concepts)         |
| Navigation  | `NavigationStack` / `UINavigationController` | Limited in Tokamak                    |

## 🐛 Troubleshooting

### Frontend can't reach backend

- Verify port 8080 is **Public** in Ports tab
- Check `backendURL` in `App.swift` matches forwarded URL
- Look for CORS errors in browser console

### Build hangs indefinitely

- You ran `swift build` without `--product` flag
- Kill process, run `./build.sh` instead

### Database errors

- Delete `tasks.sqlite` file and restart backend
- Migrations run automatically on startup

### "main.js" 404 error

- Carton automatically injects scripts, ignore this error
- App should still work (check browser console for real errors)

## 📖 Learning Path

### For Students New to Swift

1. Study `Sources/Shared/Model.swift` - basic Swift structs
2. Read `Sources/Backend/main.swift` - API routing
3. Explore `Sources/Frontend/App.swift` - SwiftUI-like syntax

### For Students Learning iOS Patterns

1. **Repository Pattern**: `Sources/Backend/Repositories/TaskRepository.swift`
2. **Database Migrations**: `Sources/Backend/Migrations/CreateTask.swift`
3. **DTO Conversion**: `TaskModel.toDTO()` methods
4. **Async/await**: All network and database methods

### For Students Extending the Project

1. Add authentication (JWT tokens)
2. Add task categories/tags
3. Add task priority levels
4. Implement search functionality
5. Add task attachments/notes
6. Build calendar view
7. Add push notifications (via WebSockets)

## 🤝 Contributing

This is an educational example. Students should:

- Fork and experiment freely
- Modify models to add new fields
- Create new API endpoints
- Build additional UI screens
- Break things and learn!

## 📄 License

MIT License - See LICENSE file

## 🙏 Acknowledgments

- Built with [Vapor](https://vapor.codes/) - Swift web framework
- UI powered by [Tokamak](https://tokamak.dev/) - SwiftUI-compatible renderer
- Based on [swift-env-template](https://github.com/AOShei/swift-env-template)
- Inspired by the need for accessible Swift education
