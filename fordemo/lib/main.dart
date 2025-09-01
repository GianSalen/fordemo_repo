import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String initialText = "Loading...";
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _updateUsernameController = TextEditingController();
  
  Map<String, dynamic>? postResponse;
  Map<String, dynamic>? getResponse;
  String? updateMessage;
  List<dynamic>? allUsers;
  String? userCode;
  String? userId;
  
  bool showInitial = true;
  bool showPost = false;
  bool showGet = false;
  bool showUpdate = false;
  bool showAllUsers = false;

  final String baseUrl = "https://fordemo-ot4j.onrender.com";

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          initialText = response.body.trim();
        });
      } else {
        setState(() {
          initialText = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        initialText = "Failed to load: $e";
      });
    }
  }

  Future<void> postUser() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/users"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          postResponse = data;
          userCode = data['code']?.toString();
          showInitial = false;
          showPost = true;
        });
      }
    } catch (e) {
      setState(() {
        postResponse = {'message': 'Failed to post: $e'};
        showInitial = false;
        showPost = true;
      });
    }
  }

  Future<void> getUserByCode() async {
    if (userCode == null) return;
    
    try {
      final response = await http.get(Uri.parse("$baseUrl/users/$userCode"));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          getResponse = data;
          userId = data['id']?.toString();
          showPost = false;
          showGet = true;
        });
      }
    } catch (e) {
      setState(() {
        getResponse = {'message': 'Failed to get user: $e'};
        showPost = false;
        showGet = true;
      });
    }
  }

  Future<void> updateUsername() async {
    if (userId == null) return;
    
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/users/$userId"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _updateUsernameController.text,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          updateMessage = data['message'];
          showGet = false;
          showUpdate = true;
        });
      }
    } catch (e) {
      setState(() {
        updateMessage = 'Failed to update: $e';
        showGet = false;
        showUpdate = true;
      });
    }
  }

  Future<void> getAllUsers() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/users"));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allUsers = data['users'];
          showUpdate = false;
          showAllUsers = true;
        });
      }
    } catch (e) {
      setState(() {
        allUsers = [];
        showUpdate = false;
        showAllUsers = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PT03")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              if (showInitial) _buildInitialView(),
              if (showPost) _buildPostView(),
              if (showGet) _buildGetView(),
              if (showUpdate) _buildUpdateView(),
              if (showAllUsers) _buildAllUsersView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return Column(
      children: [
        Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              initialText,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.indigo[900],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: "Username",
            prefixIcon: Icon(Icons.person),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: "Password",
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: postUser,
          child: Text("Enter"),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _buildPostView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Post Response:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text("Message: ${postResponse?['message'] ?? 'N/A'}"),
            Row(
              children: [
                Text("Code: ${postResponse?['code'] ?? 'N/A'}"),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: getUserByCode,
                  child: Text("Get User"),
                ),
              ],
            ),
            Text("ID: ${postResponse?['id'] ?? 'N/A'}"),
          ],
        ),
      ),
    );
  }

  Widget _buildGetView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Get Response:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text("Message: ${getResponse?['message'] ?? 'N/A'}"),
            Text("ID: ${getResponse?['id'] ?? 'N/A'}"),
            SizedBox(height: 20),
            TextField(
              controller: _updateUsernameController,
              decoration: InputDecoration(
                labelText: "New Username",
                prefixIcon: Icon(Icons.edit),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: updateUsername,
              child: Text("Update Username"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Update Response:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Text("Message: ${updateMessage ?? 'N/A'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: getAllUsers,
              child: Text("Get All Users"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllUsersView() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("First 5 Users:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            if (allUsers != null && allUsers!.isNotEmpty)
            ...allUsers!.take(5).map((user) => Card(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ID: ${user['id'] ?? 'N/A'}"),
                    Text("Code: ${user['code'] ?? 'N/A'}"),
                    Text("Username: ${user['username'] ?? 'N/A'}"),
                    Text("Number5: ${user['number5'] ?? 'N/A'}"),
                    Text("__v: ${user['__v'] ?? 'N/A'}"),
                  ],
                ),
              ),
            )).toList()
            else
              Text("No users found"),
          ],
        ),
      ),
    );
  }
}