import Hummingbird
import Shared
import Foundation

// 1. EXTENSION: Make TaskItem returnable directly
// Hummingbird needs to know this Codable struct is safe to send as a JSON response.
extension TaskItem: HBResponseCodable {}

// 2. MIDDLEWARE: Custom CORS Middleware
// We define a struct because 'HBCallbackMiddleware' does not exist in this version.
struct CORSMiddleware: HBAsyncMiddleware {
    func apply(to request: HBRequest, next: HBResponder) async throws -> HBResponse {
        // Handle "Pre-flight" OPTIONS checks
        if request.method == .OPTIONS {
            return .init(status: .ok, headers: [
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "GET, POST, OPTIONS"
            ])
        }
        
        // Handle normal requests and add CORS headers to response
        let response = try await next.respond(to: request)
        response.headers.replaceOrAdd(name: "Access-Control-Allow-Origin", value: "*")
        return response
    }
}

// 3. Setup App
let app = HBApplication(configuration: .init(address: .hostname("0.0.0.0", port: 8080)))

// Add the middleware
app.middleware.add(CORSMiddleware())

// 4. In-Memory Database (simulated)
var tasks: [TaskItem] = [
    TaskItem(title: "Learn Swift Server", isCompleted: true),
    TaskItem(title: "Build a Web App", isCompleted: false)
]

// 5. Define Routes
app.router.get("tasks") { _ in
    return tasks
}

app.router.post("tasks") { req -> TaskItem in
    let newTask = try req.decode(as: TaskItem.self)
    tasks.append(newTask)
    return newTask
}

// 6. Start Server
try app.start()
app.wait()