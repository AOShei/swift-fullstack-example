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
