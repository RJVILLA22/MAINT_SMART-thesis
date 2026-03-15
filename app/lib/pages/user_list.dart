import 'package:app/components/header_2.dart';
import 'package:app/components/user_tab.dart';

import 'package:app/utils/block_sizes.dart';

import 'package:flutter/material.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
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
        const Expanded(child: UserTabComponent()),
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
