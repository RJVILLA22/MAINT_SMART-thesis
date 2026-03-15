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

class Return extends StatefulWidget {
  const Return({super.key});

  @override
  State<Return> createState() => _ReturnState();
}

class _ReturnState extends State<Return> {
  String scanning = "Start Scanning";
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

  Widget buildReturnScreen(context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    final provider = Provider.of<ToolsProvider>(context, listen: false);

    return Column(
      children: [
        // Header
        CustomHeader(
          onBackPressed: () => Navigator.of(context).pop(),
          light: false,
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
                      'SCAN NOW TO',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 8,
                        fontWeight: FontWeight.bold,
                        color: maintColor.primaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    Text(
                      'RETURN A TOOL',
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 10,
                        fontWeight: FontWeight.bold,
                        color: maintColor.primaryDark,
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
                      color: maintColor.blackText, // Adjust color as needed
                    ),
                    SizedBox(width: AppSizes.blockSizeHorizontal * 4),
                    Text(
                      "This feature uses NFC. \nPlease tap your phone on the tool's \nNFC sticker.",
                      style: TextStyle(
                        fontSize: AppSizes.blockSizeHorizontal * 4,
                        fontWeight: FontWeight.bold,
                        color: maintColor.blackText,
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
                        final toolId = await provider.returnTool(scannedToolId);
                        if (toolId != null) {
                          final tool = await provider.getToolById(
                            scannedToolId,
                          );
                          Navigator.pushNamed(context, '/return_success');
                          setState(() {
                            scanning = "Start Scanning";
                          });
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
                  backgroundColor: maintColor.primary,
                  textColor: Colors.white,
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
      body: buildReturnScreen(context),
      backgroundColor: const Color(0xffFAFAFF),
    );
  }
}
