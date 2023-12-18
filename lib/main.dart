import 'package:flutter/material.dart';
import 'package:todo/todo.dart';
import 'package:todo/todo_state.dart';

void main() {
  runApp(MaterialApp(
    home: const TodoStateHolder(child: MyHomePage()),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Colors.black,
      ),
    ),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool showDone = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addTodo(BuildContext oldContext) {
    showDialog(
      context: oldContext,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Todo"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                TodoStateHolder.of(oldContext).add(
                  Todo(
                    title: _titleController.text,
                    description: _descriptionController.text,
                  ),
                );
                _titleController.clear();
                _descriptionController.clear();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todo"),
        actions: [
          if (TodoProvider.of(context)
              .todoList
              .where((element) => element.isDone)
              .isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  showDone = !showDone;
                });
              },
              child:
                  showDone ? const Text("Hide Done") : const Text("Show Done"),
            )
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemCount: TodoProvider.of(context).todoList.length,
          itemBuilder: (context, index) {
            Todo currentTodo = TodoProvider.of(context).todoList[index];
            if (currentTodo.isDone && !showDone) return Container();
            return ListTile(
              title: Text(currentTodo.title),
              subtitle: currentTodo.description != null
                  ? Text(currentTodo.description!)
                  : null,
              trailing: Checkbox(
                value: currentTodo.isDone,
                onChanged: (bool? value) {
                  TodoStateHolder.of(context).update(
                    index,
                    Todo(
                      title: currentTodo.title,
                      description: currentTodo.description,
                      isDone: value!,
                    ),
                  );
                },
              ),
              onLongPress: () => TodoStateHolder.of(context).delete(index),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTodo(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
