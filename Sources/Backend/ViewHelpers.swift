import Vapor
import Foundation
import Shared

// MARK: - SwiftUI-Like View Context Builders
// Teaching note: This provides SwiftUI-style syntax for building Leaf template contexts
// Similar to how SwiftUI uses @ViewBuilder to compose views

/// TaskViewModel - Represents a task with presentation logic
/// Teaching note: Like a ViewModel in MVVM or a cell configuration in UITableView
struct TaskViewModel: Codable {
    let id: String
    let title: String
    let isCompleted: Bool
    let isArchived: Bool
    let createdAgo: String
    let dueDate: Date?
    let dueDateFormatted: String?
    let isOverdue: Bool
    
    /// Initialize from TaskItem with formatting
    /// Teaching note: This is where presentation logic lives (formatting dates, computing states)
    init(from task: TaskItem) {
        self.id = task.id.uuidString
        self.title = task.title
        self.isCompleted = task.isCompleted
        self.isArchived = task.isArchived
        self.createdAgo = Self.formatRelativeTime(task.createdAt)
        self.dueDate = task.dueDate
        self.dueDateFormatted = task.dueDate.map { Self.formatDueDate($0) }
        self.isOverdue = task.dueDate.map { $0 < Date() && !task.isCompleted } ?? false
    }
    
    // MARK: - Formatting Helpers
    // Teaching note: These are pure functions - no side effects, easy to test
    
    private static func formatRelativeTime(_ date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if seconds < 60 {
            return "just now"
        } else if minutes < 60 {
            return "\(Int(minutes))m ago"
        } else if hours < 24 {
            return "\(Int(hours))h ago"
        } else if days < 7 {
            return "\(Int(days))d ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
    }
    
    private static func formatDueDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// TaskListContext - SwiftUI-like builder for task list view
/// Teaching note: This is like building a List in SwiftUI with ForEach
struct TaskListContext: Codable {
    let title: String
    let filter: String
    let tasks: [TaskViewModel]
    
    /// Create context from an array of TaskItems
    /// Teaching note: This is the "build" step - transforms model data into view data
    static func build(title: String = "Task Board", 
                     filter: String = "active", 
                     tasks: [TaskItem]) -> TaskListContext {
        let viewModels = tasks.map { TaskViewModel(from: $0) }
        
        return TaskListContext(title: title, filter: filter, tasks: viewModels)
    }
}

// MARK: - Request + Form Data Helpers
// Teaching note: Like parsing form data in UIKit or SwiftUI (TextField bindings)
extension Request {
    /// Decode form data into a CreateTaskData struct
    /// Teaching note: Similar to how SwiftUI bindings work with @State
    func decodeFormData() throws -> CreateTaskData {
        struct FormData: Content {
            let title: String
            let dueDate: String?
        }
        
        let formData = try content.decode(FormData.self)
        
        guard !formData.title.isEmpty else {
            throw Abort(.badRequest, reason: "Title is required")
        }
        
        let dueDate = formData.dueDate.flatMap { parseDateTimeLocal($0) }
        
        return CreateTaskData(title: formData.title, dueDate: dueDate)
    }
    
    /// Parse HTML datetime-local format to Date
    /// Teaching note: Like DateFormatter, but for HTML5 input types
    private func parseDateTimeLocal(_ string: String) -> Date? {
        guard !string.isEmpty else { return nil }
        
        // Format: "2025-12-31T13:01"
        let components = string.split(separator: "T")
        guard components.count == 2 else { return nil }
        
        let dateParts = components[0].split(separator: "-").compactMap { Int($0) }
        let timeParts = components[1].split(separator: ":").compactMap { Int($0) }
        
        guard dateParts.count == 3, timeParts.count >= 2 else { return nil }
        
        var dateComponents = DateComponents()
        dateComponents.year = dateParts[0]
        dateComponents.month = dateParts[1]
        dateComponents.day = dateParts[2]
        dateComponents.hour = timeParts[0]
        dateComponents.minute = timeParts[1]
        dateComponents.timeZone = TimeZone.current
        
        return Calendar.current.date(from: dateComponents)
    }
}

/// Data structure for creating tasks from forms
/// Teaching note: Like a DTO (Data Transfer Object) for form submissions
struct CreateTaskData {
    let title: String
    let dueDate: Date?
}
