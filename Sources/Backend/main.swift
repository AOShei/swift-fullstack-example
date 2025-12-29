import Vapor
import Shared

var env = try Environment.detect()
let app = try Application(env)
defer { app.shutdown() }

// 1. Configure CORS (Allow the browser to access the API)
let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .all,
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE],
    allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
)
let cors = CORSMiddleware(configuration: corsConfiguration)
app.middleware.use(cors)

// 2. In-Memory Database (simulated)
var tasks: [TaskItem] = [
    TaskItem(title: "Learn Swift Server", isCompleted: true),
    TaskItem(title: "Build a Web App", isCompleted: false)
]

// 3. Define Routes
app.get("tasks") { req -> [TaskItem] in
    return tasks
}

app.post("tasks") { req -> TaskItem in
    let newTask = try req.content.decode(TaskItem.self)
    tasks.append(newTask)
    return newTask
}

try app.run()
