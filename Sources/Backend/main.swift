import Vapor
import Fluent
import FluentSQLiteDriver
import Leaf
import LeafKit
import Shared

// Import our backend components
import struct Foundation.UUID

// MARK: - Configuration Function

func configure(_ app: Application) async throws {
    // MARK: - Leaf Configuration (Server-Side Rendering)
    // Teaching note: Leaf is like Storyboards/XIBs but with server-side rendering
    
    // Set the directory where Leaf templates are located
    app.leaf.configuration.rootDirectory = app.directory.workingDirectory + "Sources/Backend/Resources/Views/"
    app.views.use(.leaf)
    
    // MARK: - Database Configuration
    // Teaching note: This is like setting up Core Data stack in iOS AppDelegate
    
    // 1. Configure SQLite database (file-based, perfect for Codespaces)
    app.databases.use(.sqlite(.file("tasks.sqlite")), as: .sqlite)
    
    // 2. Register migrations (how we evolve database schema)
    // Teaching note: Like Core Data model versions
    app.migrations.add(CreateTask())
    
    // 3. Run migrations automatically on startup
    // Teaching note: In production, you'd run migrations separately
    try await app.autoMigrate()
    
    // MARK: - Repository Setup (Dependency Injection)
    // Teaching note: Creating singleton repository accessible to all routes
    // Similar to passing Core Data context throughout iOS app
    
    // Store repository in a variable that will be captured by route closures
    // In Vapor 4.99+, app.storage API changed, so we use closure capture
    let repository = TaskRepository(database: app.db)
    
    // MARK: - Model Extensions for Vapor
    
    // Make TaskItem work with Vapor's automatic JSON encoding/decoding
    // (Extension is defined at bottom of file)
    
    // MARK: - CORS Middleware Configuration
    // Teaching note: Needed for external API access, not needed for same-origin HTML forms
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors)
    
    // MARK: - HTML Routes (Server-Side Rendered)
    // Teaching note: These render HTML using Leaf templates, like MVC pattern in iOS
    
    // GET / - Main task board view
    app.get { req async throws -> View in
        let filter = try? req.query.get(String.self, at: "filter")
        let filterValue = filter ?? "active"
        
        // Fetch tasks based on filter
        let tasks: [TaskItem]
        switch filterValue {
        case "all":
            tasks = try await repository.findAll()
        case "completed":
            tasks = try await repository.findCompleted()
        case "archived":
            tasks = try await repository.findArchived()
        case "overdue":
            tasks = try await repository.findOverdue()
        default: // "active"
            tasks = try await repository.findActive()
        }
        
        // Build context using SwiftUI-like builder pattern
        let context = TaskListContext.build(filter: filterValue, tasks: tasks)
        
        return try await req.view.render("tasks", context)
    }
    
    // POST /tasks/create - Create new task from form
    // Teaching note: Like handling form submission in UIKit
    app.post("tasks", "create") { req async throws -> Response in
        let formData = try req.decodeFormData()
        
        let newTask = TaskItem(
            title: formData.title,
            isCompleted: false,
            isArchived: false,
            createdAt: Date(),
            dueDate: formData.dueDate,
            completedAt: nil
        )
        
        _ = try await repository.create(newTask)
        
        // Redirect back to the task list
        return req.redirect(to: "/")
    }
    
    // POST /tasks/:id/toggle - Toggle task completion
    app.post("tasks", ":id", "toggle") { req async throws -> Response in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        _ = try await repository.toggleComplete(id: id)
        
        return req.redirect(to: "/")
    }
    
    // POST /tasks/:id/archive - Archive a task
    app.post("tasks", ":id", "archive") { req async throws -> Response in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        _ = try await repository.archive(id: id)
        
        return req.redirect(to: "/")
    }
    
    // POST /tasks/:id/unarchive - Unarchive a task
    app.post("tasks", ":id", "unarchive") { req async throws -> Response in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        _ = try await repository.unarchive(id: id)
        
        return req.redirect(to: "/?filter=archived")
    }
    
    // POST /tasks/:id/delete - Delete a task
    app.post("tasks", ":id", "delete") { req async throws -> Response in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        try await repository.delete(id: id)
        
        return req.redirect(to: "/")
    }
    
    // MARK: - JSON API Routes (for external access/testing)
    // Teaching note: Keep these for API clients and testing with curl/Postman
    
    // MARK: - JSON API Routes (for external access/testing)
    // Teaching note: Keep these for API clients and testing with curl/Postman
    
    // GET /tasks - Fetch all tasks
    app.get("tasks") { req async throws -> [TaskItem] in
        return try await repository.findAll()
    }
    
    // GET /tasks/active - Fetch only active (non-archived) tasks
    app.get("tasks", "active") { req async throws -> [TaskItem] in
        return try await repository.findActive()
    }
    
    // GET /tasks/completed - Fetch completed tasks
    app.get("tasks", "completed") { req async throws -> [TaskItem] in
        return try await repository.findCompleted()
    }
    
    // GET /tasks/archived - Fetch archived tasks
    app.get("tasks", "archived") { req async throws -> [TaskItem] in
        return try await repository.findArchived()
    }
    
    // GET /tasks/overdue - Fetch overdue tasks
    app.get("tasks", "overdue") { req async throws -> [TaskItem] in
        return try await repository.findOverdue()
    }
    
    // POST /tasks - Create a new task
    // Teaching note: POST for creating resources (RESTful convention)
    app.post("tasks") { req async throws -> TaskItem in
        let newTask = try req.content.decode(TaskItem.self)
        return try await repository.create(newTask)
    }
    
    // PUT /tasks/:id - Update an existing task
    // Teaching note: PUT for full resource updates
    app.put("tasks", ":id") { req async throws -> TaskItem in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        let updatedTask = try req.content.decode(TaskItem.self)
        return try await repository.update(id: id, with: updatedTask)
    }
    
    // PATCH /tasks/:id/complete - Toggle task completion
    // Teaching note: PATCH for partial updates (just changing one field)
    app.patch("tasks", ":id", "complete") { req async throws -> TaskItem in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        return try await repository.toggleComplete(id: id)
    }
    
    // PATCH /tasks/:id/archive - Archive a task
    app.patch("tasks", ":id", "archive") { req async throws -> TaskItem in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        return try await repository.archive(id: id)
    }
    
    // PATCH /tasks/:id/unarchive - Unarchive a task
    app.patch("tasks", ":id", "unarchive") { req async throws -> TaskItem in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        return try await repository.unarchive(id: id)
    }
    
    // DELETE /tasks/:id - Permanently delete a task
    // Teaching note: DELETE for removing resources
    app.delete("tasks", ":id") { req async throws -> HTTPStatus in
        guard let idString = req.parameters.get("id"),
              let id = UUID(uuidString: idString) else {
            throw Abort(.badRequest, reason: "Invalid task ID")
        }
        
        try await repository.delete(id: id)
        return .noContent
    }
}

// MARK: - Content Conformance

// Make TaskItem work with Vapor's automatic JSON encoding/decoding
extension TaskItem: Content {}

// MARK: - Main Entry Point
// Teaching note: Traditional top-level code approach for executable targets
// In Vapor 4.99+, we use Application.make() in async context

let env = try Environment.detect()
let app = try await Application.make(env)

defer { app.shutdown() }

try await configure(app)
try await app.execute()