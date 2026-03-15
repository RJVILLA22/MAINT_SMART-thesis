import 'package:app/components/button.dart';
import 'package:app/components/gradient.dart';
import 'package:app/components/header.dart';
import 'package:app/components/home_dial.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/inventory_provider.dart';
import 'package:app/provider/transaction_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        context.read<InventoryProvider>().startUserBorrowedListener();
        context.read<TransactionProvider>().startUserRecentTransactions(
          user.uid,
        );
      }
    });
  }

  @override
  void dispose() {
    context.read<TransactionProvider>().stopUserRecentTransactions();
    context.read<InventoryProvider>().stopUserBorrowedListener();
    super.dispose();
  }

  final recentActivity = {};

  String _toSentenceCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }

  Widget buildHomeDashboard() {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Consumer<UserAuthProvider>(
      builder: (context, authProvider, _) {
        // Get user's first name, fallback to 'User' if not available
        final userName = authProvider.currentUserProfile?.first_name ?? 'User';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            SizedBox(height: AppSizes.blockSizeVertical * 3),
            Header(profile: true, light: true),
            // Greeting Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: AppSizes.blockSizeHorizontal * 5),
              child: GradientText(
                'Hi, $userName!',
                style: TextStyle(
                  fontSize: AppSizes.blockSizeHorizontal * 12,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
                gradient: LinearGradient(
                  colors: [maintColor.primary, maintColor.blackText],
                ),
              ),
            ),
            SizedBox(height: AppSizes.blockSizeVertical * 2),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.blockSizeHorizontal * 4,
              ),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: AppSizes.blockSizeHorizontal * 2,
                crossAxisSpacing: AppSizes.blockSizeHorizontal * 4,
                childAspectRatio: 0.9,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  FeatureButton(
                    iconPath: 'assets/images/borrow.png',
                    label: 'Borrow a Tool',
                    onTap: () => Navigator.pushNamed(context, '/borrow'),
                  ),
                  FeatureButton(
                    iconPath: 'assets/images/return.png',
                    label: 'Return a Tool',
                    onTap: () => Navigator.pushNamed(context, '/return'),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSizes.blockSizeVertical * 2),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.blockSizeHorizontal * 4,
              ),
              child: ActionButton(
                text: 'View Live Tool Inventory',
                icon: Icons.storage,
                onTap: () {
                  Navigator.pushNamed(context, '/inventory');
                },
                isFullWidth: true,
              ),
            ),

            SizedBox(height: AppSizes.blockSizeVertical * 2),

            //Transaction History
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: AppSizes.blockSizeHorizontal * 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    AppSizes.blockSizeHorizontal * 6,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.blockSizeHorizontal * 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Title
                      Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: AppSizes.blockSizeHorizontal * 6,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 13, 20, 119),
                        ),
                      ),

                      // Consistent spacing after title
                      SizedBox(height: AppSizes.blockSizeVertical * 2),

                      // Content area
                      Expanded(
                        child: Consumer<TransactionProvider>(
                          builder: (context, txnProvider, _) {
                            if (txnProvider.error != null) {
                              return Center(
                                child: Text(
                                  'Error loading transactions',
                                  style: TextStyle(
                                    fontSize: AppSizes.blockSizeHorizontal * 4,
                                    color: Colors.red,
                                  ),
                                ),
                              );
                            }

                            if (txnProvider.userRecent.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: AppSizes.blockSizeHorizontal * 20,
                                      color: maintColor.grayText.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppSizes.blockSizeVertical * 2,
                                    ),
                                    Text(
                                      'No recent activity',
                                      style: TextStyle(
                                        fontSize:
                                            AppSizes.blockSizeHorizontal * 4,
                                        color: maintColor.grayText,
                                      ),
                                    ),
                                    SizedBox(
                                      height: AppSizes.blockSizeVertical * 2,
                                    ),
                                    Text(
                                      'Your tool transactions will appear here',
                                      style: TextStyle(
                                        fontSize:
                                            AppSizes.blockSizeHorizontal * 3.5,
                                        color: maintColor.grayText.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: txnProvider.userRecent.length,
                              separatorBuilder:
                                  (context, index) => Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                  ),
                              itemBuilder: (context, index) {
                                final activity = txnProvider.userRecent[index];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: AppSizes.blockSizeVertical * 0.5,
                                    horizontal:
                                        AppSizes.blockSizeHorizontal * 2,
                                  ),
                                  leading: Icon(
                                    activity.toLowerCase().startsWith('borrow')
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color:
                                        activity.toLowerCase().startsWith(
                                              'borrow',
                                            )
                                            ? Colors.orange
                                            : Colors.green,
                                    size: AppSizes.blockSizeHorizontal * 5,
                                  ),
                                  title: Text(
                                    _toSentenceCase(activity),
                                    style: TextStyle(
                                      fontSize:
                                          AppSizes.blockSizeHorizontal * 4.5,
                                      color: maintColor.blackText,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom padding with consistent spacing
            SizedBox(height: AppSizes.blockSizeVertical * 2),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFF),
      body: buildHomeDashboard(),
    );
  }
}
