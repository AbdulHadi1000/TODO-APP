import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_todo_list_app/to_do_list.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class AddTODO extends StatefulWidget {
  final Map? todo;

  const AddTODO({super.key, this.todo});

  @override
  State<AddTODO> createState() => _AddTODOState();
}

class _AddTODOState extends State<AddTODO> {
  TextEditingController task = TextEditingController();
  TextEditingController description = TextEditingController();
  bool isEdit = true;

  @override
  void initState() {
    if (widget.todo != null) {
      isEdit = true;
      task.text = widget.todo?['title'] ?? '';
      description.text = widget.todo?['description'] ?? '';
    } else {
      isEdit = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          isEdit ? "Edit TODO" : "Add TODO",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold, // Bold text for emphasis
          ),
        ),
        backgroundColor:
            Colors.transparent, // Use a transparent background for gradient
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent], // Gradient color
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5, // Shadow effect
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Task",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                controller: task,
                decoration: InputDecoration(
                  hintText: "Task",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              const Text(
                "Description",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextFormField(
                minLines: 5,
                maxLines: 8,
                controller: description,
                decoration: InputDecoration(
                  hintText: "Description",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.04),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 2.0),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              InkWell(
                onTap: () {
                  if (isEdit) {
                    updateData();
                  } else {
                    submitData();
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      isEdit ? "Update" : "Submit",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitData() async {
    final todoTask = task.text;
    final taskDescription = description.text;
    final body = {
      "title": todoTask,
      "description": taskDescription,
      "is_completed": false
    };
    Response response = await http.post(
        Uri.parse(
          'https://api.nstack.in/v1/todos',
        ),
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'});
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      task.text = "";
      description.text = '';

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Task Crearted Successfully")));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ToDoList()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Task Creartion Failed"),
        backgroundColor: Colors.red,
      ));
    }
  }

  void updateData() async {
    final todo = widget.todo;
    if (todo == null) {
      print("You can not edit");
      return;
    }
    final id = todo['_id'];

    final todoTask = task.text;
    final taskDescription = description.text;
    final body = {
      "title": todoTask,
      "description": taskDescription,
      "is_completed": false
    };

    Response response = await http.put(
      Uri.parse('https://api.nstack.in/v1/todos/$id'),
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    print(response.statusCode);
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task Updated Successfully")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ToDoList()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Task Upgradation Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
