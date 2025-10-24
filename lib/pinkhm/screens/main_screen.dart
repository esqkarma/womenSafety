import 'package:flutter/material.dart';
import 'package:shecare/PinkPolice/change_password.dart';
import 'package:shecare/PinkPolice/view_complaint_and_take_action.dart';
import 'package:shecare/PinkPolice/view_profile.dart';
import 'package:shecare/pinkhm/components/bottom_nav_bar.dart';
import 'package:shecare/pinkhm/constants.dart';
import 'package:shecare/pinkhm/screens/cart_screen.dart';
import 'package:shecare/pinkhm/screens/home_screen.dart';
import 'package:shecare/Nlogin.dart';
import 'package:shecare/login.dart';
import 'package:shecare/user/view_and_edit_profile.dart';
import 'package:shecare/user/view_safe_point.dart';

class PinkMainScreen extends StatefulWidget {
  const PinkMainScreen({Key? key}) : super(key: key);

  static const String id = 'PinkMainScreen';

  @override
  State<PinkMainScreen> createState() => _PinkMainScreenState();
}

class _PinkMainScreenState extends State<PinkMainScreen> {
  int selectedIndex = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0.0,
      //   leadingWidth: 0,
      //   automaticallyImplyLeading: false,
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       // GestureDetector(
      //       //   child: CircleAvatar(
      //       //     backgroundColor: kDarkGreenColor,
      //       //     radius: 22.0,
      //       //     backgroundImage: const AssetImage('images/Dhairye.jpg'),
      //       //   ),
      //       //   onTap: () {},
      //       // ),
      //       Text("SheCare", style: TextStyle(
      //         color: Colors.black,
      //         fontSize: 24.0,
      //         fontWeight: FontWeight.w600,
      //       ),),
      //
      //     ],
      //   ),
      // ),
      // bottomNavigationBar: CustomBottomNavBar(
      //   selectedIndex: selectedIndex,
      //   selectedColor: kDarkGreenColor,
      //   unselectedColor: kSpiritedGreen,
      //   onTapped: (index) {
      //
      //     // if(index==1)
      //     //   {
      //     //     Navigator.push(context, MaterialPageRoute(
      //     //       builder: (context) => View_complaint_and_take_action(title: "View Complaints"),));
      //     //   }
      //     if(index==1)
      //       {
      //         Navigator.push(context, MaterialPageRoute(
      //           builder: (context) => MyChangePasswordPage(title: "Change Password"),));
      //       }
      //     else if(index==2)
      //       {
      //         Navigator.push(context, MaterialPageRoute(
      //           builder: (context) => View_profile(title: "Profile"),));
      //       }
      //
      //
      //     setState(() {
      //       selectedIndex = index;
      //     });
      //   },
      //   items: const [
      //     Icon(Icons.home),
      //     // Icon(Icons.image_search_outlined),
      //     Icon(Icons.lock),
      //     Icon(Icons.person),
      //   ],
      // ),
      body: PinkPoliceHomeScreen(),

    );
  }
}
