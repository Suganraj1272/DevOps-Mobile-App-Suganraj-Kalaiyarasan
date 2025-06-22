// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:devops/Custom_Colors/Custom_Colors.dart';
import 'package:devops/api_Model_Class/sprintlist_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RetroDashboardScreen extends StatefulWidget {
  const RetroDashboardScreen({super.key});

  @override
  _RetroDashboardScreenState createState() => _RetroDashboardScreenState();
}

class _RetroDashboardScreenState extends State<RetroDashboardScreen> {
  List<Sprint> _sprintList = [];
  Sprint? _fromSprint;
  Sprint? _toSprint;
  String? userName;
  int _overallPercentage = 0;
  int _taskCompletion = 0;
  int _quality = 0;
  int _compliance = 0;
  bool _checklist1 = false;
  bool _checklist2 = false;

  @override
  void initState() {
    super.initState();
    _fetchSprintList();
    getUserName();
  }

  Future<void> _fetchSprintList() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse('https://dev-devops.haroob.com/api/sprintList'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final sprintList = SprintList.fromJson(data);
      setState(() {
        List<Sprint> sprints = sprintList.result.sprints;
        sprints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _sprintList = sprintList.result.sprints;
        if (_sprintList.isNotEmpty) {
          _fromSprint = _sprintList.first;
          _toSprint = _sprintList.last;
          _loadMetrics();
        }
      });
    } else {
      if (kDebugMode) print('Failed to fetch sprints');
    }
  }

  Future<void> _loadMetrics() async {
    if (_fromSprint == null || _toSprint == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getString('user_id');

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID is missing. Please log in again.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('https://dev-devops.haroob.com/api/sprintRetroList'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'from_sprint_id': _fromSprint!.id,
        'to_sprint_id': _toSprint!.id,
        'userId': userId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['result'];

      setState(() {
        _overallPercentage = result['overAllTotalPercentage'] ?? 0;
        _taskCompletion = result['totalTaskCompletionPercentage'] ?? 0;
        _quality = result['totalQualityPercentage'] ?? 0;
        _compliance = result['totalCompletionPercentage'] ?? 0;
      });
    } else {
      if (kDebugMode) {
        print('Failed to load metrics');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      try {
        final errorResponse = json.decode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Unknown error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMessage')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load metrics')),
        );
      }
    }
  }

  Future<void> _createRetroScore() async {
    if (!_checklist1 || !_checklist2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete both checklist items')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse(
          'https://dev-devops.haroob.com/api/updateRetroChecklist/773?from_sprint_id=${_fromSprint!.id}&to_sprint_id=${_toSprint!.id}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retro Score Created Successfully')),
      );
    } else {
      try {
        final errorResponse = json.decode(response.body);
        final errorMessage =
            errorResponse['message'] ?? 'Unknown error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create retro score: $errorMessage')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create retro score')),
        );
      }
    }
  }

  Future<void> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('email');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Retro Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.AppBar, AppColors.AppBar1],
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: _sprintList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchSprintList,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi $userName !',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Welcome to the Retro Dashboard!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField2<Sprint>(
                            decoration: InputDecoration(
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              labelText: "From Sprint",
                              labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            value: _fromSprint,
                            items: _sprintList.map((s) {
                              return DropdownMenuItem<Sprint>(
                                value: s,
                                child: Text(
                                  s.name,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _fromSprint = val);
                              _loadMetrics();
                            },
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0)),
                            ),
                            isExpanded: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField2<Sprint>(
                            decoration: InputDecoration(
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)),
                              labelText: "To Sprint",
                              labelStyle: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            value: _toSprint,
                            items: _sprintList.map((s) {
                              return DropdownMenuItem<Sprint>(
                                value: s,
                                child: Text(
                                  s.name,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _toSprint = val);
                              _loadMetrics();
                            },
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0)),
                            ),
                            isExpanded: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 20,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        Card(
                          title: 'Total Score',
                          value: '$_overallPercentage%',
                          icon: Icons.insert_chart,
                        ),
                        Card(
                          title: 'Task Completion',
                          value: '$_taskCompletion%',
                          icon: Icons.check_circle_outline,
                        ),
                        Card(
                          title: 'Quality',
                          value: '$_quality%',
                          icon: Icons.thumb_up_alt_outlined,
                        ),
                        Card(
                          title: 'Compliance',
                          value: '$_compliance%',
                          icon: Icons.rule_folder,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CheckboxListTile(
                      title: const Text(
                        "Collaboration",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      value: _checklist1,
                      onChanged: (val) => setState(() => _checklist1 = val!),
                    ),
                    CheckboxListTile(
                      title: const Text(
                        "Privacy & Policy",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      value: _checklist2,
                      onChanged: (val) => setState(() => _checklist2 = val!),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _createRetroScore,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.AppBar, AppColors.AppBar1],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Container(
                            height: 50,
                            width: 200,
                            alignment: Alignment.center,
                            child: const Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
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
}

class Card extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const Card({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.AppBar.withOpacity(0.8),
            AppColors.AppBar1.withOpacity(0.9)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
