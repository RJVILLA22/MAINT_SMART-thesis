import 'package:app/components/button.dart';
import 'package:app/components/gradient.dart';
import 'package:app/components/header.dart';
import 'package:app/components/home_dial.dart';
import 'package:app/components/textfield.dart';
import 'package:app/models/tool.dart';
import 'package:app/provider/tools_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String userName = 'Admin';

  final recentActivity = {};
  TextEditingController modelController = TextEditingController();
  TextEditingController borrowDaysController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String nfcData = "Scanning";

  // Future<bool> writeNFCWithFeedback(String toolId, BuildContext context) async {
  //   print("writing to nfc");
  //   print(toolId);

  //   // Capture messenger early
  //   final messenger = ScaffoldMessenger.of(context);

  //   bool isAvailable = await NfcManager.instance.isAvailable();
  //   if (!isAvailable) {
  //     messenger.showSnackBar(
  //       const SnackBar(content: Text('❌ NFC not available on this device')),
  //     );
  //     return false;
  //   }

  //   Completer<bool> completer = Completer<bool>();

  //   NfcManager.instance.startSession(
  //     onDiscovered: (NfcTag tag) async {
  //       try {
  //         Ndef? ndef = Ndef.from(tag);

  //         if (ndef == null || !ndef.isWritable) {
  //           messenger.showSnackBar(
  //             const SnackBar(content: Text('❌ NFC tag is not writable')),
  //           );
  //           completer.complete(false);
  //           NfcManager.instance.stopSession();
  //           return;
  //         }

  //         final message = NdefMessage([NdefRecord.createText(toolId.trim())]);
  //         await ndef.write(message);

  //         messenger.showSnackBar(
  //           const SnackBar(content: Text('✅ NFC tag written successfully!')),
  //         );

  //         completer.complete(true);
  //       } catch (e) {
  //         messenger.showSnackBar(
  //           SnackBar(content: Text('❌ Error writing NFC: $e')),
  //         );
  //         completer.complete(false);
  //       } finally {
  //         NfcManager.instance.stopSession();
  //       }
  //     },
  //   );

  //   return completer.future;
  // }

  Future<bool> writeNFCWithFeedback(String toolId, BuildContext context) async {
    // Capture the messenger once at the beginning while context is valid
    final messenger = ScaffoldMessenger.of(context);

    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      messenger.showSnackBar(
        const SnackBar(content: Text('❌ NFC not available on this device')),
      );
      return false;
    }

    Completer<bool> completer = Completer<bool>();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          Ndef? ndef = Ndef.from(tag);

          if (ndef == null || !ndef.isWritable) {
            // Use the captured 'messenger', NOT 'context'
            messenger.showSnackBar(
              const SnackBar(content: Text('❌ NFC tag is not writable')),
            );
            completer.complete(false);
            await NfcManager.instance.stopSession();
            return;
          }

          final message = NdefMessage([NdefRecord.createText(toolId.trim())]);
          await ndef.write(message);

          messenger.showSnackBar(
            const SnackBar(content: Text('✅ NFC tag written successfully!')),
          );

          completer.complete(true);
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('❌ Error writing NFC: $e')),
          );
          completer.complete(false);
        } finally {
          await NfcManager.instance.stopSession();
        }
      },
    );

    return completer.future;
  }

  Widget buildHomeDashboard(context) {
    final tool_provider = Provider.of<ToolsProvider>(context, listen: false);

    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
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
                  iconPath: 'assets/images/users.png',
                  label: 'Users',
                  onTap: () {
                    Navigator.pushNamed(context, '/user_list');
                  },
                ),
                FeatureButton(
                  iconPath: 'assets/images/return.png',
                  label: 'Inventory',
                  onTap: () {
                    Navigator.pushNamed(context, '/inventory_admin');
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: AppSizes.blockSizeVertical * 2),

          // Add Tool Section
          Container(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section Title
                  GradientText(
                    'Add a Tool',
                    style: TextStyle(
                      fontSize: AppSizes.blockSizeHorizontal * 8,
                      fontWeight: FontWeight.w600,
                      height: 0.7,
                    ),
                    gradient: LinearGradient(
                      colors: [maintColor.primary, maintColor.blackText],
                    ),
                  ),

                  SizedBox(height: AppSizes.blockSizeVertical * 4),

                  // Form fields
                  MaintTextField(
                    controller: modelController,
                    hintText: "Model",
                    obscureText: false,
                  ),
                  SizedBox(height: AppSizes.blockSizeVertical * 2),
                  MaintTextField(
                    controller: borrowDaysController,
                    hintText: "Allowable borrowing days",
                    obscureText: false,
                  ),
                  SizedBox(height: AppSizes.blockSizeVertical * 2),
                  MaintTextField(
                    controller: descriptionController,
                    hintText: "Description",
                    obscureText: false,
                  ),
                  SizedBox(height: AppSizes.blockSizeVertical * 2),
                  ActionButton(
                    text: 'Write to Tool',
                    onTap: () async {
                      final toolModel = modelController.text.trim();
                      final borrowDaysText = borrowDaysController.text.trim();
                      final description = descriptionController.text.trim();

                      // Capture ScaffoldMessenger BEFORE any async operations
                      final messenger = ScaffoldMessenger.of(context);

                      // Validate input
                      if (toolModel.isEmpty ||
                          borrowDaysText.isEmpty ||
                          description.isEmpty) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('⚠️ Please fill in all fields'),
                          ),
                        );
                        return;
                      }

                      int borrowDays;
                      try {
                        borrowDays = int.parse(borrowDaysText);
                      } catch (_) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Borrow days must be a valid number'),
                          ),
                        );
                        return;
                      }

                      final toolProvider = Provider.of<ToolsProvider>(
                        context,
                        listen: false,
                      );
                      final newTool = Tool(
                        model: toolModel,
                        borrowDays: borrowDays,
                        description: description,
                        status: "available",
                      );

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Saving tool to Firestore...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      final String? newToolId = await toolProvider.addTool(
                        newTool,
                      );

                      print(newToolId);

                      // Check if widget is still mounted after async operation
                      if (!mounted) return;

                      if (newToolId == null) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save tool to Firestore'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Tap NFC tag to write tool ID...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      final bool writeSuccess = await writeNFCWithFeedback(
                        newToolId,
                        context,
                      );

                      if (!mounted) return;

                      if (!writeSuccess) {
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Tool created, but NFC write FAILED'),
                          ),
                        );
                        return;
                      }

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Tool added & NFC tag written!'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      modelController.clear();
                      borrowDaysController.clear();
                      descriptionController.clear();
                    },
                    backgroundColor: maintColor.primary,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding
          SizedBox(height: AppSizes.blockSizeVertical * 2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFAFAFF),
      resizeToAvoidBottomInset: true, // This is important for keyboard behavior
      body: buildHomeDashboard(context),
    );
  }
}
