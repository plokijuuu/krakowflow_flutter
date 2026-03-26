import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Task> tasks = [
    Task(title: "Przygotować prezentację", deadline: "w piątek", done: false, priority: "wysoki"),
    Task(title: "Zrobić zakupy", deadline: "dzisiaj", done: true, priority: "niski"),
    Task(title: "Zrobić trening", deadline: "w czwartek", done: false, priority: "średni"),
    Task(title: "Napisać notatki", deadline: "weekend", done: false, priority: "niski"),
  ];

  @override
  Widget build(BuildContext context) {
    int doneCount = tasks.where((task) => task.done).length;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("KrakFlow"),
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masz dziś ${tasks.length} zadania (ukończone: $doneCount)"),

              SizedBox(height: 16),

              Text(
                "Dzisiejsze zadania",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          task.done
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
        ),
        title: Text(task.title),
        subtitle: Text(
          "termin: ${task.deadline} | priorytet: ${task.priority}",
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
}