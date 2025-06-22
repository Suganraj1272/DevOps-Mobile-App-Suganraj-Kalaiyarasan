import 'package:devops/Custom_Colors/Custom_Colors.dart';
import 'package:devops/api_Model_Class/userlist_model.dart' as userlistApi;
import 'package:devops/api_Model_Class/userlist_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

//api using the stored token and email//
class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<userlistApi.User?>
      _userFuture; // Future that will hold the user data//
  final String apiUrl = 'https://dev-devops.haroob.com/api/userList';

  Future<userlistApi.User?> fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final email = prefs.getString('email');
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Decode the response and find the user with matching email//
      final json = jsonDecode(response.body);
      final userList = Userlist1.fromJson(json).result.userList;
      return userList.firstWhere((user) => user.email == email);
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<void> _onRefresh() async {
    /// Pull to refresh function that reloads the user data//
    setState(() {
      _userFuture = fetchUser();
    });
  }

  @override
  void initState() {
    super.initState();
    _userFuture = fetchUser(); // Initialize data fetching//
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          "Profile Information",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.AppBar, AppColors.AppBar1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<User?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No user data available"));
          } else {
            final user = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 30),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundColor: Color(0xFFE6E6E6),
                            child: Icon(Icons.person,
                                size: 48, color: Colors.black45),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.AppBar,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(thickness: 1, color: Colors.grey),
                          const SizedBox(height: 16),
                          // User details fields//
                          buildInfoRow("Gender", user.gender.name),
                          buildInfoRow("Status", user.status.name),
                          buildInfoRow(
                              "Login Access", user.loginAccess ? "Yes" : "No"),
                          if (user.redmineUserId != null)
                            buildInfoRow("Redmine User ID",
                                user.redmineUserId.toString()),
                          if (user.giteaUserId != null)
                            buildInfoRow(
                                "Gitea User ID", user.giteaUserId.toString()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
