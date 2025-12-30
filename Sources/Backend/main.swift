import Hummingbird
import Shared
import Foundation

// 1. Create the App
let app = HBApplication(configuration: .init(address: .hostname("0.0.0.0", port: 8080)))

// 2. Add CORS Middleware (Manually)
// This allows your Frontend (browser) to talk to this Backend.
app.middleware.add(HBCallbackMiddleware { request, next in
    // Handle "Pre-flight" OPTIONS checks
    if request.method == .OPTIONS {
        return .init(status: .ok, headers: [
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
        ], body: .empty)
    }
    
    // Handle normal requests and add CORS headers to response
    let response = try await next.respond(to: request)
    response.headers.replaceOrAdd(name: "Access-Control-Allow-Origin", value: "*")
    return response
})

// 3. In-Memory Data
var tasks: [TaskItem] = [
    TaskItem(title: "Learn Hummingbird", isCompleted: true),
    TaskItem(title: "Compile Faster", isCompleted: false)
]

// 4. Define Routes
app.router.get("tasks") { _ in
    return tasks
}

app.router.post("tasks") { req -> TaskItem in
    // Note: Hummingbird uses 'decode' instead of 'content.decode'
    let newTask = try req.decode(as: TaskItem.self)
    tasks.append(newTask)
    return newTask
}

// 5. Start Server
try app.start()
app.wait()