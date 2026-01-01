import Fluent
import Vapor
import Foundation
import Shared

// TEACHING NOTE: Repository Pattern
// This abstracts database operations from route handlers, following iOS best practices.
// In iOS, you'd use repositories to abstract Core Data or network calls from ViewControllers.
// This promotes:
// - Separation of concerns
// - Testability (can mock repositories)
// - Reusability (multiple routes can share logic)

final class TaskRepository {
    let database: Database
    
    // MARK: - Initialization
    
    // Teaching note: This is dependency injection - passing in the database
    // Similar to passing Core Data context to ViewControllers
    init(database: Database) {
        self.database = database
    }
    
    // MARK: - Read Operations (Queries)
    
    /// Fetch all tasks (unfiltered)
    /// Teaching note: Like NSFetchRequest with no predicate
    func findAll() async throws -> [TaskItem] {
        let models = try await TaskModel.query(on: database).all()
        return try models.map { try $0.toDTO() }
    }
    
    /// Fetch only active (non-archived) tasks
    /// Teaching note: Like NSFetchRequest with NSPredicate(format: "isArchived == NO")
    func findActive() async throws -> [TaskItem] {
        let models = try await TaskModel.query(on: database)
            .filter(\.$isArchived == false)
            .all()
        return try models.map { try $0.toDTO() }
    }
    
    /// Fetch completed tasks (excluding archived)
    /// Teaching note: Like NSPredicate with compound conditions (isCompleted AND NOT isArchived)
    func findCompleted() async throws -> [TaskItem] {
        let models = try await TaskModel.query(on: database)
            .filter(\.$isCompleted == true)
            .filter(\.$isArchived == false)
            .all()
        return try models.map { try $0.toDTO() }
    }
    
    /// Fetch archived tasks
    /// Teaching note: Like filtering for "deleted" items (soft delete pattern)
    func findArchived() async throws -> [TaskItem] {
        let models = try await TaskModel.query(on: database)
            .filter(\.$isArchived == true)
            .all()
        return try models.map { try $0.toDTO() }
    }
    
    /// Fetch overdue tasks (due date in the past, not completed)
    /// Teaching note: Like NSPredicate comparing dates (dueDate < now AND isCompleted == NO)
    func findOverdue() async throws -> [TaskItem] {
        let now = Date()
        let models = try await TaskModel.query(on: database)
            .filter(\.$isCompleted == false)
            .filter(\.$isArchived == false)
            .filter(\.$dueDate < now)
            .all()
        return try models.map { try $0.toDTO() }
    }
    
    /// Find a single task by ID
    /// Teaching note: Like Core Data fetchRequest with predicate for specific ObjectID
    func find(id: UUID) async throws -> TaskItem? {
        guard let model = try await TaskModel.find(id, on: database) else {
            return nil
        }
        return try model.toDTO()
    }
    
    // MARK: - Write Operations (Create, Update, Delete)
    
    /// Create a new task
    /// Teaching note: Like inserting new NSManagedObject into Core Data context
    func create(_ dto: TaskItem) async throws -> TaskItem {
        let model = TaskModel.fromDTO(dto)
        try await model.save(on: database)
        return try model.toDTO()
    }
    
    /// Update an existing task
    /// Teaching note: Like updating properties on NSManagedObject then saving context
    func update(id: UUID, with dto: TaskItem) async throws -> TaskItem {
        guard let model = try await TaskModel.find(id, on: database) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        model.update(from: dto)
        try await model.save(on: database)
        return try model.toDTO()
    }
    
    /// Toggle task completion status
    /// Teaching note: Common iOS pattern - toggle boolean and set timestamp
    func toggleComplete(id: UUID) async throws -> TaskItem {
        guard let model = try await TaskModel.find(id, on: database) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        model.isCompleted.toggle()
        
        // Set completedAt timestamp when marking complete, clear when uncompleting
        if model.isCompleted {
            model.completedAt = Date()
        } else {
            model.completedAt = nil
        }
        
        try await model.save(on: database)
        return try model.toDTO()
    }
    
    /// Archive a task (soft delete)
    /// Teaching note: Soft delete pattern - mark as deleted rather than actually deleting
    /// Common in iOS for undo functionality
    func archive(id: UUID) async throws -> TaskItem {
        guard let model = try await TaskModel.find(id, on: database) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        model.isArchived = true
        try await model.save(on: database)
        return try model.toDTO()
    }
    
    /// Unarchive a task
    /// Teaching note: Restore from soft delete
    func unarchive(id: UUID) async throws -> TaskItem {
        guard let model = try await TaskModel.find(id, on: database) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        model.isArchived = false
        try await model.save(on: database)
        return try model.toDTO()
    }
    
    /// Permanently delete a task (hard delete)
    /// Teaching note: Like calling delete() on NSManagedObject
    /// Usually prefer archiving for user safety
    func delete(id: UUID) async throws {
        guard let model = try await TaskModel.find(id, on: database) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        try await model.delete(on: database)
    }
}
