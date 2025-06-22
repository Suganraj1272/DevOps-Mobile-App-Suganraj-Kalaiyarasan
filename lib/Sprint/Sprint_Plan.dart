// ignore_for_file: library_prefixes, sized_box_for_whitespace, deprecated_member_use

import 'dart:convert';
import 'package:devops/Custom_Colors/Custom_Colors.dart';
import 'package:devops/Sprint/createSprint_plan.dart';
import 'package:devops/api_Model_Class/project_List.dart';
import 'package:devops/api_Model_Class/sprintList_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devops/api_Model_Class/SprintPlanList_model.dart'
    as SprintPlanModel;
import 'package:dropdown_button2/dropdown_button2.dart';

class SprintPlanScreen extends StatefulWidget {
  const SprintPlanScreen({super.key});

  @override
  State<SprintPlanScreen> createState() => _SprintPlanScreenState();
}

class _SprintPlanScreenState extends State<SprintPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSprint;
  String? selectedProject;
  final TextEditingController _ticketNoController = TextEditingController();
  String? selectedStatus;
  String? selectedCompanyStatus;
  DateTime? selectedDate;

  List<String> _sprintOptions = [];
  List<String> _projectOptions = [];

  final List<String> statusList = ['Completed', 'Not Completed', 'On Hold'];
  final List<String> companyStatusList = ['Completed', 'Not Completed'];

  List<SprintPlanModel.Result> _allSprintPlanList = [];
  List<SprintPlanModel.Result> _filteredSprintPlanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchSprintPlans();
    fetchProjects();
    _loadData();
    _ticketNoController.addListener(_applyFilters);
  }

  Future<void> _loadData() async {
    await Future.wait(
        [fetchSprintPlans(), fetchProjects(), _fetchSprintPlans()]);
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _ticketNoController.dispose();
    super.dispose();
  }

  Future<void> fetchSprintPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('https://dev-devops.haroob.com/api/sprintList'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sprintList = SprintList.fromJson(data);
        final sprintNames =
            sprintList.result.sprints.map((sprint) => sprint.name).toList();

        setState(() {
          List<Sprint> sprints = sprintList.result.sprints;
          sprints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _sprintOptions = sprintNames;
          if (_sprintOptions.isNotEmpty) {
            selectedSprint = _sprintOptions.last;
          }
        });
      } else {
        debugPrint('Failed to load sprint list: ${response.body}');
      }
    } catch (e) {
      debugPrint('Sprint list error: $e');
    }
  }

  Future<void> fetchProjects() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final response = await http.get(
        Uri.parse('https://dev-devops.haroob.com/api/projectList'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final projectList = Projectlist.fromJson(data);
        setState(() {
          List<Project> sprints = projectList.result.projects;
          sprints.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _projectOptions = projectList.result.projects
              .map((project) => project.projectName)
              .toList();
        });
      } else {
        debugPrint('Failed to load project list: ${response.body}');
      }
    } catch (e) {
      debugPrint('Project list error: $e');
    }
  }

  Future<void> _fetchSprintPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.post(
      Uri.parse('https://dev-devops.haroob.com/api/sprintPlanList'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final sprintPlanList = SprintPlanModel.SprintPlanList.fromJson(data);
      _allSprintPlanList = sprintPlanList.result;
      _filteredSprintPlanList = List.from(_allSprintPlanList);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredSprintPlanList = _allSprintPlanList.where((plan) {
        final sprintMatch =
            selectedSprint == null || plan.sprintName == selectedSprint;
        final projectMatch =
            selectedProject == null || plan.projectName == selectedProject;
        final ticketMatch = _ticketNoController.text.isEmpty ||
            plan.ticketNo
                .toLowerCase()
                .contains(_ticketNoController.text.toLowerCase());
        return sprintMatch && projectMatch && ticketMatch;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Center(
      child: Container(
        width: 230,
        child: TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 12),
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            labelText: label,
            labelStyle: const TextStyle(
                fontSize: 12, color: Colors.black, fontWeight: FontWeight.bold),
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
    required String hint,
  }) {
    return Container(
        width: 230,
        child: DropdownButtonFormField2<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black)),
            labelText: label,
            labelStyle: TextStyle(
                fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          isExpanded: true,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              alignment: Alignment.topLeft,
              value: item,
              child: Text(item.toString(), style: TextStyle(fontSize: 10)),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownStyleData: DropdownStyleData(
            maxHeight: 200,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
          ),
        ));
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sprint Plan',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      color: AppColors.AppBar),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "New Planning",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.AppBar,
                                          AppColors.AppBar1,
                                        ],
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) =>
                                              const CreateSprintPlan(),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    _buildDropdown(
                                      label: 'Sprint*',
                                      value: selectedSprint,
                                      items: _sprintOptions,
                                      onChanged: (val) {
                                        setState(() => selectedSprint = val);
                                        _applyFilters();
                                      },
                                      hint: "Select",
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDropdown(
                                      label: 'Project*',
                                      value: selectedProject,
                                      items: _projectOptions,
                                      onChanged: (val) {
                                        setState(() => selectedProject = val);
                                        _applyFilters();
                                      },
                                      hint: "Select",
                                    ),
                                    const SizedBox(height: 20),
                                    _buildTextField(
                                      controller: _ticketNoController,
                                      label: 'Ticket No*',
                                      hint: 'Search',
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDropdown(
                                      label: 'Status*',
                                      value: selectedStatus,
                                      items: statusList,
                                      onChanged: (val) =>
                                          setState(() => selectedStatus = val),
                                      hint: "Select",
                                    ),
                                    const SizedBox(height: 20),
                                    _buildDropdown(
                                      label: 'Company O/P Status*',
                                      value: selectedCompanyStatus,
                                      items: companyStatusList,
                                      onChanged: (val) => setState(
                                          () => selectedCompanyStatus = val),
                                      hint: "Select",
                                    ),
                                    const SizedBox(height: 20),
                                    TextButton.icon(
                                      onPressed: () => _selectDate(context),
                                      icon: const Icon(Icons.calendar_today,
                                          size: 16),
                                      label: Text(
                                        selectedDate == null
                                            ? 'Select Date'
                                            : DateFormat('dd-MM-yyyy')
                                                .format(selectedDate!),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.centerLeft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'Sprint Plan List',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Scrollbar(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade400),
                                        ),
                                        headingRowColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) => AppColors.AppBar),
                                        headingRowHeight: 40,
                                        dataRowHeight: 36,
                                        columnSpacing: 20,
                                        dividerThickness: 1,
                                        columns: const [
                                          DataColumn(
                                              label: Text('#',
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                          DataColumn(
                                              label: Text('Sprint',
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                          DataColumn(
                                              label: Text('Project',
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                          DataColumn(
                                              label: Text('Ticket No',
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                          DataColumn(
                                              label: Text('Estimation Time',
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                          DataColumn(
                                              label: Text('Spent Time',
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                          DataColumn(
                                            label: Text(
                                              'Status',
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: _filteredSprintPlanList
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final index = entry.key;
                                          final plan = entry.value;
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(
                                                  (index + 1).toString(),
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                              DataCell(Text(plan.sprintName,
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                              DataCell(Text(plan.projectName,
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                              DataCell(Text(plan.ticketNo,
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                              DataCell(Text(plan.estimationTime,
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                              DataCell(Text(
                                                  plan.spentTime ?? '0',
                                                  style:
                                                      TextStyle(fontSize: 12))),
                                              DataCell(
                                                Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: (plan.status
                                                                .toLowerCase() ==
                                                            'completed')
                                                        ? Colors.green
                                                        : Colors.red,
                                                    shape: BoxShape.rectangle,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Builder(
                                    builder: (context) {
                                      double totalEstimation = 0;
                                      double totalSpent = 0;

                                      for (var plan
                                          in _filteredSprintPlanList) {
                                        totalEstimation += double.tryParse(
                                                plan.estimationTime) ??
                                            0;
                                        totalSpent += double.tryParse(
                                                plan.spentTime ?? '0') ??
                                            0;
                                      }

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(left: 12.0),
                                        child: Text(
                                          'Total Hours: ${totalEstimation.toStringAsFixed(2)} hrs                                    Total Spent Time: ${totalSpent.toStringAsFixed(2)} hrs',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
