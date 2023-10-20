import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: " Form Data Todos",
      home: GetDataTodos(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.purpleAccent, // Warna ungu muda
        ),
      ),
    );
  }
}

Future<List<Todo>> fetchTodos() async {
  final response =
      await http.get(Uri.parse('https://calm-plum-jaguar-tutu.cyclic.app/todos'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (data.containsKey('data')) {
      List<dynamic> todosData = data['data'];
      List<Todo> todos = todosData
          .map((item) => Todo.fromJson(item as Map<String, dynamic>))
          .toList();
      return todos;
    }
  }
  throw Exception('Failed to load Todos');
}

class Todo {
  final String id; // Add id field
  final String todoName;
  final bool isComplete;
  final String createdAt;
  final String updatedAt;

  Todo({
    required this.id,
    required this.todoName,
    required this.isComplete,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'] ?? '',
      todoName: json['todoName'] ?? '',
      isComplete: json['isComplete'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class GetDataTodos extends StatelessWidget {
  final Future<List<Todo>> Todos = fetchTodos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todos From API Willa'),
      ),
      body: Center(
        child: FutureBuilder<List<Todo>>(
          future: Todos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        'Todo Name: ${snapshot.data![index].todoName}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        'Is Complete: ${snapshot.data![index].isComplete}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        _showTodoDetails(context, snapshot.data![index]);
                      },
                    ),
                  );
                },
              );
            } else {
              return Text('No data available.');
            }
          },
        ),
      ),
    );
  }

  void _showTodoDetails(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Todo Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID: ${todo.id}'),
              Text('Todo Name: ${todo.todoName}'),
              Text('Is Complete: ${todo.isComplete}'),
              Text('Created At: ${todo.createdAt}'),
              Text('Updated At: ${todo.updatedAt}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
