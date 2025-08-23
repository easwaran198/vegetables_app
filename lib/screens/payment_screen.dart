import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vegetables_app/providers/cart_provider.dart';
import 'package:vegetables_app/providers/profile_providers.dart';
import 'package:vegetables_app/screens/home_screen.dart';
import 'package:vegetables_app/screens/profile_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/widgets/MyHeadingText.dart';
import 'package:vegetables_app/widgets/MyTextContent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderTotalAmount;

  const PaymentScreen({Key? key, required this.orderTotalAmount}) : super(key: key);

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentState();
}

class _PaymentState extends ConsumerState<PaymentScreen> {
  int quantity = 1;
  final double rating = 2.4;
  late Razorpay _razorpay;
  late String total_amt_string; // Renamed to clearly indicate it's a string
  String selectedPaymentMethod = 'cod';

  @override
  void initState() {
    super.initState();
    total_amt_string = widget.orderTotalAmount; // Assign the string directly
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void increment() {
    setState(() {
      quantity++;
    });
  }

  void decrement() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    final profileAsyncValue = ref.watch(profileFutureProvider);
    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset("assets/images/back_img.png"),
                  ),
                  MyHeadingText(
                      text: "Payment",
                      fontSize: 22,
                      backgroundColor: Colors.white,
                      textColor: Colors.black),
                  SizedBox(width: 40),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15, left: 5, right: 5),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: const Color(0xffF9F9F9),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.grey)),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 20, bottom: 10),
                    child: MyHeadingText(
                        text: "Shipping Address",
                        fontSize: 18,
                        backgroundColor: Colors.white,
                        textColor: Colors.black),
                  ),
                  profileAsyncValue.when(
                    data: (profile) {
                      return
                        Row(
                          children: [
                            const SizedBox(
                                width: 50,
                                height: 30,
                                child: Icon(Icons.location_on, color: Colors.red)),
                            SizedBox(
                              child: Mytextcontent(
                                text: profileState?.address ?? profile.mobileno, // Assuming profile.mobileno is a fallback for address
                                fontSize: 13,
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                              ),
                            ),
                          ],
                        );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text('Error: ${error.toString()}'),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, left: 5, right: 5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: const Color(0xffF9F9F9),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.grey)),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 20, bottom: 10),
                    child: MyHeadingText(
                        text: "Contact information",
                        fontSize: 18,
                        backgroundColor: Colors.white,
                        textColor: Colors.black),
                  ),
                  profileAsyncValue.when(
                    data: (profile) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 50,
                                      height: 30,
                                      child: Icon(Icons.call, color: Colors.red)),
                                  SizedBox(
                                    child: Mytextcontent(
                                      text: profileState?.mobileno ?? profile.mobileno,
                                      fontSize: 13,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                      width: 50,
                                      height: 30,
                                      child: Icon(Icons.mail, color: Colors.red)),
                                  SizedBox(
                                    child: Mytextcontent(
                                      text: profileState?.mail ?? profile.mail,
                                      fontSize: 13,
                                      backgroundColor: Colors.white,
                                      textColor: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  ProfileScreen(),
                                ),
                              );
                              if (result == true) {
                                ref.invalidate(profileFutureProvider);
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(50)),
                                  color: backgroundColor),
                              child: const Icon(Icons.edit, color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Text('Error: ${error.toString()}'),
                  ),
                ],
              ),
            ),
            Container(
                alignment: AlignmentDirectional.topStart,
                margin: const EdgeInsets.only(left: 10, top: 10),
                child: MyHeadingText(
                    text: "Payment method",
                    fontSize: 20,
                    backgroundColor: Colors.white,
                    textColor: Colors.black)),

            _buildPaymentMethodOption(
              context,
              title: 'Razorpay',
              subtitle: 'Google Pay, PhonePe, Paytm and more',
              icon: Icons.credit_card,
              methodValue: 'razorpay',
              isSelected: selectedPaymentMethod == 'razorpay',
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'razorpay';
                });
              },
            ),

            _buildPaymentMethodOption(
              context,
              title: 'Cash on Delivery',
              subtitle: 'Pay at the time of delivery',
              icon: Icons.money,
              methodValue: 'cod',
              isSelected: selectedPaymentMethod == 'cod',
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'cod';
                });
              },
            ),
            _buildPaymentMethodOption(
              context,
              title: 'UPI transaction on store',
              subtitle: 'Pay at the time of Take away',
              icon: Icons.currency_rupee,
              methodValue: 'upi_take_away',
              isSelected: selectedPaymentMethod == 'upi_take_away',
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'cod';
                });
              },
            ),

            _buildPaymentMethodOption(
              context,
              title: 'PhonePe',
              subtitle: 'Pay using PhonePe UPI/Wallet',
              icon: Icons.phone_android,
              methodValue: 'phonepe',
              isSelected: selectedPaymentMethod == 'phonepe',
              onTap: () {
                setState(() {
                  selectedPaymentMethod = 'phonepe';
                });
              },
            ),



          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 10,right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyHeadingText(
                text: "Total ₹ $total_amt_string", // Use the string variable
                fontSize: 20,
                backgroundColor: Colors.white,
                textColor: Colors.black),
            InkWell(
                onTap: () {
                  print(selectedPaymentMethod);
                  if (selectedPaymentMethod == 'razorpay') {
                    _openCheckout();
                  } else if (selectedPaymentMethod == 'cod') {
                    _handleCashOnDelivery();
                  } else if (selectedPaymentMethod == 'upi_take_away') {
                    _handleCashOnDelivery();
                  } else if (selectedPaymentMethod == 'phonepe') {
                    _openPhonePeCheckout(); // new function
                  }
                },
              child: Container(
                padding:
                const EdgeInsets.only(left: 40, right: 40, top: 10, bottom: 10),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: backgroundColor),
                child: const Text(
                  "Pay",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required String methodValue,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return InkWell(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.08,
        width: screenWidth * 0.9,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.green : Colors.grey),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Radio<String>(
                value: methodValue,
                groupValue: selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleCashOnDelivery() async {
   /* debugPrint("Cash on Delivery selected. Processing order...");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Placing Cash on Delivery order...')),
    );*/

    try {
      final cartService = ref.read(cartServiceProvider);
      // Ensure total_amt_string is a String before cleaning
      String cleanTotalAmt = total_amt_string.replaceAll(RegExp(r'[^\d.]'), '').trim();

      final response = await cartService.placeOrder(
        'COD', // Payment mode
        cleanTotalAmt,
        'on process',
      );

      if (response['success'] == 'true') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VegetableShopScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: ${response['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      debugPrint('Error placing COD order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: ${e.toString()}')),
      );
    }
  }

  void _openCheckout() {
    String cleanTotalAmt = total_amt_string.replaceAll(',', '').trim(); // Use the string variable
    double temp;
    try {
      temp = double.parse(cleanTotalAmt);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid total amount: $total_amt_string')),
      );
      debugPrint('Error parsing total amount: $e');
      return;
    }
    int amountInPaise = (temp * 100).round();

    final profile = ref.read(profileNotifierProvider);

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not loaded. Cannot proceed with payment.')),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_W7JSd7hTzekaGo', // Your Razorpay key
      'amount': amountInPaise,
      'name': 'Natfo',
      'description': 'Order Payment for Vegetables',
      'prefill': {
        'contact': profile.mobileno,
        'email': profile.mail,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open payment gateway. Please try again.')),
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("Payment successful: ${response.paymentId}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful! Payment ID: ${response.paymentId}')),
    );

    try {
      final cartService = ref.read(cartServiceProvider);
      // Ensure total_amt_string is a String before cleaning
      String cleanTotalAmt = total_amt_string.replaceAll(RegExp(r'[^\d.]'), '').trim();

      final orderResponse = await cartService.placeOrder(
        'Razorpay', // Payment mode
        cleanTotalAmt, // Grand total (this is already a String)
        'on process', // Delivery status
      );

      if (orderResponse['success'] == 'true') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully (Razorpay)!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VegetableShopScreen(), // Navigate to home or order success screen
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful but failed to place order: ${orderResponse['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      debugPrint('Error placing order after Razorpay success: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful but error placing order: ${e.toString()}')),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment error: ${response.code} | ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet Selected: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }

  void _openPhonePeCheckout() {
    String cleanTotalAmt = total_amt_string.replaceAll(',', '').trim();
    double temp;
    try {
      temp = double.parse(cleanTotalAmt);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid total amount: $total_amt_string')),
      );
      return;
    }
    int amountInPaise = (temp * 100).round();

    final profile = ref.read(profileNotifierProvider);

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile not loaded. Cannot proceed with payment.')),
      );
      return;
    }

    var options = {
      'key': 'rzp_test_W7JSd7hTzekaGo',
      'amount': amountInPaise,
      'name': 'Vegetables',
      'description': 'Order Payment (PhonePe)',
      'prefill': {
        'contact': profile.mobileno,
        'email': profile.mail,
      },
      'external': {
        'wallets': ['phonepe'] // 👈 Force PhonePe option
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open PhonePe payment. Please try again.')),
      );
    }
  }


  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}