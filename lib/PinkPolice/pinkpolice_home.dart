// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shecare/PinkPolice/add_dangerous_spot.dart';
// import 'package:shecare/PinkPolice/change_password.dart';
// import 'package:shecare/PinkPolice/verify_dangerous_spot.dart';
// import 'package:shecare/PinkPolice/view_complaint_and_take_action.dart';
// import 'package:shecare/PinkPolice/view_emergency_assist_request.dart';
// import 'package:shecare/PinkPolice/view_profile.dart';
// import 'package:shecare/Nlogin.dart';
// import 'package:shecare/login.dart';
//
// class Pinkpolice_homepage extends StatefulWidget {
//   const Pinkpolice_homepage({super.key, required this.title});
//   final String title;
//
//   @override
//   State<Pinkpolice_homepage> createState() => _Pinkpolice_homepageState();
// }
//
// class _Pinkpolice_homepageState extends State<Pinkpolice_homepage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background Image
//           Positioned.fill(
//             child: Image.asset(
//               'assets/pink.jpg', // Your background image
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Overlay for text readability
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withOpacity(0.5), // Transparent overlay
//             ),
//           ),
//           // Main content
//           Column(
//             children: [
//               // App Bar
//               AppBar(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 title: Text(
//                   widget.title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 centerTitle: true,
//                 iconTheme: const IconThemeData(color: Colors.white),
//               ),
//
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Welcome Section
//                       const Text(
//                         'Welcome, Officer',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Ready to ensure women\'s safety',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//
//                       // Quick Stats Section
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _StatCard(
//                               title: 'Emergency\nRequests',
//                               value: '12',
//                               color: Colors.red,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: _StatCard(
//                               title: 'Pending\nComplaints',
//                               value: '8',
//                               color: Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _StatCard(
//                               title: 'Dangerous\nSpots',
//                               value: '23',
//                               color: Colors.purple,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: _StatCard(
//                               title: 'Verified\nToday',
//                               value: '5',
//                               color: Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 40),
//
//                       // Quick Actions Grid
//                       const Text(
//                         'Quick Actions',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Expanded(
//                         child: GridView.count(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 16,
//                           mainAxisSpacing: 16,
//                           children: [
//                             _ActionCard(
//                               icon: Icons.emergency_rounded,
//                               title: 'Emergency\nRequests',
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => View_emergency_assist_request(title: "Emergency Assist"),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _ActionCard(
//                               icon: Icons.report_problem_rounded,
//                               title: 'View\nComplaints',
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => View_complaint_and_take_action(title: "View Complaints"),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _ActionCard(
//                               icon: Icons.warning_amber_rounded,
//                               title: 'Add Dangerous\nSpot',
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => Add_dangerous_spot(title: "Add Dangerous Spot"),
//                                   ),
//                                 );
//                               },
//                             ),
//                             _ActionCard(
//                               icon: Icons.verified_rounded,
//                               title: 'Verify\nSpots',
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => Verify_dangerous_spot(title: "Verify Dangerous Spot"),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(context),
//     );
//   }
//
//   Widget _buildDrawer(BuildContext context) {
//     return Drawer(
//       child: Stack(
//         children: [
//           // Background Image for Drawer
//           Positioned.fill(
//             child: Image.asset(
//               'assets/pink.jpg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           // Overlay
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withOpacity(0.7),
//             ),
//           ),
//           ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               // Header
//               Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.5),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundColor: Colors.white.withOpacity(0.2),
//                       child: Icon(
//                         Icons.security_rounded,
//                         size: 40,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Pink Police Officer',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       'SheCare Team',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.white70,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Menu Items
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.dashboard_rounded,
//                 title: 'Dashboard',
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 isSelected: true,
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.person_rounded,
//                 title: 'My Profile',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => View_profile(title: "My Profile"),
//                     ),
//                   );
//                 },
//               ),
//               Divider(color: Colors.white.withOpacity(0.3), height: 1),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.warning_amber_rounded,
//                 title: 'Add Dangerous Spot',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => Add_dangerous_spot(title: "Add Dangerous Spot"),
//                     ),
//                   );
//                 },
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.verified_rounded,
//                 title: 'Verify Dangerous Spot',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => Verify_dangerous_spot(title: "Verify Dangerous Spot"),
//                     ),
//                   );
//                 },
//               ),
//               Divider(color: Colors.white.withOpacity(0.3), height: 1),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.emergency_rounded,
//                 title: 'Emergency Assist',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => View_emergency_assist_request(title: "Emergency Assist"),
//                     ),
//                   );
//                 },
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.report_problem_rounded,
//                 title: 'View Complaints',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => View_complaint_and_take_action(title: "View Complaints"),
//                     ),
//                   );
//                 },
//               ),
//               Divider(color: Colors.white.withOpacity(0.3), height: 1),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.lock_rounded,
//                 title: 'Change Password',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => MyChangePasswordPage(title: "Change Password"),
//                     ),
//                   );
//                 },
//               ),
//               _buildDrawerItem(
//                 context: context,
//                 icon: Icons.logout_rounded,
//                 title: 'Logout',
//                 onTap: () {
//                   _showLogoutDialog(context);
//                 },
//                 color: Colors.red.shade300,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDrawerItem({
//     required BuildContext context,
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     bool isSelected = false,
//     Color? color,
//   }) {
//     return ListTile(
//       leading: Icon(
//         icon,
//         color: color ?? (isSelected ? Colors.white : Colors.white70),
//         size: 22,
//       ),
//       title: Text(
//         title,
//         style: TextStyle(
//           fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//           color: color ?? (isSelected ? Colors.white : Colors.white70),
//         ),
//       ),
//       trailing: isSelected
//           ? Icon(
//         Icons.circle,
//         size: 8,
//         color: Colors.white,
//       )
//           : null,
//       onTap: onTap,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//     );
//   }
//
//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.logout_rounded,
//                   size: 48,
//                   color: Colors.red,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'Logout',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Are you sure you want to logout?',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey[300],
//                           foregroundColor: Colors.black,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         child: const Text('Cancel'),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => LoginPage(),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                         ),
//                         child: const Text('Logout'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final Color color;
//
//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.color,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.9),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.black87,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _ActionCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;
//
//   const _ActionCard({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 40,
//               color: Colors.pink,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }