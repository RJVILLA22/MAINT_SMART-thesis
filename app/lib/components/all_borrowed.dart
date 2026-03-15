import 'package:app/components/info_container.dart';
import 'package:app/pages/borrow.dart';
import 'package:app/pages/profile.dart';
import 'package:app/provider/inventory_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BorrowedToolsScreen extends StatefulWidget {
  const BorrowedToolsScreen({super.key});

  @override
  State<BorrowedToolsScreen> createState() => _MyBorrowedToolsScreenState();
}

class _MyBorrowedToolsScreenState extends State<BorrowedToolsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().startAllBorrowedListener();
    });
  }

  @override
  void dispose() {
    context.read<InventoryProvider>().stopAllBorrowedListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        if (inv.isAllBorrowedLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (inv.allBorrowedError != null) {
          return Center(
            child: Text(
              "Error: ${inv.allBorrowedError}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (inv.allBorrowed.isEmpty) {
          return const Center(child: Text("No borrowed tools"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoContainer(
              text: "Tools that everyone is currently borrowing",
              backgroundColor: Color(0xffE2E5FF),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.blockSizeVertical * 2,
                ),
                itemCount: inv.allBorrowed.length,
                itemBuilder: (context, i) {
                  final row = inv.allBorrowed[i];
                  final model = row['model'] as String;
                  final userId = row['id'] as String;
                  final borrowedBy = row['borrowedBy'] as String;
                  final borrowedAt = row['borrowedAt'] as DateTime?;
                  final dueDate = row['dueDate'] as DateTime?;

                  final formatter = DateFormat('MMMM d, y');
                  final borrowedAtStr =
                      borrowedAt != null
                          ? formatter.format(borrowedAt.toLocal())
                          : 'N/A';
                  final dueDateStr =
                      dueDate != null
                          ? formatter.format(dueDate.toLocal())
                          : 'N/A';

                  return Card(
                    color: Color(0xffF5F5F5),
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSizes.blockSizeHorizontal * 5,
                      vertical: AppSizes.blockSizeVertical * 1,
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userId: userId),
                          ),
                        );
                      },
                      title: Text(
                        model,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: maintColor.primaryDark,
                          fontSize: AppSizes.blockSizeVertical * 3,
                        ),
                      ),
                      subtitle: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: AppSizes.blockSizeVertical * 1.7,
                            color: maintColor.blackText,
                          ),
                          children: [
                            const TextSpan(
                              text: "Borrowed by: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "$borrowedBy\n"),
                            const TextSpan(
                              text: "Borrowed: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: "$borrowedAtStr\n"),
                            const TextSpan(
                              text: "Due: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: dueDateStr),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
