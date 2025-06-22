import 'dart:convert';
import 'package:devops/Custom_Colors/Custom_Colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PerformanceChartScreen extends StatefulWidget {
  final bool showSnackbar;
  const PerformanceChartScreen({super.key, required this.showSnackbar});

  @override
  State<PerformanceChartScreen> createState() => _PerformanceChartScreenState();
}

class _PerformanceChartScreenState extends State<PerformanceChartScreen> {
  // State variables//
  bool isLoading = true;
  String errorMessage = '';
  double totalEstimated = 0.0;
  double totalCompleted = 0.0;
  List<BarChartGroupData> barChartData = [];
  List<String> sprintLabels = [];
  final Color completedColor =
      Color(0XffFFD0DA); //Colors for bar and pie charts//
  final Color estimatedColor = Color(0xffFF7290);

  @override
  void initState() {
    super.initState();
    _fetchSprintPlanData(); // fetch data when screen initializes//
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showSnackbar) {
        ScaffoldMessenger.of(context).showSnackBar(
          // Show snackbar //
          SnackBar(
            content: const Text('Welcome to DevOps!'),
            backgroundColor: AppColors.AppBar,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _onRefresh() async {
    // pull to refresh functionality//
    await _fetchSprintPlanData();
  }

  Future<void> _fetchSprintPlanData() async {
    // api call to fetch sprint plan data//
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        // Check for token presence//
        setState(() {
          errorMessage = "Authorization token not found.";
          isLoading = false;
        });
        return;
      }

      const String apiUrl = 'https://dev-devops.haroob.com/api/sprintPlanList';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> sprintPlans = data['result'];

        Map<String, Map<String, double>> groupedData =
            {}; // grouping data by sprint names ///

        for (final item in sprintPlans) {
          final String sprintName = item['sprint_name'] ?? 'Unnamed Sprint';
          final double estimated =
              double.tryParse(item['estimation_time'] ?? '0') ?? 0.0;
          final double completed =
              double.tryParse(item['spent_time'] ?? '0') ?? 0.0;

          if (!groupedData.containsKey(sprintName)) {
            groupedData[sprintName] = {
              'estimated': 0.0,
              'completed': 0.0,
            };
          }
          // Sum up estimated and completed times per sprint
          groupedData[sprintName]!['estimated'] =
              groupedData[sprintName]!['estimated']! + estimated;
          groupedData[sprintName]!['completed'] =
              groupedData[sprintName]!['completed']! + completed;
        }
        // chart data /......
        List<BarChartGroupData> chartData = [];
        List<String> labels = [];
        double estimatedSum = 0.0;
        double completedSum = 0.0;
        int index = 0;

        groupedData.forEach((sprint, times) {
          // Convert grouped data into chart format//
          double estimated = times['estimated']!;
          double completed = times['completed']!;

          estimatedSum += estimated;
          completedSum += completed;

          chartData.add(
            BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: estimated,
                  color: estimatedColor,
                  width: 10,
                  borderRadius: BorderRadius.circular(6),
                ),
                BarChartRodData(
                  toY: completed,
                  color: completedColor,
                  width: 10,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          );

          labels.add(sprint);
          index++;
        });

        setState(() {
          // Update UI with chart data//
          barChartData = chartData;
          sprintLabels = labels;
          totalEstimated = estimatedSum;
          totalCompleted = completedSum;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage =
              'Error ${response.statusCode}: ${response.reasonPhrase}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Failed to load data: $e";
        isLoading = false;
      });
    }
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    // X axis label widget//
    if (value.toInt() >= 0 && value.toInt() < sprintLabels.length) {
      return SideTitleWidget(
        meta: meta,
        space: 8,
        child: Text(
          sprintLabels[value.toInt()],
          style: const TextStyle(fontSize: 7, color: Colors.black87,fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget leftTitles(double value, TitleMeta meta) {
    // Y axis label widget//
    return Text(
      value.toStringAsFixed(0),
      style: const TextStyle(fontSize: 12, color: Colors.black87),
    );
  }

  Widget buildBarChartCard() {
    // Widget for the bar chart card//
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: const Text(
              "Sprint Plan Vs Completion",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: barChartData,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 5,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black, width: 1),
                    bottom: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: leftTitles,
                      reservedSize: 40,
                      interval: 25,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: bottomTitles,
                      reservedSize: 42,
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.white,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = rodIndex == 0 ? 'Estimated' : 'Completed';
                      return BarTooltipItem(
                        '$label: ${rod.toY}',
                        const TextStyle(color: Colors.black),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              LegendItem(color: Color(0xffFF7290), label: "Estimated"),
              SizedBox(width: 20),
              LegendItem(color: Color(0XffFFD0DA), label: "Completed"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPieChartCard() {
    // Widget for the pie chart card//
    double incomplete =
        (totalEstimated - totalCompleted).clamp(0, totalEstimated);
    double completedPercentage =
        totalEstimated == 0 ? 0 : (totalCompleted / totalEstimated) * 100;

    double total = totalEstimated + totalCompleted;
    double estimatedPercentage =
        total == 0 ? 0 : (totalEstimated / total) * 100;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Overall Sprint Task Completion",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      startDegreeOffset: 180,
                      sectionsSpace: 4,
                      centerSpaceRadius: 60,
                      sections: [
                        PieChartSectionData(
                          value: totalCompleted,
                          color: Color(0XffFFD0DA),
                          title: '',
                          radius: 50,
                        ),
                        PieChartSectionData(
                          value: incomplete,
                          color: Color(0xffFF7290),
                          title: '',
                          radius: 50,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${completedPercentage.toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Text(
              "Estimated: ${estimatedPercentage.toStringAsFixed(1)}%",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                LegendItem(color: Color(0XffFFD0DA), label: "Completed Task"),
                SizedBox(width: 20),
                LegendItem(color: Color(0xffFF7290), label: "Estimated"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading//....
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) // Show error Message//....
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        buildPieChartCard(),
                        buildBarChartCard(),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class LegendItem extends StatelessWidget {
  // Custom widget for chart legends//
  final Color color;
  final String label;

  const LegendItem({
    super.key,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
