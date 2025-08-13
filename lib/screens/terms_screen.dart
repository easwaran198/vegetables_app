import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/screens/my_orders_screen.dart';
import 'package:vegetables_app/providers/terms_provider.dart'; // import the provider file

class TermsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(termsProvider);

    return Scaffold(
      appBar: AppBar(
        title: MyHeadingText(
          text: "Terms and conditions",
          fontSize: 20,
          backgroundColor: backgroundColor,
          textColor: Colors.black,
        ),
      ),
      body: SafeArea(
        child: termsAsync.when(
          data: (termsContent) => SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Text(
              termsContent,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text("Error: ${e.toString()}")),
        ),
      ),
    );
  }
}
