import 'package:app/components/header_2.dart';
import 'package:app/components/tabs.dart';

import 'package:app/utils/block_sizes.dart';

import 'package:flutter/material.dart';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<Inventory> createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  Widget buildInventoryScreen(context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);
    return Column(
      children: [
        // Header
        CustomHeader(
          onBackPressed: () => Navigator.of(context).pop(),
          light: false,
        ),

        // Tabs + content (fills remaining space)
        const Expanded(child: ScrollableTabComponent()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildInventoryScreen(context),
      backgroundColor: Colors.white,
    );
  }
}
