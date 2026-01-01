import Foundation

// "Codable" allows this to be converted to JSON automatically.
// This is a Data Transfer Object (DTO) - the contract between frontend and backend.
// Teaching note: In iOS, this would be your model layer (like structs in SwiftUI apps)
public struct TaskItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var isCompleted: Bool
    public var isArchived: Bool
    
    // Timestamps for task lifecycle management
    public var createdAt: Date
    public var dueDate: Date?
    public var completedAt: Date?

    public init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        isArchived: Bool = false,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.completedAt = completedAt
    }
}
