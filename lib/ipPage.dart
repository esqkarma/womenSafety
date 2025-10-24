import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shecare/login.dart';
import 'package:shecare/phoneMotion.dart';
import 'package:shecare/pinkhm/screens/home_screen.dart';
import 'package:shecare/pinkhm/screens/main_screen.dart';
import 'package:shecare/sos_service.dart';
import 'package:shecare/user/home_screen.dart';

class IpPage extends StatefulWidget {
  const IpPage({super.key});


  @override
  State<IpPage> createState() => _IpPageState();
}

class _IpPageState extends State<IpPage> {
  TextEditingController ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
        
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 100,),
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Server Configuration',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Enter your server IP address to connect',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
        
              const SizedBox(height: 48),
        
              // Input Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IP Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: ipController,
                      decoration: const InputDecoration(
                        hintText: '192.168.1.100',
                        prefixIcon: Icon(Icons.dns_rounded, color: Colors.grey),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an IP address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
        
              const SizedBox(height: 24),
        
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String ip = ipController.text.trim();
                      SharedPreferences sh = await SharedPreferences.getInstance();
                      await sh.setString("url", "http://$ip:8000");
        
                      // Show success feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Settings saved successfully'),
                          backgroundColor: Colors.green[600],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                      bool logged = await sh.getBool('isLogged') ?? false;
                      String? type = await sh.getString('type');
                        if(logged )
                          {
                            if(type == 'user')
                              {
                                await sh.setBool('userLogged', true);
        
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>  UserHome())
                                );
                              }else
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) =>  PinkPoliceHomeScreen())
                                  );
                                }
        
                          }else{
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage())
                          );
                        }
        
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
        
              const SizedBox(height: 16),
        
              // Help Text
              const Center(
                child: Text(
                  'Make sure your server is running on port 8000',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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