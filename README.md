# Project Example: Collaborative Task Manager

This project demonstrates a full-stack Swift application running entirely in Codespaces. It consists of three parts:

Shared: Data models used by both client and server.

Backend: A Hummingbird server API.

Frontend: A Tokamak WebAssembly app.

📂 1. Directory Structure

Your project folder should look like this:

/Sources
  /Shared
    Model.swift
  /Backend
    main.swift
  /Frontend
    App.swift
Package.swift


📦 2. The Package.swift

This file defines the dependencies and targets. Note how Shared is a dependency for both Backend and Frontend.

// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TaskApp",
    platforms: [.macOS(.v13)], // ignored by Wasm
    products: [
        .executable(name: "Backend", targets: ["Backend"]),
        .executable(name: "Frontend", targets: ["Frontend"]),
    ],
    dependencies: [
        // Vapor for the Backend
        .package(url: "[https://github.com/vapor/vapor.git](https://github.com/vapor/vapor.git)", from: "4.89.0"),
        // Tokamak for the Frontend (WebAssembly)
        .package(url: "[https://github.com/TokamakUI/Tokamak](https://github.com/TokamakUI/Tokamak)", from: "0.11.0"),
    ],
    targets: [
        // 1. Shared Logic (The Contract)
        .target(name: "Shared"),

        // 2. Backend (Server)
        .executableTarget(
            name: "Backend",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                "Shared"
            ]
        ),

        // 3. Frontend (Web Client)
        .executableTarget(
            name: "Frontend",
            dependencies: [
                .product(name: "TokamakShim", package: "Tokamak"),
                "Shared"
            ]
        ),
    ]
)


🤝 3. The Shared Module (Sources/Shared/Model.swift)

This is the code that Student A and Student B agree upon before starting.

import Foundation

// "Codable" allows this to be converted to JSON automatically.
public struct TaskItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var title: String
    public var isCompleted: Bool

    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}


☁️ 4. The Backend (Sources/Backend/main.swift)

This is a simple Vapor server. Crucial: It includes CORS configuration so the web browser is allowed to talk to it.

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


🖥️ 5. The Frontend (Sources/Frontend/App.swift)

This uses Tokamak to render HTML using SwiftUI syntax.

import TokamakDOM
import Foundation
import Shared

@main
struct TaskApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var tasks: [TaskItem] = []
    @State private var newTaskTitle = ""
    @State private var isLoading = false

    var body: some View {
        VStack {
            Text("Collaborative Task Board")
                .font(.title)
                .padding()

            HStack {
                TextField("New Task...", text: $newTaskTitle)
                Button("Add") {
                    createTask()
                }
                .disabled(newTaskTitle.isEmpty)
            }
            .padding()

            if isLoading {
                Text("Loading...")
            } else {
                List(tasks) { task in
                    HStack {
                        Text(task.title)
                        Spacer()
                        if task.isCompleted {
                            Text("✅")
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchTasks()
        }
    }

    // Networking Logic using Swift's native URLSession
    func fetchTasks() {
        isLoading = true
        guard let url = URL(string: "[http://127.0.0.1:8080/tasks](http://127.0.0.1:8080/tasks)") else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data, let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
                    self.tasks = decoded
                }
            }
        }.resume()
    }

    func createTask() {
        guard let url = URL(string: "[http://127.0.0.1:8080/tasks](http://127.0.0.1:8080/tasks)") else { return }
        let newTask = TaskItem(title: newTaskTitle)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(newTask)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async {
                if data != nil {
                    self.tasks.append(newTask)
                    self.newTaskTitle = ""
                }
            }
        }.resume()
    }
}


🚀 How to Run (The "Two Terminal" Trick)

Since you have a backend and a frontend, you need two terminal instances in VS Code.

Terminal 1 (Backend):

swift run Backend


Wait until you see "Server starting on https://www.google.com/search?q=http://127.0.0.1:8080"

Terminal 2 (Frontend):
Split the terminal (or open a new one) and run:

carton dev --product Frontend


Wait for it to build, then open the browser link provided.

Note on Codespaces:
When carton dev opens the app in the browser, it is accessing the frontend. The frontend code tries to hit 127.0.0.1:8080. Codespaces is smart enough to forward this traffic correctly, but if you have connection issues, ensure the Ports tab in VS Code shows both port 8080 (Backend) and port 8081 (Carton/Frontend) as "Forwarded".