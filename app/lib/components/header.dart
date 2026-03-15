import 'package:app/pages/profile.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final bool profile;
  final bool light;

  const Header({super.key, required this.profile, required this.light});

  @override
  Widget build(BuildContext context) {
    // Initialize AppSizes
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Container(
      padding: EdgeInsets.only(
        top: AppSizes.blockSizeVertical * 3.5, // Increased top padding
        bottom: AppSizes.blockSizeVertical * 2,
        left: AppSizes.blockSizeHorizontal * 5, // Increased left padding
        right: AppSizes.blockSizeHorizontal * 2,
      ),
      height:
          AppSizes.blockSizeVertical * 15, // Fixed height for responsiveness
      child: Stack(
        children: [
          // Logo and Text Section
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo/Image Section
              SizedBox(width: AppSizes.blockSizeHorizontal * 4),
              // Text Section
              Expanded(
                flex: 4, // Adjusted flex to control space
                child: Padding(
                  padding: EdgeInsets.only(
                    top: AppSizes.blockSizeVertical * 2,
                    right: AppSizes.blockSizeHorizontal * 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'MAINT - SMART',
                        style: TextStyle(
                          fontSize: AppSizes.blockSizeHorizontal * 7,
                          fontWeight: FontWeight.bold,
                          color: light ? maintColor.grayText : Colors.white,
                        ),
                      ),
                      Text(
                        'Philippine State College of Aeronautics',
                        style: TextStyle(
                          fontSize: AppSizes.blockSizeHorizontal * 3,
                          color: light ? maintColor.grayText : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Profile Icon at Upper Right
          if (profile)
            Positioned(
              top: AppSizes.blockSizeVertical * 1,
              right: AppSizes.blockSizeHorizontal * 2,
              child: IconButton(
                icon: Icon(Icons.person_outline),
                iconSize:
                    AppSizes.blockSizeHorizontal * 8, // Responsive icon size
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
    );
  }
}
