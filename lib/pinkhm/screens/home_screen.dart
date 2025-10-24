import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/PinkPolice/add_dangerous_spot.dart';
import 'package:shecare/PinkPolice/change_password.dart';
import 'package:shecare/PinkPolice/verify_dangerous_spot.dart';
import 'package:shecare/PinkPolice/view_complaint_and_take_action.dart';
import 'package:shecare/PinkPolice/view_emergency_assist_request.dart';
import 'package:shecare/PinkPolice/view_profile.dart';
import 'package:shecare/Nlogin.dart';
import 'package:shecare/login.dart';

class PinkPoliceHomeScreen extends StatefulWidget {
  const PinkPoliceHomeScreen({super.key});

  @override
  State<PinkPoliceHomeScreen> createState() => _PinkPoliceHomeScreenState();
}

class _PinkPoliceHomeScreenState extends State<PinkPoliceHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFE3EC),
                    Color(0xFFFFC2D6),
                    Color(0xFFFF8FB1),
                  ],
                ),
              ),
            ),
          ),

          // Scrollable main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Colors.black),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const Text(
                          "SheCare",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Welcome section
                    const Text(
                      'Welcome Back,',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'Police Officer!',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ensuring safety for women in our community',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Quick Stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Emergency\nRequests',
                            value: '12',
                            icon: Icons.emergency_rounded,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Pending\nComplaints',
                            value: '8',
                            icon: Icons.report_problem_rounded,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Dangerous\nSpots',
                            value: '23',
                            icon: Icons.location_pin,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Verified\nToday',
                            value: '5',
                            icon: Icons.verified_rounded,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quick Actions Grid
                    SizedBox(
                      height: 400,
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _ActionCard(
                            icon: Icons.emergency_rounded,
                            title: 'Emergency\nRequests',
                            subtitle: 'View urgent requests',
                            color: Colors.red,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => View_emergency_assist_request(title: "Emergency Assist"),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.report_problem_rounded,
                            title: 'View\nComplaints',
                            subtitle: 'Check complaints',
                            color: Colors.orange,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => View_complaint_and_take_action(title: "View Complaints"),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.warning_amber_rounded,
                            title: 'Add Dangerous\nSpot',
                            subtitle: 'Report new spot',
                            color: Colors.purple,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Add_dangerous_spot(title: "Add Dangerous Spot"),
                                ),
                              );
                            },
                          ),
                          _ActionCard(
                            icon: Icons.verified_rounded,
                            title: 'Verify\nSpots',
                            subtitle: 'Verify locations',
                            color: Colors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Verify_dangerous_spot(title: "Verify Dangerous Spot"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
    );
  }

  // Drawer builder
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFF8FB1),
                  Color(0xFFFFC2D6),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 40,
                    color: Color(0xFFFF8FB1),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pink Police Officer',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'SheCare Security Team',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          _buildDrawerItem(
            icon: Icons.dashboard_rounded,
            title: 'Dashboard',
            isSelected: true,
            onTap: () => Navigator.pop(context),
          ),
          _buildDrawerItem(
            icon: Icons.person_rounded,
            title: 'My Profile',
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => View_profile(title: "My Profile"))),
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.warning_amber_rounded,
            title: 'Add Dangerous Spot',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Add_dangerous_spot(title: "Add Dangerous Spot")),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.verified_rounded,
            title: 'Verify Dangerous Spot',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Verify_dangerous_spot(title: "Verify Dangerous Spot")),
            ),
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.emergency_rounded,
            title: 'Emergency Assist',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => View_emergency_assist_request(title: "Emergency Assist")),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.report_problem_rounded,
            title: 'View Complaints',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => View_complaint_and_take_action(title: "View Complaints")),
            ),
          ),
          const Divider(height: 20, indent: 16, endIndent: 16),
          _buildDrawerItem(
            icon: Icons.lock_rounded,
            title: 'Change Password',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyChangePasswordPage(title: "Change Password")),
            ),
          ),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: 'Logout',
            color: Colors.red,
            onTap: () => _showLogoutDialog(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFE3EC) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: color ?? (isSelected ? const Color(0xFFFF8FB1) : Colors.grey[700]),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: color ?? (isSelected ? const Color(0xFFFF8FB1) : Colors.grey[700]),
            fontSize: 16,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.circle, size: 8, color: Color(0xFFFF8FB1))
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                  ),
                  child: const Icon(Icons.logout_rounded, size: 30, color: Colors.red),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logout',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to logout?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
