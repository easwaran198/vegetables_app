import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/register_res_data.dart';
import 'package:vegetables_app/providers/register_notifier.dart';
import 'package:vegetables_app/screens/login_screen.dart';
import 'package:vegetables_app/screens/otp_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/widgets/MyHeadingText.dart';
import 'package:vegetables_app/widgets/custom_text_form_field.dart';
import 'package:vegetables_app/widgets/text_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: screenHeight * 0.12,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/reg_top_img.png"),
                      fit: BoxFit.fill, // Or BoxFit.fill, BoxFit.contain, etc.
                    ),
                  )),
              Container(
                  height: screenHeight*0.15,
                  child: Image.asset("assets/images/logo.png")),
              MyHeadingText(text: "Create an Account", fontSize: 22, backgroundColor: Colors.white, textColor: Colors.black),
              SizedBox(height: 8,),
              Container(
                margin: EdgeInsets.only(left: 20.0,right: 20.0),
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: nameController,
                      borderlineColor: backgroundColor,
                      hintText: 'Enter the name',
                      prefixIcon: Icons.person,
                      onSuffixTap: () {
                        nameController.clear();
                      },
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      backgroundColor: Colors.white,
                      borderRadius: 30,
                    ),
                    SizedBox(height: 15,),
                    CustomTextFormField(
                      controller: phoneController,
                      borderlineColor: backgroundColor,
                      hintText: 'Email the phone number',
                      prefixIcon: Icons.phone_android,
                      onSuffixTap: () {
                        phoneController.clear();
                      },
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                      backgroundColor: Colors.white,
                      borderRadius: 30,
                    ),
                    SizedBox(height: 15,),
                    CustomTextFormField(
                      controller: emailController,
                      borderlineColor: backgroundColor,
                      hintText: 'Enter the E-mail Address',
                      prefixIcon: Icons.email,
                      onSuffixTap: () {
                        emailController.clear();
                      },
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        } else if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      backgroundColor: Colors.white,
                      borderRadius: 30,
                    ),
                    SizedBox(height: 15,),
                    CustomTextFormField(
                      controller: addressController,
                      borderlineColor: backgroundColor,
                      hintText: 'Address',
                      prefixIcon: Icons.label,
                      onSuffixTap: () {
                        addressController.clear();
                      },
                      validator: (value){
                        if (value == null || value.isEmpty) {
                          return 'Please enter address';
                        }
                        return null;
                      },
                      backgroundColor: Colors.white,
                      borderRadius: 30,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              MyTextButton(text: "Register",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final data = {
                      'name': nameController.text.toString(),
                      'mobileno': phoneController.text.toString(),
                      'email': emailController.text.toString(),
                      'address': addressController.text.toString(),
                    };
                    // Assuming 'registerProvider' is a Provider that exposes AsyncValue<RegisterResData>
// or a similar structure.

                    // In your UI widget (where you call registerUser)

                    print(data);

                    ref.read(registerProvider.notifier).registerUser(data).then((_) {
                      final registerState = ref.read(registerProvider);

                      if (registerState.hasValue) {
                        // This cast is now safe because registerUser ensures the state holds RegisterResData
                        final RegisterResData? registerResData = registerState.value;

                        if (registerResData != null && registerResData.success == 'true') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OtpScreen(mobileno: phoneController.text.toString(),otp : registerResData.otp.toString()),
                            ),
                          );
                        } else {
                          final errorMessage = registerResData?.message ?? registerResData?.error ?? 'Registration failed. Please try again.';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        }
                      } else if (registerState.hasError) {
                        final error = registerState.error;
                        final errorMessage = error.toString();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('An error occurred during registration: $errorMessage')),
                        );
                      }
                    });
                  }
                },
                backgroundColor: backgroundColor, textColor: Colors.white, padding: EdgeInsets.only(left: 50,right: 50,bottom: 10,top: 10),),
              SizedBox(height: 8,),
              InkWell(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: MyHeadingText(underline:true,text: "Account is already exists then \nPlease click and login here", fontSize: 15, backgroundColor: Colors.white, textColor: Colors.red)),
              Container(
                width: screenWidth,
                height: screenHeight*0.23,
                  alignment: Alignment.centerRight,
                  child: Image.asset("assets/images/reg_bottom_img.png"))
            ],
          ),
        ),
      ),
    );
  }


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(color: Colors.green),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
