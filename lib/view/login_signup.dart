import 'package:chittootech/view/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _googleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      if (googleAuth != null) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);
        _navigateToHome();
        Fluttertoast.showToast(msg: "Login successfully");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _phoneLogin(String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _navigateToHome();
        },
        verificationFailed: (FirebaseAuthException e) {
          Fluttertoast.showToast(msg: e.message ?? "Verification failed");
        },
        codeSent: (String verificationId, int? resendToken) async {
          _showOtpDialog(verificationId);
          Fluttertoast.showToast(msg: "OTP sent");
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOtpDialog(String verificationId) {
    String otp = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter OTP"),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              otp = value;
            },
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(width: 1, color: Colors.blue)),
              onPressed: () async {
                try {
                  final credential = PhoneAuthProvider.credential(
                    verificationId: verificationId,
                    smsCode: otp,
                  );
                  await _auth.signInWithCredential(credential);
                  Fluttertoast.showToast(msg: "Login successfully");
                  Navigator.pop(context);
                  _navigateToHome();
                } catch (e) {
                  Fluttertoast.showToast(msg: e.toString());
                }
              },
              child: const Text("Verify"),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Login",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(width: 1, color: Colors.blue)),
                      onPressed: _googleLogin,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/google.png",
                              width: 20, height: 20),
                          const SizedBox(width: 16),
                          Text(
                            "Login with Google",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.5)),
                        ),
                        Text("OR"),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.4,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.5)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    IntlPhoneField(
                        initialValue: _phoneController.text,
                        textInputAction: TextInputAction.done,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 14, fontWeight: FontWeight.w500),
                        dropdownIcon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black38,
                        ),
                        decoration: InputDecoration(
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2),
                          ),
                          labelText: 'Phone Number',
                          labelStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black38),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.black38,
                              width: 1,
                            ),
                          ),
                        ),
                        initialCountryCode:
                            'IN', // Change it to your desired initial country code
                        onChanged: (phone) {
                          _phoneController.text = phone.completeNumber;
                        }

                        // onCountryChanged: (country) {
                        //   print(country.code);
                        // },
                        ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            side: const BorderSide(
                                width: 1, color: Colors.white)),
                        onPressed: () async {
                          await _phoneLogin(_phoneController.text);
                        },
                        child: const Text(
                          "Get OTP",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ))
                  ],
                ),
              ),
      ),
    );
  }
}
