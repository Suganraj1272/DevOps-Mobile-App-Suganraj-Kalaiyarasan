import 'package:devops/Custom_Colors/Custom_Colors.dart';
import 'package:devops/Screens/Login_Screen.dart';
import 'package:devops/Screens/performance_Repot_chart.dart';
import 'package:devops/Screens/userlist.dart';
import 'package:devops/Sprint/Retro%20Dashboard.dart';
import 'package:devops/Sprint/sprint_plan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _drawerController =
      AdvancedDrawerController(); // Controller for the managing the drawer state....//
  int selectedPageIndex = 0; // index to track the currently selected page//

  final List<Widget> pages = [
    // list of pages displayed in the dashboard//
    PerformanceChartScreen(showSnackbar: true),
    SprintPlanScreen(),
    const Center(child: Text('Retro Dashboard Page')),
  ];

  final List<String> pageTitles = [
    // list of titles to each pages/////
    'Dashboard',
    'Sprint Plan',
    'Retro Dashboard',
  ];

  void onMenuItemSelected(int index) {
    //the menubutton profile and logout/
    setState(() {
      selectedPageIndex = index;
    });
    Navigator.pop(context);
  }

  Future<void> logout(BuildContext context) async {
    // handles user logout and clears stored credentials//
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('https://dev-devops.haroob.com/api/logout'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          String email = prefs.getString('email') ?? '';
          String password = prefs.getString('password') ?? '';
          await prefs.clear(); // Clear stored data//
          await prefs.setString('email', email);
          await prefs.setString('password', password);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    LoginScreen()), // Navigate to login screen//
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to logout')));
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No token found')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdrop: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // drawer background with gradient styling colo/
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.AppBar, AppColors.AppBar1],
          ),
        ),
      ),
      controller: _drawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 200),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 1.0),
        ],
      ),
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                // the Circular profile image in the drawer/
                width: 120,
                height: 120,
                margin: EdgeInsets.only(top: 20, bottom: 40),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/image.png'),
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            DashboardScreen()), // dashboard menu item////
                  );
                },
                leading: Icon(Icons.dashboard),
                title: Text(
                  "Dashboard",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ExpansionTile(
                // expansion tile for Sprint options//////
                leading: Icon(Icons.calendar_today),
                title: Text(
                  "Sprint",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                collapsedIconColor: Colors.white,
                iconColor: Colors.white,
                children: [
                  ListTile(
                    leading: Icon(Icons.edit_calendar),
                    title: Text(
                      "Sprint Plan",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SprintPlanScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.assessment,
                    ),
                    title: Text(
                      "Retro Dashboard",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => RetroDashboardScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.AppBar, AppColors.AppBar1],
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              actions: [
                PopupMenuButton<String>(
                  popUpAnimationStyle: AnimationStyle(
                    curve: Curves.easeInCirc,
                    duration: Duration(milliseconds: 100),
                  ),
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'userlist',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Text(
                        'Profile',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4.0),
                      child: Text(
                        'Logout',
                        style: const TextStyle(fontSize: 12.0),
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'userlist') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserDetailsScreen()),
                      );
                    } else if (value == 'logout') {
                      logout(context);
                    }
                  },
                ),
              ],
              title: Text(
                "Dashboard",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              leading: IconButton(
                color: Colors.white,
                onPressed: _handleMenuButton,
                icon: ValueListenableBuilder<AdvancedDrawerValue>(
                  valueListenable: _drawerController,
                  builder: (context, value, child) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        value.visible ? Icons.clear : Icons.menu,
                        key: ValueKey<bool>(value.visible),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        body: pages[selectedPageIndex], // display the selected page//
      ),
    );
  }

  void _handleMenuButton() {
    _drawerController
        .showDrawer(); // handle drawer opening when the menu button is pressed//
  }
}
