import 'package:app/pages/profile.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final bool showProfileButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool light;

  const CustomHeader({
    Key? key,
    this.title = 'MAINT - SMART',
    this.subtitle = 'Philippine State College of Aeronautics',
    this.showBackButton = true,
    this.showProfileButton = true,
    this.onBackPressed,
    this.onProfilePressed,
    this.backgroundColor,
    this.gradient,
    required this.light,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: AppSizes.blockSizeVertical * 1.5,
        bottom: AppSizes.blockSizeVertical * 2,
        left: AppSizes.blockSizeHorizontal * 5,
        right: AppSizes.blockSizeHorizontal * 2,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            if (showBackButton)
              GestureDetector(
                onTap: onBackPressed ?? () => Navigator.of(context).pop(),
                child: Container(
                  padding: EdgeInsets.all(AppSizes.blockSizeHorizontal * 2),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: light ? Colors.white : maintColor.blackText,
                    size: AppSizes.blockSizeHorizontal * 6,
                  ),
                ),
              ),

            // Title and subtitle section
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.only(
                  right: AppSizes.blockSizeHorizontal * 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: light ? Colors.white : maintColor.blackText,
                        fontSize: AppSizes.blockSizeHorizontal * 7,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSizes.blockSizeVertical * 0.5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: light ? Colors.white : maintColor.blackText,
                        fontSize: AppSizes.blockSizeHorizontal * 3,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            if (showProfileButton)
              Padding(
                padding: EdgeInsets.only(
                  right: AppSizes.blockSizeHorizontal * 2,
                ),
                child: IconButton(
                  color: light ? Colors.white : maintColor.blackText,
                  icon: Icon(Icons.person_outline),
                  iconSize: AppSizes.blockSizeHorizontal * 8,
                  onPressed: () async {
                    try {
                      // Get the current user from Firebase Auth directly
                      final currentUser = FirebaseAuth.instance.currentUser;

                      if (currentUser != null && context.mounted) {
                        print("User ID: ${currentUser.uid}");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProfileScreen(userId: currentUser.uid),
                          ),
                        );
                      } else {
                        print("No user logged in");
                      }
                    } catch (e) {
                      print("Error navigating to profile: $e");
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
