import 'package:app/components/button.dart';
import 'package:app/components/form_field.dart';
import 'package:app/components/header.dart';
import 'package:app/pages/signup1.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Widget buildLogin(context) {
    final authProvider = Provider.of<UserAuthProvider>(context);
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
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSizes.blockSizeHorizontal * 4,
                  top: AppSizes.blockSizeVertical * 9,
                  right: AppSizes.blockSizeHorizontal * 4,
                  bottom: AppSizes.blockSizeVertical * 3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, PhilSCAns!',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 7,
                        fontWeight: FontWeight.w500,
                        color: maintColor.primaryDark,
                      ),
                    ),
                    Text(
                      'Tap in. Take tools. Track Smart.',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 4,
                        fontWeight: FontWeight.w500,
                        color: maintColor.primaryDark,
                      ),
                    ),
                    SizedBox(height: AppSizes.blockSizeVertical * 2),
                    // Remove any horizontal padding from form fields
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 9.2),
                      child: SizedBox(
                        width: double.infinity,
                        child: MaintFormField(
                          controller: emailController,
                          hintText: "Email: ",
                          obscureText: false,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.blockSizeVertical * 2),
                    Padding(
                      padding: EdgeInsetsGeometry.only(left: 9.2),
                      child: SizedBox(
                        width: double.infinity,
                        child: MaintFormField(
                          controller: passwordController,
                          hintText: "Password: ",
                          obscureText: true,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.blockSizeVertical * 11),
                    Center(
                      child: ActionButton(
                        text: "Log In",
                        onTap: () async {
                          // Capture messenger BEFORE async operation
                          final messenger = ScaffoldMessenger.of(context);

                          try {
                            final uid = await authProvider.signIn(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                            if (!mounted) return;

                            // If login successful, clear fields
                            emailController.clear();
                            passwordController.clear();

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Login successful!"),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;

                            // Catch the exception thrown from FirebaseAuthAPI
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );

                            emailController.clear();
                            passwordController.clear();
                          }
                        },
                        backgroundColor: maintColor.primary,
                        textColor: Colors.white,
                        borderRadius: 30,
                        width: AppSizes.blockSizeHorizontal * 60,
                        isFullWidth: false,
                      ),
                    ),
                    SizedBox(height: AppSizes.blockSizeVertical * 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(
                            color: maintColor.blackText,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpPage1(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign up now',
                            style: TextStyle(
                              color: maintColor.primary,
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
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              maintColor.primary,
              const Color(0xffFAFAFF),
              maintColor.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: buildLogin(context),
      ),
    );
  }
}
