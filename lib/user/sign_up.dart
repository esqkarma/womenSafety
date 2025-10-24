import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shecare/Nlogin.dart';
import 'package:shecare/login.dart';
import 'package:intl/intl.dart';


class MyMySignupPage extends StatefulWidget {
  const MyMySignupPage({super.key, required this.title});
  final String title;

  @override
  State<MyMySignupPage> createState() => _MyMySignupPageState();
}

class _MyMySignupPageState extends State<MyMySignupPage> {
  String gender = "Male";
  File? uploadimage;
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController postController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController idmarkController = TextEditingController();
  TextEditingController fnameController = TextEditingController();
  TextEditingController mnameController = TextEditingController();
  TextEditingController bloodgroupController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  DateTime? selectedDob;

  @override
  void initState() {
    super.initState();

    // Add listeners to focus nodes to scroll when keyboard appears
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        // Delay to ensure keyboard is fully open
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
        // Delay to ensure keyboard is fully open
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        resizeToAvoidBottomInset: true, // This is important
        backgroundColor: Colors.pink[50],
        appBar: AppBar(
          backgroundColor: Colors.pink[700],
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 20),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Profile Image
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Stack(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.pink[300]!,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pink[100]!,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                            _selectedImage!,
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )
                              : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.pink[300],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.pink[500],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.camera_alt,
                                size: 18, color: Colors.white),
                            onPressed: _checkPermissionAndChooseImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Add Profile Photo',
                  style: TextStyle(
                    color: Colors.pink[700],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // Form
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSectionHeader("Personal Information"),
                          _buildTextField(
                              nameController, "Name", Icons.person),
                          _buildDatePickerField(),

                          // Gender
                          Container(
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "Gender",
                              style: TextStyle(
                                color: Colors.pink[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildGenderRadio(
                                      "Male", Icons.male)),
                              Expanded(
                                  child: _buildGenderRadio(
                                      "Female", Icons.female)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(phoneController,
                              "Phone Number", Icons.phone),
                          _buildTextField(emailController, "Email",
                              Icons.email),

                          _buildSectionHeader("Address Information"),
                          _buildTextField(placeController, "Place",
                              Icons.location_on),
                          _buildTextField(postController, "Post",
                              Icons.local_post_office),
                          _buildTextField(districtController,
                              "District", Icons.map),
                          _buildTextField(stateController, "State",
                              Icons.public),

                          _buildSectionHeader("Family Information"),
                          _buildTextField(idmarkController,
                              "Identification Mark", Icons.assignment),
                          _buildTextField(fnameController,
                              "Father's Name", Icons.man),
                          _buildTextField(mnameController,
                              "Mother's Name", Icons.woman),
                          _buildTextField(bloodgroupController,
                              "Blood Group", Icons.bloodtype),

                          _buildSectionHeader("Security"),
                          _buildPasswordField(
                              passwordController,
                              "Password",
                              Icons.lock,
                              _passwordFocusNode),
                          _buildPasswordField(
                              confirmpController,
                              "Confirm Password",
                              Icons.lock_outline,
                              _confirmPasswordFocusNode),
                        ],
                      ),
                    ),
                  ),
                ),

                // Sign Up & Login
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _send_data,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 4,
                            shadowColor: Colors.pink[300],
                          ),
                          child: const Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            },
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                color: Colors.pink[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Add extra space at the bottom when keyboard is open
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 300 : 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      IconData icon, FocusNode focusNode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.pink[600]),
          prefixIcon: Icon(icon, color: Colors.pink[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            BorderSide(color: Colors.pink[500]!, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink[300]!),
          ),
          filled: true,
          fillColor: Colors.pink[50],
        ),
      ),
    );
  }

  Widget _buildDatePickerField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _selectDate,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.pink[300]!, width: 1),
            borderRadius: BorderRadius.circular(10),
            color: Colors.pink[50],
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.pink[400]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dobController.text.isEmpty
                      ? "Select Date of Birth"
                      : dobController.text,
                  style: TextStyle(
                    color: dobController.text.isEmpty
                        ? Colors.pink[600]
                        : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.pink[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2001),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Colors.pink[700]!),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      String formattedDate =
          "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
      setState(() {
        selectedDob = pickedDate;
        dobController.text = formattedDate;
      });
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16, bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.pink[200]!, width: 2),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.pink[700],
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.pink[600]),
          prefixIcon: Icon(icon, color: Colors.pink[400]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            BorderSide(color: Colors.pink[500]!, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink[300]!),
          ),
          filled: true,
          fillColor: Colors.pink[50],
        ),
      ),
    );
  }

  Widget _buildGenderRadio(String genderValue, IconData icon) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Radio(
        value: genderValue,
        groupValue: gender,
        onChanged: (value) {
          setState(() {
            gender = value.toString();
          });
        },
        activeColor: Colors.pink[700],
      ),
      title: Row(
        children: [
          Icon(icon, size: 20, color: Colors.pink[600]),
          const SizedBox(width: 5),
          Text(genderValue, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _send_data() async {
    String uname = nameController.text;
    String dob = dobController.text;
    String phone = phoneController.text;
    String email = emailController.text;
    String place = placeController.text;
    String post = postController.text;
    String district = districtController.text;
    String state = stateController.text;
    String idmark = idmarkController.text;
    String fname = fnameController.text;
    String mname = mnameController.text;
    String bloodgroup = bloodgroupController.text;
    String password = passwordController.text;
    String confirmp = confirmpController.text;

    if (dob.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please select Date of Birth',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();

    final urls = Uri.parse('$url/myapp/user_registration/');
    try {
      final response = await http.post(urls, body: {
        "photo": photo,
        "name": uname,
        "dob": DateFormat('yyyy-MM-dd').format(selectedDob!),
        "gender": gender,
        "phone": phone,
        "email": email,
        "place": place,
        "post": post,
        "district": district,
        "state": state,
        "identification_mark": idmark,
        "fathers_name": fname,
        "mothers_name": mname,
        "blood_group": bloodgroup,
        "password": password,
        "confirmp": confirmp,
      });

      if (response.statusCode == 200) {
        String status = jsonDecode(response.body)['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(
            msg: 'Registration Successful',
            backgroundColor: Colors.pink[700],
            textColor: Colors.white,
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          Fluttertoast.showToast(
            msg: 'Registration Failed',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Network Error',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  File? _selectedImage;
  String? _encodedImage;
  Future<void> _chooseAndUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
        _encodedImage = base64Encode(_selectedImage!.readAsBytesSync());
        photo = _encodedImage.toString();
      });
    }
  }

  Future<void> _checkPermissionAndChooseImage() async {
    final PermissionStatus status = await Permission.mediaLibrary.request();
    if (status.isGranted) {
      _chooseAndUploadImage();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text(
            'Please go to app settings and grant permission to choose an image.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  String photo = '';
}