import 'dart:async';

import 'package:app/components/button.dart';
import 'package:app/components/header_2.dart';
import 'package:app/provider/tools_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class BorrowSuccess extends StatefulWidget {
  const BorrowSuccess({super.key});

  @override
  State<BorrowSuccess> createState() => _BorrowSuccessState();
}

class _BorrowSuccessState extends State<BorrowSuccess> {
  Widget buildBorrowScreen(context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    final provider = Provider.of<ToolsProvider>(context, listen: false);

    return Column(
      children: [
        // Header
        CustomHeader(
          onBackPressed: () {
            provider.clearSelectedTool();
            Navigator.of(context).pop();
          },
          light: true,
          onProfilePressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),

        // Main content area
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.blockSizeHorizontal * 5,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Top spacer
                SizedBox(height: AppSizes.blockSizeVertical * 2),

                // Text section
                Column(
                  children: [
                    Text(
                      'TRANSACTION',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      'CONFIRMED',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Animation section
                Expanded(
                  flex: 1,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: AppSizes.blockSizeHorizontal * 80,
                        maxHeight: AppSizes.blockSizeHorizontal * 80,
                      ),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: DotLottieLoader.fromAsset(
                          "assets/images/check.lottie",
                          frameBuilder: (
                            BuildContext ctx,
                            DotLottie? dotlottie,
                          ) {
                            if (dotlottie != null) {
                              return Lottie.memory(
                                dotlottie.animations.values.single,
                                fit: BoxFit.contain,
                                repeat: true,
                                animate: true,
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.animation,
                                  size: AppSizes.blockSizeHorizontal * 10,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.blockSizeVertical * 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Successfully borrowed ${provider.selectedTool!.model}.\n"
                      "Please return within ${provider.selectedTool!.borrowDays} days.",
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign:
                          TextAlign
                              .center, // better than justify for short messages
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.blockSizeVertical * 6),
                // Bottom spacer
                ActionButton(
                  text: "Back to Home",
                  onTap: () async {
                    provider.clearSelectedTool();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  backgroundColor: Color(0xffEFF0FF),
                  textColor: maintColor.primaryDark,
                ),
                SizedBox(height: AppSizes.blockSizeVertical * 4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBorrowScreen(context),
      backgroundColor: maintColor.primary,
    );
  }
}
