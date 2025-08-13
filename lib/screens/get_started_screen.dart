import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vegetables_app/screens/register_screen.dart';
import 'package:vegetables_app/utils/contants_color.dart';
import 'package:vegetables_app/widgets/MyHeadingText.dart';
import 'package:vegetables_app/widgets/MyTextContent.dart';
import 'package:vegetables_app/widgets/text_button.dart';

class GetStartedScreen extends ConsumerStatefulWidget{
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GetStartedScreenState();

}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen>{
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    height : screenHeight*0.55,
                      child: Image.asset("assets/images/get_started_img.png")),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30),)
                      ),
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyHeadingText(text: "Buy Vegetables \n Easily with us", fontSize: 25,backgroundColor: Colors.white, textColor: Colors.black),
                          Mytextcontent(text: "This e-commerce app makes buying fresh,  and convenient, offering a wide variety of  produce, secure payment options, and fast delivery,all from the comfort of your home", fontSize: 12, backgroundColor: Colors.white, textColor: Colors.black),
                          MyTextButton(
                            text: "Get Started",
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()));
                            },
                            backgroundColor: backgroundColor,
                            textColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              )
            ),

          ],
        ),
      ),
    );
  }

}