import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/providers/verifyotp_notifier.dart';
import 'package:vegetables_app/utils/contants_color.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String mobileno;
  final String otp;

  const OtpScreen({Key? key,required this.mobileno,required this.otp}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OtpScreenState(mobileNo: mobileno,otp : otp);

}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final String mobileNo;
  final String otp;

  _OtpScreenState({Key? key, required this.mobileNo,required this.otp});

  @override
  void initState() {
    otpController.text = otp ;
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(verifyotpNotifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Verify OTP'),
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("OTP Verification",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),

              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Enter OTP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OTP';
                  }
                  return null;
                },
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'mobileno' : mobileNo,
                        'otp': otpController.text
                      };
                      print(data);
                      ref.read(verifyotpNotifier.notifier).verifyOtp(data).then((_) {
                        if (ref.read(verifyotpNotifier).hasError) {
                          final error = ref.read(verifyotpNotifier).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registration failed: $error')),
                          );

                          print('$error');
                        } else {
                          Navigator.pushNamed(context, '/home');
                        }
                      });
                      //Navigator.pushNamed(context, '/home');
                    }
                  },
                  child: Text('Verify',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
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
