import 'dart:async';

import 'package:app/components/button.dart';
import 'package:app/components/header_2.dart';
import 'package:app/provider/inventory_provider.dart';
import 'package:app/provider/tools_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';

class Borrow extends StatefulWidget {
  const Borrow({super.key});

  @override
  State<Borrow> createState() => _BorrowState();
}

class _BorrowState extends State<Borrow> {
  String scanning = "Start Scanning";
  bool _noticeDismissed = false;
  
  Future<String?> startNFC() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      print("NFC not available");
      return null;
    }

    final completer = Completer<String?>();

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          Ndef? ndef = Ndef.from(tag);
          if (ndef != null) {
            final cachedMessage = ndef.cachedMessage;
            if (cachedMessage != null && cachedMessage.records.isNotEmpty) {
              final record = cachedMessage.records.first;
              if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
                  record.type.length == 1 &&
                  record.type.first == 0x54) {
                final payload = record.payload;
                final languageCodeLength = payload.first;
                final textBytes = payload.sublist(1 + languageCodeLength);
                final toolId = String.fromCharCodes(textBytes);

                print("✅ Tool ID read from NFC: $toolId");

                completer.complete(toolId); // ✅ resolve future with toolId
                NfcManager.instance.stopSession();
                return;
              }
            }
          }
          completer.complete(null);
        } catch (e) {
          completer.completeError(e);
        } finally {
          NfcManager.instance.stopSession();
        }
      },
    );

    return completer.future; // ✅ return String? once tag is discovered
  }

  Widget buildBorrowScreen(context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    final provider = Provider.of<ToolsProvider>(context, listen: false);

    return Column(
      children: [
        // Header
        CustomHeader(
          onBackPressed: () => Navigator.of(context).pop(),
          light: true,
          onProfilePressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),

        // Dismissable Notice Banner
        Consumer<InventoryProvider>(
          builder: (context, invProvider, _) {
            final hasBorrowedTools = invProvider.userBorrowed.isNotEmpty;
            
            if (!hasBorrowedTools || _noticeDismissed) {
              return const SizedBox.shrink();
            }

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: AppSizes.blockSizeHorizontal * 5,
                vertical: AppSizes.blockSizeVertical * 1,
              ),
              padding: EdgeInsets.all(AppSizes.blockSizeHorizontal * 4),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade700,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade900,
                    size: AppSizes.blockSizeHorizontal * 6,
                  ),
                  SizedBox(width: AppSizes.blockSizeHorizontal * 3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notice',
                          style: TextStyle(
                            fontSize: AppSizes.blockSizeHorizontal * 4.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        SizedBox(height: AppSizes.blockSizeVertical * 0.5),
                        Text(
                          'You currently have borrowed tools. Please return them before borrowing new ones.',
                          style: TextStyle(
                            fontSize: AppSizes.blockSizeHorizontal * 3.5,
                            color: Colors.amber.shade900,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: AppSizes.blockSizeVertical * 1),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/return');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizes.blockSizeHorizontal * 3,
                                  vertical: AppSizes.blockSizeVertical * 0.5,
                                ),
                                backgroundColor: Colors.amber.shade700,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                'Return Now',
                                style: TextStyle(
                                  fontSize: AppSizes.blockSizeHorizontal * 3.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _noticeDismissed = true;
                      });
                    },
                    icon: Icon(
                      Icons.close,
                      color: Colors.amber.shade900,
                      size: AppSizes.blockSizeHorizontal * 5,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
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
                      'SCAN NOW TO',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      'BORROW A TOOL',
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
                          "assets/images/nfc.lottie",
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
                    Icon(
                      Icons.nfc,
                      size: 40.0, // Adjust size as needed
                      color: Colors.white, // Adjust color as needed
                    ),
                    SizedBox(width: AppSizes.blockSizeHorizontal * 4),
                    Text(
                      "This feature uses NFC. \n Please tap your phone on the tool's \n NFC sticker.",
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.blockSizeVertical * 6),
                // Bottom spacer
                ActionButton(
                  text: scanning,
                  onTap: () async {
                    setState(() {
                      scanning = "Scanning...";
                    });
                    final scannedToolId = await startNFC();

                    if (scannedToolId != null) {
                      print("Got Tool ID: $scannedToolId");
                      try {
                        final toolId = await provider.borrowTool(scannedToolId);
                        if (toolId != null) {
                          final tool = await provider.getToolById(
                            scannedToolId,
                          );
                          setState(() {
                            scanning = "Start Scanning";
                          });
                          Navigator.pushNamed(context, '/borrow_success');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: ${provider.error}"),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          setState(() {
                            scanning = "Start Scanning";
                          });
                        }
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: ${error}"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        setState(() {
                          scanning = "Start Scanning";
                        });
                      }
                    } else {
                      setState(() {
                        scanning = "Error scanning tool.";
                      });
                    }
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
