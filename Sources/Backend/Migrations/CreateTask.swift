import Fluent

// TEACHING NOTE: Migrations are like CoreData's lightweight/heavyweight migrations
// They define how to evolve your database schema between app versions.
// In iOS, you'd use Core Data model versions and migration mappings.

struct CreateTask: AsyncMigration {
    // MARK: - Prepare (Create Schema)
    
    // This runs when migrating "up" - creating the table
    // Teaching note: Like creating a new Core Data entity
    func prepare(on database: Database) async throws {
        try await database.schema("tasks")
            // Primary key - like Core Data's automatic ObjectID
            .id()
            
            // Required fields
            .field("title", .string, .required)
            .field("is_completed", .bool, .required)
            .field("is_archived", .bool, .required)
            
            // Timestamps - automatic created_at
            // Teaching note: Like Core Data's automatic timestamp attributes
            .field("created_at", .datetime, .required)
            
            // Optional fields (can be null)
            .field("due_date", .datetime)
            .field("completed_at", .datetime)
            
            // Create the table
            .create()
    }
    
    // MARK: - Revert (Rollback)
    
    // This runs when migrating "down" - removing the table
    // Teaching note: Like removing a Core Data entity
    func revert(on database: Database) async throws {
        try await database.schema("tasks").delete()
    }
}
