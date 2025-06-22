import 'dart:convert';
import 'package:devops/Custom_Colors/Custom_Colors.dart';
import 'package:devops/api_Model_Class/project_List.dart';
import 'package:devops/api_Model_Class/sprintList_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateSprintPlan extends StatefulWidget {
  const CreateSprintPlan({super.key});

  @override
  State<CreateSprintPlan> createState() => _CreateSprintPlanState();
}

class _CreateSprintPlanState extends State<CreateSprintPlan> {
  final _formKey = GlobalKey<FormState>();
  final _ticketController = TextEditingController();
  final _estimationController = TextEditingController();

  String? _selectedSprint;
  String? _selectedProject;

  List<String> _sprintOptions = [];
  List<String> _projectOptions = [];
  Map<String, int> _sprintMap = {};
  Map<String, int> _projectMap = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDropdownData();
  }

  Future<void> fetchDropdownData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Access token not found")),
      );
      return;
    }

    try {
      final sprintResponse = await http.get(
        Uri.parse('https://dev-devops.haroob.com/api/sprintList'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final projectResponse = await http.get(
        Uri.parse('https://dev-devops.haroob.com/api/projectList'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (sprintResponse.statusCode == 200 &&
          projectResponse.statusCode == 200) {
        final sprintList =
            SprintList.fromJson(json.decode(sprintResponse.body));
        final projectList =
            Projectlist.fromJson(json.decode(projectResponse.body));

        setState(() {
          List<Project> sprints = projectList.result.projects;
          sprints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          List<Sprint> sprints1 = sprintList.result.sprints;
          sprints1.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _sprintMap = {
            for (var s in sprintList.result.sprints) s.name: s.id,
          };

          _projectMap = {
            for (var p in projectList.result.projects) p.projectName: p.id,
          };

          _sprintOptions = _sprintMap.keys.toList();
          _projectOptions = _projectMap.keys.toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      focusedBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Colors.black),
      hintStyle: const TextStyle(fontSize: 11),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
    );
  }

  Future<void> _submitSprintPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Access token not found")),
      );
      return;
    }

    final url = Uri.parse("https://dev-devops.haroob.com/api/createSprintplan");

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'projectId': _projectMap[_selectedProject],
          'issueNo': _ticketController.text,
          'estimationTime': _estimationController.text,
          'sprint': _sprintMap[_selectedSprint],
        }),
      );

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sprint Plan Submitted')),
        );
      } else {
        if (response.statusCode == 400) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Bad Request: Please check the input data.')),
          );
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unauthorized: Token expired or invalid')),
          );
        } else if (response.statusCode == 500) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Server Error: Please try again later')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submission failed: ${response.body}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Create Sprint Plan',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      content: _isLoading
          ? const SizedBox(
              height: 100, child: Center(child: CircularProgressIndicator()))
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField2<String>(
                      value: _selectedSprint,
                      decoration: _inputDecoration("Sprint"),
                      items: _sprintOptions
                          .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSprint = val),
                      isExpanded: true,
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0)),
                      ),
                      validator: (val) => val == null ? 'Sprint' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField2<String>(
                      value: _selectedProject,
                      decoration: _inputDecoration("Project"),
                      items: _projectOptions
                          .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedProject = val),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4.0)),
                      ),
                      validator: (val) => val == null ? 'Project' : null,
                      isExpanded: true,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ticketController,
                      decoration: _inputDecoration("Ticket No"),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Ticket' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _estimationController,
                      decoration: _inputDecoration("Estimation Time"),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Estimation Time' : null,
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        Center(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.AppBar, AppColors.AppBar1],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ElevatedButton.icon(
              label:
                  const Text("Create ", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _submitSprintPlan();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
