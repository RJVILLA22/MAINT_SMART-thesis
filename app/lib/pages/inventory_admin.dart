import 'package:app/components/admin_tabs.dart';
import 'package:app/components/header_2.dart';

import 'package:app/utils/block_sizes.dart';

import 'package:flutter/material.dart';

class InventoryAdmin extends StatefulWidget {
  const InventoryAdmin({super.key});

  @override
  State<InventoryAdmin> createState() => _InventoryAdminState();
}

class _InventoryAdminState extends State<InventoryAdmin> {
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
        const Expanded(child: ScrollableAdminTabComponent()),
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
