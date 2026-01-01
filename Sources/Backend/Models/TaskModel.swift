import Fluent
import Vapor
import Foundation
import Shared

// TEACHING NOTE: Fluent Models are like CoreData's NSManagedObject
// This class represents how tasks are stored in the database.
// We use property wrappers (@Field, @Timestamp, etc.) similar to how SwiftUI uses @State, @Binding

final class TaskModel: Model, @unchecked Sendable {
    // Database table name
    // Teaching note: Like CoreData entity names
    static let schema = "tasks"
    
    // MARK: - Properties with Fluent Property Wrappers
    
    // @ID is like CoreData's NSManagedObjectID
    @ID(key: .id)
    var id: UUID?
    
    // @Field stores regular data columns
    // Teaching note: Like CoreData @NSManaged properties
    @Field(key: "title")
    var title: String
    
    @Field(key: "is_completed")
    var isCompleted: Bool
    
    @Field(key: "is_archived")
    var isArchived: Bool
    
    // @Timestamp automatically manages created/updated dates
    // Teaching note: Similar to CoreData's automatic timestamp attributes
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    // @OptionalField for nullable columns
    @OptionalField(key: "due_date")
    var dueDate: Date?
    
    @OptionalField(key: "completed_at")
    var completedAt: Date?
    
    // MARK: - Initializers
    
    // Required empty initializer for Fluent
    init() { }
    
    // Convenience initializer for creating new tasks
    init(
        id: UUID? = nil,
        title: String,
        isCompleted: Bool = false,
        isArchived: Bool = false,
        dueDate: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.isArchived = isArchived
        self.dueDate = dueDate
        self.completedAt = completedAt
    }
    
    // MARK: - DTO Conversion (Data Transfer Object Pattern)
    
    // Teaching note: This is the Repository/DTO pattern - separating database entities
    // from API contracts. In iOS, you'd convert NSManagedObject to structs for views.
    
    /// Convert database model to API DTO
    /// Teaching note: Like converting Core Data objects to view-safe structs
    func toDTO() throws -> TaskItem {
        guard let id = self.id,
              let createdAt = self.createdAt else {
            throw Abort(.internalServerError, reason: "Task missing required fields")
        }
        
        return TaskItem(
            id: id,
            title: title,
            isCompleted: isCompleted,
            isArchived: isArchived,
            createdAt: createdAt,
            dueDate: dueDate,
            completedAt: completedAt
        )
    }
    
    /// Create database model from DTO
    /// Teaching note: Like creating NSManagedObject from struct data
    static func fromDTO(_ dto: TaskItem) -> TaskModel {
        return TaskModel(
            id: dto.id,
            title: dto.title,
            isCompleted: dto.isCompleted,
            isArchived: dto.isArchived,
            dueDate: dto.dueDate,
            completedAt: dto.completedAt
        )
    }
    
    /// Update this model with data from DTO
    /// Teaching note: Like updating an existing Core Data object
    func update(from dto: TaskItem) {
        self.title = dto.title
        self.isCompleted = dto.isCompleted
        self.isArchived = dto.isArchived
        self.dueDate = dto.dueDate
        self.completedAt = dto.completedAt
    }
}
