import TokamakDOM
import Foundation
import Shared
import JavaScriptKit

@main
struct TaskApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    // ---------------------------------------------------------
    // 🚨 CONFIGURATION STEP 🚨
    // 1. Go to the "Ports" tab in VS Code.
    // 2. Right-click Port 8080 -> Port Visibility -> Public.
    // 3. Copy the "Local Address" (e.g., https://...-8080.app.github.dev).
    // 4. Paste it below (ensure no trailing slash).
    // ---------------------------------------------------------
    let backendURL = "https://CHANGE-ME-TO-YOUR-PORT-8080-URL.app.github.dev"
    // ---------------------------------------------------------

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
                
                if newTaskTitle.isEmpty {
                    Button("Add") { }
                        .opacity(0.5)
                } else {
                    Button("Add") {
                        createTask()
                    }
                }
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

    // 1. Fetch Logic
    func fetchTasks() {
        isLoading = true
        
        Task {
            do {
                let jsFetch = JSObject.global.fetch.function!
                
                // USE DYNAMIC URL
                let resultVal = jsFetch("\(backendURL)/tasks")
                
                guard let promise = JSPromise(resultVal.object!) else { return }
                let responseVal = try await promise.value
                let responseObj = responseVal.object!
                
                let textResult = responseObj.text!()
                guard let textPromise = JSPromise(textResult.object!) else { return }
                let textVal = try await textPromise.value
                
                if let jsonString = textVal.string,
                   let data = jsonString.data(using: .utf8) {
                    let decoded = try JSONDecoder().decode([TaskItem].self, from: data)
                    self.tasks = decoded
                }
                
                self.isLoading = false
            } catch {
                print("Fetch Error: \(error)")
                self.isLoading = false
            }
        }
    }

    // 2. Create Logic
    func createTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let newTask = TaskItem(title: newTaskTitle)
        
        Task {
            do {
                let encoder = JSONEncoder()
                guard let data = try? encoder.encode(newTask),
                      let jsonString = String(data: data, encoding: .utf8) else { return }
                
                let jsFetch = JSObject.global.fetch.function!
                let objectConstructor = JSObject.global.Object.function!
                
                var options = objectConstructor.new()
                options["method"] = "POST"
                
                var headers = objectConstructor.new()
                headers["Content-Type"] = "application/json"
                options["headers"] = headers.jsValue
                options["body"] = jsonString.jsValue
                
                // USE DYNAMIC URL
                let resultVal = jsFetch("\(backendURL)/tasks", options)
                
                guard let promise = JSPromise(resultVal.object!) else { return }
                _ = try await promise.value
                
                self.tasks.append(newTask)
                self.newTaskTitle = ""
            } catch {
                print("Post Error: \(error)")
            }
        }
    }
}