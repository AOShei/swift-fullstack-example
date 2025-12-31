import Vapor
import Shared

// 1. EXTENSION: Make TaskItem conform to Content
// Vapor uses 'Content' to automatically handle JSON encoding/decoding.
extension TaskItem: Content {}

var env = try Environment.detect()
let app = Application(env)
defer { app.shutdown() }

// 2. MIDDLEWARE: Configure CORS
// Essential for the browser frontend to talk to this backend.
let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
)
let cors = CORSMiddleware(configuration: corsConfiguration)
app.middleware.use(cors)

// 3. In-Memory Database (simulated)
var tasks: [TaskItem] = [
    TaskItem(title: "Setup Development Environment", isCompleted: true),
    TaskItem(title: "Complete First Assignment", isCompleted: false)
]

// 4. Define Routes
app.get("tasks") { req -> [TaskItem] in
    return tasks
}

app.post("tasks") { req -> TaskItem in
    // Vapor automatically decodes the JSON body into our struct
    let newTask = try req.content.decode(TaskItem.self)
    tasks.append(newTask)
    return newTask
}

// 5. Start Server
try app.run()