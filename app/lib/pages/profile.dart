import 'package:app/components/header_2.dart';
import 'package:app/pages/login.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/models/user.dart' as AppUser;

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppUser.AppUser? _userProfile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    print(widget.userId);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<UserAuthProvider>();
      final profile = await authProvider.getProfile(widget.userId);

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes()..initSizes(context);

    return Scaffold(
      backgroundColor: const Color(0xffFAFAFF),
      body: Column(
        children: [
          // Header with gradient background
          Container(
            height: AppSizes.blockSizeVertical * 27,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [maintColor.primary, maintColor.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CustomHeader(
                  light: true,
                  showBackButton: true,
                  showProfileButton: false,
                ),
                SizedBox(height: AppSizes.blockSizeVertical * 3),
              ],
            ),
          ),

          // Profile content
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: AppSizes.blockSizeHorizontal * 15,
                            color: Colors.red,
                          ),
                          SizedBox(height: AppSizes.blockSizeVertical * 2),
                          Text(
                            'Error loading profile',
                            style: TextStyle(
                              fontSize: AppSizes.blockSizeHorizontal * 4,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    )
                    : _userProfile == null
                    ? Center(
                      child: Text(
                        'User not found',
                        style: TextStyle(
                          fontSize: AppSizes.blockSizeHorizontal * 4,
                          color: maintColor.grayText,
                        ),
                      ),
                    )
                    : SingleChildScrollView(
                      child: Column(
                        children: [
                          // Profile avatar with overlap
                          Transform.translate(
                            offset: Offset(0, -AppSizes.blockSizeVertical * 5),
                            child: Container(
                              width: AppSizes.blockSizeHorizontal * 40,
                              height: AppSizes.blockSizeHorizontal * 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/profile.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: AppSizes.blockSizeHorizontal * 25,
                                      color: maintColor.primaryDark,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Name
                          Transform.translate(
                            offset: Offset(0, -AppSizes.blockSizeVertical * 3),
                            child: Column(
                              children: [
                                Text(
                                  '${_userProfile!.first_name} ${_userProfile!.last_name}',
                                  style: TextStyle(
                                    fontSize: AppSizes.blockSizeHorizontal * 8,
                                    fontWeight: FontWeight.bold,
                                    color: maintColor.primaryDark,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: AppSizes.blockSizeVertical * 1,
                                ),
                                Text(
                                  _userProfile!.email,
                                  style: TextStyle(
                                    fontSize: AppSizes.blockSizeHorizontal * 4,
                                    color: maintColor.grayText,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Profile details
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.blockSizeHorizontal * 8,
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  'Classification:',
                                  _userProfile!.type.toUpperCase(),
                                  sizes,
                                ),
                                SizedBox(
                                  height: AppSizes.blockSizeVertical * 3,
                                ),
                                if (_userProfile!.course != null)
                                  _buildInfoRow(
                                    'Program:',
                                    _userProfile!.course!,
                                    sizes,
                                  ),
                                if (_userProfile!.course != null)
                                  SizedBox(
                                    height: AppSizes.blockSizeVertical * 3,
                                  ),
                                if (_userProfile!.department != null)
                                  _buildInfoRow(
                                    'Department:',
                                    _userProfile!.department!,
                                    sizes,
                                  ),
                                if (_userProfile!.department != null)
                                  SizedBox(
                                    height: AppSizes.blockSizeVertical * 3,
                                  ),
                                if (_userProfile!.id_number != null)
                                  _buildInfoRow(
                                    'ID Number:',
                                    _userProfile!.id_number!,
                                    sizes,
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppSizes.blockSizeVertical * 4),

                          // Edit profile button (only for logged in user)
                          StreamBuilder<User?>(
                            stream: FirebaseAuth.instance.authStateChanges(),
                            builder: (context, snapshot) {
                              final currentUser = snapshot.data;
                              final isOwnProfile =
                                  currentUser?.uid == widget.userId;
                              print(
                                'Current UID: ${currentUser?.uid}, Viewing: ${widget.userId}',
                              );
                              if (!isOwnProfile) {
                                print(currentUser?.uid);
                                return const SizedBox.shrink();
                              }

                              return Column(
                                children: [
                                  // Padding(
                                  //   padding: EdgeInsets.symmetric(
                                  //     horizontal:
                                  //         AppSizes.blockSizeHorizontal * 8,
                                  //   ),
                                  //   child: SizedBox(
                                  //     width: double.infinity,
                                  //     height: AppSizes.blockSizeVertical * 5,
                                  //     child: ElevatedButton(
                                  //       onPressed: () {
                                  //         // TODO: Navigate to edit profile
                                  //         print('Edit profile pressed');
                                  //       },
                                  //       style: ElevatedButton.styleFrom(
                                  //         backgroundColor: maintColor.primary,
                                  //         shape: RoundedRectangleBorder(
                                  //           borderRadius: BorderRadius.circular(
                                  //             25,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       child: Text(
                                  //         'Edit Profile',
                                  //         style: TextStyle(
                                  //           fontSize:
                                  //               AppSizes.blockSizeHorizontal *
                                  //               4.5,
                                  //           fontWeight: FontWeight.bold,
                                  //           color: Colors.white,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(
                                  //   height: AppSizes.blockSizeVertical * 2,
                                  // ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          AppSizes.blockSizeHorizontal * 8,
                                    ),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: AppSizes.blockSizeVertical * 5,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          // Call provider to handle sign-out
                                          await context
                                              .read<UserAuthProvider>()
                                              .signOut();

                                          Navigator.of(
                                            context,
                                          ).popUntil((route) => route.isFirst);

                                          print('✅ User logged out');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              maintColor.primaryComplement,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.logout_rounded,
                                          color: maintColor.blackText,
                                          size:
                                              AppSizes.blockSizeHorizontal *
                                              5.5,
                                        ),
                                        label: Text(
                                          'Log Out',
                                          style: TextStyle(
                                            fontSize:
                                                AppSizes.blockSizeHorizontal *
                                                4.5,
                                            fontWeight: FontWeight.bold,
                                            color: maintColor.blackText,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: AppSizes.blockSizeVertical * 4),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, AppSizes sizes) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppSizes.blockSizeHorizontal * 4,
              fontWeight: FontWeight.w500,
              color: maintColor.blackText,
            ),
          ),
        ),
        SizedBox(width: AppSizes.blockSizeHorizontal * 2),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.blockSizeHorizontal * 5,
              fontWeight: FontWeight.bold,
              color: maintColor.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
