import 'package:app/components/header.dart';
import 'package:app/components/home_dial.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/signup2.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/sign_up_provider.dart';
import 'package:app/utils/block_sizes.dart';

import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage1 extends StatefulWidget {
  const SignUpPage1({super.key});

  @override
  State<SignUpPage1> createState() => _SignUpPage1State();
}

class _SignUpPage1State extends State<SignUpPage1> {
  Widget buildSignUp1(context) {
    final userProvider = Provider.of<SignUpProvider>(context);
    String? selectedType = userProvider.userType;
    final authProvider = Provider.of<UserAuthProvider>(context);
    AppSizes appSizes = AppSizes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSizes.blockSizeVertical * 3),
        Header(profile: false, light: true),

        Padding(
          padding: EdgeInsets.only(
            left: AppSizes.blockSizeHorizontal * 6,
            top: AppSizes.blockSizeVertical * 6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, PhilSCAns!',
                style: TextStyle(
                  fontSize: AppSizes.blockSizeHorizontal * 9,
                  fontWeight: FontWeight.w800,
                  color: maintColor.blackText,
                ),
              ),
              Text(
                'Welcome to MAINT-SMART',
                style: TextStyle(
                  fontSize: AppSizes.blockSizeHorizontal * 5,
                  fontWeight: FontWeight.w500,
                  color: maintColor.blackText,
                ),
              ),
              SizedBox(height: AppSizes.blockSizeVertical * 8),
              Padding(
                padding: EdgeInsets.only(
                  right: AppSizes.blockSizeHorizontal * 6,
                ),
                child: Center(
                  child: Text(
                    'Select your status to begin.',
                    style: TextStyle(
                      fontSize: AppSizes.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.w500,
                      color: maintColor.blackText,
                    ),
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.only(
                  right: AppSizes.blockSizeHorizontal * 6,
                  top: AppSizes.blockSizeVertical * 2,
                ),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: AppSizes.blockSizeHorizontal * 2,
                  crossAxisSpacing: AppSizes.blockSizeHorizontal * 4,
                  childAspectRatio: 0.9,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      EdgeInsets
                          .zero, // ADD THIS TO REMOVE ANY DEFAULT GRID PADDING
                  children: [
                    FeatureButton(
                      iconPath: 'assets/images/student.png',
                      label: 'Student',
                      backgroundColor: Colors.white,
                      textColor: maintColor.primaryDark,
                      onTap: () {
                        userProvider.setUserType('student');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage2(),
                          ),
                        );
                      },
                    ),
                    FeatureButton(
                      iconPath: 'assets/images/instructor.png',
                      label: 'Instructor',
                      textColor: maintColor.primaryDark,
                      backgroundColor: Colors.white,
                      onTap: () {
                        userProvider.setUserType('instructor');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage2(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: AppSizes.blockSizeVertical * 18,
                    right: AppSizes.blockSizeHorizontal * 6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Tap in. Take tools. Track smart',
                        style: TextStyle(
                          fontSize: AppSizes.blockSizeHorizontal * 5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          const SizedBox(width: 4),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Login(),
                                ),
                              );
                            },

                            child: const Text(
                              'Log in here!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xffFAFAFF), maintColor.primary],
          ),
        ),
        child: buildSignUp1(context),
      ),
    );
  }
}
