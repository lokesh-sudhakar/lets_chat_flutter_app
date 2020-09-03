import 'package:chat_app/colors.dart';
import 'package:chat_app/enums/enums.dart';
import 'package:chat_app/model/verify_number/verify_number_response.dart';
import 'package:chat_app/viewmodel/login_view_model.dart';
import 'package:chat_app/views/otp.dart';
import 'package:chat_app/widgets/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../locator.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  LoginViewModel viewModel = locator<LoginViewModel>();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    viewModel.responseStream.listen((response) {
      switch (response.event) {
        case VerifyPhoneCallbackEvent.codeSent:
          {
            showToast(context, response.message);
            moveToOtpScreen();
            break;
          }
        case VerifyPhoneCallbackEvent.failed:
          {
            showToast(context, response.message);
            break;
          }
        case VerifyPhoneCallbackEvent.timeOut:
          {
//            showToast(context, response.message);
            break;
          }
        case VerifyPhoneCallbackEvent.verified:
          // TODO: No need to handle this case.
          break;
        case VerifyPhoneCallbackEvent.loading:
          // TODO: No need to handle this case.
          break;
        case VerifyPhoneCallbackEvent.stable:
          // TODO: No need to handle this case.
          break;
      }
    });
  }

  void moveToOtpScreen() {
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Otp(
                    phoneNumber: viewModel
                        .numberWithCountryCode(phoneNumberController.text),
                    verificationId: viewModel.verificationId,
                  )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
      padding: EdgeInsets.all(15.0),
      child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/welcome_chat_logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        "Welcome",
                        style: TextStyle(
                          color: ThemeColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      Text(
                        "Please verify your phone number to continue",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ThemeColors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly,
                      ],
                      style: TextStyle(
                        color: ThemeColors.black,
                      ),
                      controller: phoneNumberController,
                      decoration: new InputDecoration(
                        focusColor: ThemeColors.blue,
                        prefixText: "+91",
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/phone_blue.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.fill,
                          ),
                        ),
                        labelText: "Enter Phone Number",
                        fillColor: ThemeColors.blue,

                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          borderSide: new BorderSide(),
                        ),
                        //fillColor: Colors.green
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Enter valid number";
                        } else if (value.length < 10) {
                          return "number should contain atleast 10 digits";
                        } else {
                          return null;
                        }
                      },
                    ),
                    StreamBuilder<VerifyNumberResponse>(
                        stream: viewModel.responseStream,
                        builder: (context, snapshot) {
                          bool showLoading = snapshot.hasData
                              ? snapshot.data.event ==
                                  VerifyPhoneCallbackEvent.loading
                              : false;
                          return Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (!showLoading &&
                                        formKey.currentState.validate()) {
                                      FocusScope.of(context).unfocus();
                                      viewModel.verifyPhoneNumber(
                                          phoneNumberController.text);
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    child: Center(
                                      child: Text(
                                        "Verify",
                                        style: TextStyle(
                                          color: ThemeColors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: showLoading
                                            ? Colors.grey
                                            : ThemeColors.blue),
                                  ),
                                ),
                                showLoading
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: Column(
                                          children: [
                                            LinearProgressIndicator(),
                                            SizedBox(
                                              height: 4,
                                            ),
                                            Text(
                                              "Please wait while we are authenticating\n using your phone",
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                      )
                                    : Container(
                                        width: 0,
                                        height: 0,
                                      )
                              ],
                            ),
                          );
                        }),
                  ],
                ),
              ],
            ),
      ),
    ),
          ),
        ));
  }
}
