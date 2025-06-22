// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:devops/api_Model_Class/SprintPlanList_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SprintPlanListScreen extends StatefulWidget {
  const SprintPlanListScreen({super.key});

  @override
  _SprintPlanListScreenState createState() => _SprintPlanListScreenState();
}

class _SprintPlanListScreenState extends State<SprintPlanListScreen> {
  late Future<SprintPlanList> _futureSprintPlans;

  @override
  void initState() {
    super.initState();
    _futureSprintPlans = SprintPlanService().fetchSprintPlans();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SprintPlanList>(
      future: _futureSprintPlans,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final plans = snapshot.data!.result;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Sprint Plan List',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 40,
                        columns: [
                          DataColumn(label: Text('Ticket No')),
                          DataColumn(label: Text('Sprint Name')),
                          DataColumn(label: Text('Est. Time')),
                          DataColumn(label: Text('Spent Time')),
                          DataColumn(label: Text('Project')),
                        ],
                        rows: plans.map((plan) {
                          return DataRow(cells: [
                            DataCell(Text(plan.ticketNo)),
                            DataCell(Text(plan.sprintName)),
                            DataCell(Text(plan.estimationTime)),
                            DataCell(Text(plan.spentTime ?? '0')),
                            DataCell(Text(plan.projectName)),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SprintPlanService {
  static const String apiUrl =
      'https://dev-devops.haroob.com/api/sprintPlanList';

  Future<SprintPlanList> fetchSprintPlans() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      return SprintPlanList.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sprint plans: ${response.statusCode}');
    }
  }
}
