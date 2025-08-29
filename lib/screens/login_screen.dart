import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/models/register_res_data.dart';
import 'package:vegetables_app/providers/register_notifier.dart';
import 'package:vegetables_app/screens/otp_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/widgets/MyHeadingText.dart';
import 'package:vegetables_app/widgets/custom_text_form_field.dart';
import 'package:vegetables_app/widgets/text_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
          child: Container(
            height: screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: screenHeight*0.15,
                    child: Image.asset("assets/images/logo.png")),
                SizedBox(height: 8,),
                Container(
                  margin: EdgeInsets.only(left: 20.0,right: 20.0),
                  child: CustomTextFormField(
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
                ),
                SizedBox(height: 8,),
                MyTextButton(text: "Login",
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'mobileno': phoneController.text.toString(),
                      };
                      // Assuming 'registerProvider' is a Provider that exposes AsyncValue<RegisterResData>
            // or a similar structure.

                      // In your UI widget (where you call registerUser)

                      print(data);

                      ref.read(registerProvider.notifier).loginUser(data).then((_) {
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
              ],
            ),
          ),
        ),
      ),
    );
  }

}
