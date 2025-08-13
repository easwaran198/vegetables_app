import 'dart:convert';
import 'dart:typed_data'; // Import for Uint8List

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegetables_app/screens/home_screen.dart';
import 'package:vegetables_app/screens/my_orders_screen.dart';
import 'package:vegetables_app/screens/register_screen.dart';
import 'package:vegetables_app/screens/terms_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart' hide backgroundColor;
import 'package:vegetables_app/widgets/MyHeadingText.dart' hide MyHeadingText;
import 'package:vegetables_app/widgets/MyTextContent.dart' hide Mytextcontent;
import 'package:vegetables_app/widgets/text_button.dart';
import 'package:vegetables_app/models/profile_model.dart';
import 'package:vegetables_app/providers/profile_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  late TextEditingController _mailController;
  late TextEditingController _addressController;
  String? _profileImageBase64String; // Stores the picked image as Base64 for the dialog

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _mobileController = TextEditingController();
    _mailController = TextEditingController();
    _addressController = TextEditingController();
  }

  // --- MODIFIED: Function to get the image provider based on Base64 string or URL ---
  ImageProvider<Object> _getImageProvider(String? imageSource) {
    if (imageSource != null && imageSource.isNotEmpty) {
      // Check if it's a URL
      if (imageSource.startsWith('http://') || imageSource.startsWith('https://')) {
        return NetworkImage(imageSource);
      } else {
        // Assume it's a Base64 string if not a URL
        try {
          final Uint8List bytes = base64Decode(imageSource);
          return MemoryImage(bytes);
        } catch (e) {
          print('Error decoding Base64 image or invalid image source: $e');
          // Fallback to default image if decoding fails or it's not a valid Base64
        }
      }
    }
    return AssetImage("assets/images/profile.jpg"); // Default image
  }
  // ----------------------------------------------------------------------------------

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profileImageBase64String = base64Encode(bytes);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _mailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(Profile currentProfile) {
    _nameController.text = currentProfile.name;
    _mobileController.text = currentProfile.mobileno;
    _mailController.text = currentProfile.mail;
    _addressController.text = currentProfile.address ?? '';

    // Initialize _profileImageBase64String with the current profile's image.
    // This allows the dialog to show the existing image (if any)
    // before a new one is picked. It could be a Base64 string from a previous pick
    // or a URL from the fetched profile.
    _profileImageBase64String = currentProfile.profileimg;


    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Profile'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        await _pickImage();
                        setState(() {}); // Update the dialog's state to show new image
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _getImageProvider(_profileImageBase64String),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _mobileController,
                      decoration: InputDecoration(labelText: 'Mobile No.'),
                      keyboardType: TextInputType.phone,
                    ),
                    TextField(
                      controller: _mailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(labelText: 'Address'),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final profileNotifier = ref.read(profileNotifierProvider.notifier);
                    try {
                      await profileNotifier.updateProfile(
                        name: _nameController.text,
                        mobileno: _mobileController.text,
                        mail: _mailController.text,
                        address: _addressController.text.isEmpty ? null : _addressController.text,
                        profileimg: _profileImageBase64String, context: context, // Use the picked/existing Base64 string for update
                      );
                      Navigator.of(context).pop();
                      ref.invalidate(profileFutureProvider);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update profile: $e')),
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    final profileAsyncValue = ref.watch(profileFutureProvider);
    final currentProfile = ref.watch(profileNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsyncValue.when(
          data: (initialProfile) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (currentProfile == null || initialProfile != currentProfile) {
                ref.read(profileNotifierProvider.notifier).setProfile(initialProfile);
              }
            });

            final displayProfile = currentProfile ?? initialProfile;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyHeadingText(
                            text: "Profile",
                            fontSize: 22,
                            backgroundColor: Colors.white,
                            textColor: Colors.black),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  CircleAvatar(
                    radius: 50,
                    // --- MODIFIED: Use the helper function here ---
                    backgroundImage: _getImageProvider(displayProfile.profileimg),
                    // ---------------------------------------------
                    backgroundColor: Colors.transparent,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyHeadingText(
                          text: displayProfile.name,
                          fontSize: 22,
                          backgroundColor: Colors.white,
                          textColor: backgroundColor),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () => _showEditProfileDialog(displayProfile),
                        child: CircleAvatar(
                          child: Icon(Icons.edit, color: Colors.white),
                          backgroundColor: Colors.red,
                          radius: 15,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    color: backgroundColor,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Mytextcontent(
                            text: "Edit Profile",
                            fontSize: 18,
                            backgroundColor: backgroundColor,
                            textColor: Colors.white),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: screenWidth * 0.1,
                            child: Icon(Icons.phone, color: Colors.red)),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Mytextcontent(
                              text: displayProfile.mobileno,
                              fontSize: 13,
                              backgroundColor: Colors.white,
                              textColor: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: screenWidth * 0.1,
                            child: Icon(Icons.location_on, color: Colors.red)),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Mytextcontent(
                              text: displayProfile.address ?? 'Address not provided',
                              fontSize: 13,
                              backgroundColor: Colors.white,
                              textColor: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: screenWidth * 0.1,
                            child: Icon(Icons.mail, color: Colors.red)),
                        Container(
                          alignment: Alignment.topCenter,
                          child: Mytextcontent(
                              text: displayProfile.mail,
                              fontSize: 13,
                              backgroundColor: Colors.white,
                              textColor: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    color: backgroundColor,
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Mytextcontent(
                            text: "My Activity & Terms and conditions",
                            fontSize: 18,
                            backgroundColor: backgroundColor,
                            textColor: Colors.white),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyOrdersScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 20),
                        Icon(Icons.list_alt, color: Colors.red),
                        SizedBox(width: 20),
                        Mytextcontent(
                            text: "My orders",
                            fontSize: 20,
                            backgroundColor: Colors.white,
                            textColor: Colors.black),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> VegetableShopScreen(initialIndex: 3,)));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 20),
                        Icon(Icons.add_shopping_cart, color: Colors.red),
                        SizedBox(width: 20),
                        Mytextcontent(
                            text: "My cart",
                            fontSize: 20,
                            backgroundColor: Colors.white,
                            textColor: Colors.black),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TermsScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 20),
                        Icon(Icons.checklist, color: Colors.red),
                        SizedBox(width: 20),
                        Mytextcontent(
                            text: "Terms & conditions",
                            fontSize: 20,
                            backgroundColor: Colors.white,
                            textColor: Colors.black),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  MyTextButton(
                      text: "Log out",
                      onPressed: () {
                        _showLogoutDialog();
                      },
                      backgroundColor: backgroundColor,
                      textColor: Colors.white,
                      padding:
                      EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10))
                ],
              ),
            );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(profileFutureProvider),
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('Logout cancelled.');
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearUserData();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    print('Token and User ID cleared from SharedPreferences.');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => RegisterScreen()),
      );
    }
  }
}