import 'package:app/components/button.dart';
import 'package:app/components/form_field.dart';
import 'package:app/components/header.dart';
import 'package:app/pages/signup1.dart';
import 'package:app/pages/terms_and_conditions.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/sign_up_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage2 extends StatefulWidget {
  const SignUpPage2({super.key});

  @override
  State<SignUpPage2> createState() => _SignUpPage2State();
}

class _SignUpPage2State extends State<SignUpPage2> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController idNumberController = TextEditingController();
  TextEditingController departmentController = TextEditingController();
  TextEditingController degprogController = TextEditingController();
  bool _acceptedTerms = false;

  AppSizes appSizes = AppSizes();

  Future<void> _handleSignUp(BuildContext context) async {
    if (!_acceptedTerms) return;

    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    final userProvider = Provider.of<SignUpProvider>(context, listen: false);

    try {
      userProvider.setPersonalInfo(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
      );
      if (userProvider.userType! == 'instructor') {
        print("here");
        userProvider.setAcademicInfo(
          idNumber: idNumberController.text,
          department: departmentController.text,
        );
      } else {
        userProvider.setAcademicInfo(
          idNumber: idNumberController.text,
          course: degprogController.text,
        );
      }

      final newUser = userProvider.toUserModel();

      print(newUser);
      try {
        String uid = await authProvider.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
          newUser,
        );

        if (uid.isNotEmpty) {
          // Sign-up successful -> clear temp signup data
          userProvider.clear();

          // Navigate to Home (or Admin depending on role)
          if (context.mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/home',
            );
          }
        } else {
          // Show generic error
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Sign up failed. Please try again.",
                ),
              ),
            );
          }
        }
      } catch (e) {
        // Catch exceptions from FirebaseAuthAPI
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    } catch (e) {
      // Catch the exception thrown from FirebaseAuthAPI
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Widget buildSignUp2(context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
    final userProvider = Provider.of<SignUpProvider>(context);
    String? selectedType = userProvider.userType;

    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSizes.blockSizeVertical * 3),
        Header(profile: false, light: false),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: AppSizes.blockSizeVertical * 10),
            decoration: BoxDecoration(color: maintColor.primaryComplement),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSizes.blockSizeHorizontal * 4,
                  right: AppSizes.blockSizeHorizontal * 2,
                  top: AppSizes.blockSizeVertical * 3,
                  bottom: AppSizes.blockSizeVertical * 3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please provide us with some personal information.',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 6,
                        fontWeight: FontWeight.w500,
                        color: maintColor.primaryDark,
                      ),
                    ),
                    SizedBox(height: AppSizes.blockSizeVertical * 2),

                    Row(
                      children: [
                        Expanded(
                          child: MaintFormField(
                            controller: firstNameController,
                            hintText: 'First Name',
                            obscureText: false,
                          ),
                        ),
                        SizedBox(width: AppSizes.blockSizeHorizontal * 0.3),
                        Expanded(
                          child: MaintFormField(
                            controller: lastNameController,
                            hintText: 'Last Name',
                            obscureText: false,
                          ),
                        ),
                      ],
                    ),

                    MaintFormField(
                      controller: emailController,
                      hintText: "Email: ",
                      obscureText: false,
                    ),

                    MaintFormField(
                      controller: idNumberController,
                      hintText: "ID Number: ",
                      obscureText: false,
                    ),

                    selectedType == 'student'
                        ? MaintFormField(
                          controller: degprogController,
                          hintText: "Degree Program: ",
                          obscureText: false,
                        )
                        : MaintFormField(
                          controller: departmentController,
                          hintText: "Department: ",
                          obscureText: false,
                        ),

                    MaintFormField(
                      controller: passwordController,
                      hintText: "Password: ",
                      obscureText: true,
                    ),

                    // Terms and Conditions Checkbox
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppSizes.blockSizeVertical * 2,
                        right: AppSizes.blockSizeHorizontal * 6,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                            activeColor: maintColor.primary,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TermsAndConditionsPage(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: AppSizes.blockSizeVertical * 1.5,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: AppSizes.blockSizeHorizontal * 3.5,
                                      color: maintColor.blackText,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'I have read and agree to the ',
                                      ),
                                      TextSpan(
                                        text: 'Terms and Conditions',
                                        style: TextStyle(
                                          color: maintColor.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ', including the Data Privacy Act compliance.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(
                        top: AppSizes.blockSizeVertical * 2,
                        right: AppSizes.blockSizeHorizontal * 6,
                      ),
                      child: Center(
                        child: ActionButton(
                          text: "Sign Up",
                          onTap: () => _handleSignUp(context),
                          backgroundColor: _acceptedTerms ? maintColor.primary : Colors.grey,
                          textColor: Colors.white,
                          borderRadius: 30,
                          height: AppSizes.blockSizeVertical * 5.5,
                          width: AppSizes.blockSizeHorizontal * 50,
                          isFullWidth: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
            colors: [
              maintColor.primary, maintColor.primaryDark, //
            ],
          ),
        ),
        child: buildSignUp2(context),
      ),
    );
  }
}
