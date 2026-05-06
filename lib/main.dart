import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String title;
  String deadline;
  bool done;
  String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}

class TaskRepository {
  static List<Task> tasks = [
    Task(title: "Przygotować prezentację", deadline: "w piątek", done: false, priority: "wysoki"),
    Task(title: "Zrobić zakupy", deadline: "dzisiaj", done: true, priority: "niski"),
    Task(title: "Zrobić trening", deadline: "w czwartek", done: false, priority: "średni"),
    Task(title: "Napisać notatki", deadline: "weekend", done: false, priority: "niski"),
  ];
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KrakFlow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = "wszystkie";

  void _deleteAllTasks() {
    if (TaskRepository.tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Brak zadań do usunięcia!")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Potwierdzenie"),
        content: const Text("Czy na pewno chcesz usunąć wszystkie zadania?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Anuluj"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                TaskRepository.tasks.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Wszystkie zadania zostały usunięte")),
              );
            },
            child: const Text("Usuń", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTasks = TaskRepository.tasks;
    if (selectedFilter == "wykonane") {
      filteredTasks = TaskRepository.tasks.where((t) => t.done).toList();
    } else if (selectedFilter == "do zrobienia") {
      filteredTasks = TaskRepository.tasks.where((t) => !t.done).toList();
    }

    int doneCount = TaskRepository.tasks.where((task) => task.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteAllTasks,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Masz dziś ${TaskRepository.tasks.length} zadania (ukończone: $doneCount)"),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("wszystkie", "Wszystkie"),
                _filterButton("do zrobienia", "Do zrobienia"),
                _filterButton("wykonane", "Wykonane"),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  return Dismissible(
                    key: ValueKey(task.title + task.deadline),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        TaskRepository.tasks.remove(task);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Usunięto zadanie: ${task.title}")),
                      );
                    },
                    child: TaskCard(
                      task: task,
                      onChanged: (bool? value) {
                        setState(() {
                          task.done = value ?? false;
                        });
                      },
                      onTap: () async {
                        final Task? updatedTask = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditTaskScreen(task: task),
                          ),
                        );
                        if (updatedTask != null) {
                          setState(() {
                            int originalIndex = TaskRepository.tasks.indexOf(task);
                            TaskRepository.tasks[originalIndex] = updatedTask;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          if (newTask != null) {
            setState(() {
              TaskRepository.tasks.add(newTask);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _filterButton(String filterType, String label) {
    bool isActive = selectedFilter == filterType;
    return TextButton(
      onPressed: () => setState(() => selectedFilter = filterType),
      style: TextButton.styleFrom(
        foregroundColor: isActive ? Colors.blue : Colors.grey,
        backgroundColor: isActive ? Colors.blue.withOpacity(0.1) : null,
      ),
      child: Text(label),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?>? onChanged;
  final VoidCallback? onTap;

  const TaskCard({
    super.key,
    required this.task,
    this.onChanged,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(
          value: task.done,
          onChanged: onChanged,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.done ? TextDecoration.lineThrough : TextDecoration.none,
            color: task.done ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Text(
          "termin: ${task.deadline} | priorytet: ${task.priority}",
          style: TextStyle(
            color: task.done ? Colors.grey.shade400 : Colors.black54,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class EditTaskScreen extends StatefulWidget {
  final Task task;
  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController deadlineController;
  late TextEditingController priorityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    deadlineController = TextEditingController(text: widget.task.deadline);
    priorityController = TextEditingController(text: widget.task.priority);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edytuj zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytuł")),
            const SizedBox(height: 12),
            TextField(controller: deadlineController, decoration: const InputDecoration(labelText: "Termin")),
            const SizedBox(height: 12),
            TextField(controller: priorityController, decoration: const InputDecoration(labelText: "Priorytet")),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final updatedTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: widget.task.done,
                );
                Navigator.pop(context, updatedTask);
              },
              child: const Text("Zapisz zmiany"),
            ),
          ],
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadlineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nowe zadanie")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tytuł zadania", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: deadlineController, decoration: const InputDecoration(labelText: "Termin", border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: priorityController, decoration: const InputDecoration(labelText: "Priorytet", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newTask = Task(
                  title: titleController.text,
                  deadline: deadlineController.text,
                  priority: priorityController.text,
                  done: false,
                );
                Navigator.pop(context, newTask);
              },
              child: const Text("Zapisz"),
            ),
          ],
        ),
      ),
    );
  }
}