import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_todo_list_app/add_todo_page.dart';
import 'package:http/http.dart' as http;

class ToDoList extends StatefulWidget {
  const ToDoList({
    super.key,
  });

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  late Future<List<dynamic>> futureItems;

  @override
  void initState() {
    super.initState();
    futureItems = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        toolbarHeight:
            70, // Increases the height of the AppBar for a bolder appearance
        backgroundColor:
            Colors.transparent, // Transparent background to apply a gradient
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
        title: const Text(
          "TODO List",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26, // Slightly smaller but still bold
            fontWeight: FontWeight.bold,
            letterSpacing:
                1.5, // Adds a subtle spacing between letters for a modern touch
          ),
        ),
        centerTitle: true, // Centers the title
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddTODO()));
        },
        label: const Text(
          "Add Task",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final items = snapshot.data!;
            return RefreshIndicator(
              onRefresh: fetchData,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final id = item['_id'] as String;
                  return Card(
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                      vertical: MediaQuery.of(context).size.height * 0.01,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.blue.shade100, width: 1.5),
                    ),
                    elevation: 4, // Gives it a shadow effect
                    child: ListTile(
                      contentPadding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04),
                      leading: CircleAvatar(
                        child: Text("${index + 1}"),
                      ),
                      title: Text(
                        item['title'].toString(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width *
                              0.05, // Responsive title size
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      subtitle: Text(
                        item['description'].toString(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width *
                              0.04, // Responsive subtitle size
                          color: Colors.grey.shade700,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            navigatetoEditPAge(item);
                          } else if (value == 'delete') {
                            deleteByID(id);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                const SizedBox(width: 8),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.grey[100],
                        elevation: 5,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  Future<List<dynamic>> fetchData() async {
    final response = await http
        .get(Uri.parse('https://api.nstack.in/v1/todos?page=1&limit=10'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['items'];
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> deleteByID(String id) async {
    final response =
        await http.delete(Uri.parse('https://api.nstack.in/v1/todos/$id'));
    if (response.statusCode == 200) {
      setState(() {
        futureItems = fetchData();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete task')),
      );
    }
  }

  void navigatetoEditPAge(Map item) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AddTODO(todo: item)));
  }
}
