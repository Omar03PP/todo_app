import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Task> _tasks = [];

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _dialogController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _expandedTaskIndex = -1;

  void _addTask(String title, String description) {
    if (title.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title, description: description));
        _controller.clear();
      });
    }
  }

  void _performRemoveTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      if (_expandedTaskIndex == index) {
        _expandedTaskIndex = -1;
      } else if (_expandedTaskIndex > index) {
        _expandedTaskIndex--;
      }
    });
  }

  void _confirmDismiss(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar Eliminación"),
        content: Text(
          "¿Estás seguro de que quieres eliminar la tarea: \"${_tasks[index].title}\"?",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _performRemoveTask(index);
              Navigator.of(context).pop();
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTask(int index, bool? value) {
    setState(() {
      _tasks[index].done = value ?? false;
    });
  }

  void _toggleDescription(int index) {
    setState(() {
      if (_expandedTaskIndex == index) {
        _expandedTaskIndex = -1;
      } else {
        _expandedTaskIndex = index;
      }
    });
  }

  void _editTask(int index) {
    _dialogController.text = _tasks[index].title;
    _descriptionController.text =
        _tasks[index].description;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar tarea"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _dialogController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Título de la tarea",
              ),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Descripción (opcional)",
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dialogController.clear();
              _descriptionController.clear();
            },
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_dialogController.text.isNotEmpty) {
                setState(() {
                  _tasks[index].title = _dialogController.text;
                  _tasks[index].description =
                      _descriptionController.text;
                });
                _dialogController.clear();
                _descriptionController.clear();
                Navigator.of(context).pop();
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int pendingTasks = _tasks.where((t) => !t.done).length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Tareas ($pendingTasks pendientes)"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text("No hay tareas agregadas !"))
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      final bool isExpanded = _expandedTaskIndex == index;
                      final bool hasDescription = task.description
                          .trim()
                          .isNotEmpty;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Checkbox(
                                value: task.done,
                                onChanged: (value) => _toggleTask(index, value),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.done
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                              onTap: () => _editTask(index),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasDescription)
                                    IconButton(
                                      icon: Icon(
                                        isExpanded
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        color: isExpanded
                                            ? Colors.deepPurple
                                            : Colors.grey,
                                      ),
                                      onPressed: () =>
                                          _toggleDescription(index),
                                      tooltip: isExpanded
                                          ? "Ocultar descripción"
                                          : "Ver descripción",
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _confirmDismiss(context, index),
                                    tooltip: "Eliminar tarea",
                                  ),
                                ],
                              ),
                            ),
                            if (isExpanded && hasDescription)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    task.description,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          _dialogController.clear();
          _descriptionController.clear();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Nueva tarea"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _dialogController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: "Escribe el título de la tarea...",
                    ),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Escribe una descripción (opcional)...",
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _dialogController.clear();
                    _descriptionController.clear();
                  },
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_dialogController.text.isNotEmpty) {
                      _addTask(
                        _dialogController.text,
                        _descriptionController.text,
                      );
                      _dialogController.clear();
                      _descriptionController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Agregar"),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
