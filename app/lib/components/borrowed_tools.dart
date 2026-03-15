import 'package:app/components/info_container.dart';
import 'package:app/provider/inventory_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MyBorrowedScreen extends StatefulWidget {
  const MyBorrowedScreen({super.key});

  @override
  State<MyBorrowedScreen> createState() => _MyBorrowedScreenState();
}

class _MyBorrowedScreenState extends State<MyBorrowedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().startUserBorrowedListener();
    });
  }

  @override
  void dispose() {
    context.read<InventoryProvider>().stopUserBorrowedListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        if (inv.isUserBorrowedLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (inv.userBorrowedError != null) {
          return Center(
            child: Text(
              "Error: ${inv.userBorrowedError}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (inv.userBorrowed.isEmpty) {
          return const Center(child: Text("No borrowed tools"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoContainer(
              text: "Tools that you are currently borrowing",
              backgroundColor: Color(0xffE2E5FF),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.blockSizeVertical * 2,
                ),
                itemCount: inv.userBorrowed.length,
                itemBuilder: (context, i) {
                  final row = inv.userBorrowed[i];
                  final model = row['model'] as String;
                  final borrowedAt = row['borrowedAt'] as DateTime;
                  final dueDate = row['dueDate'] as DateTime;

                  final formatter = DateFormat('MMMM d, y');
                  final borrowedAtStr = formatter.format(borrowedAt.toLocal());
                  final dueDateStr = formatter.format(dueDate.toLocal());

                  return Card(
                    color: Color(0xffF5F5F5),
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSizes.blockSizeHorizontal * 5,
                      vertical: AppSizes.blockSizeVertical * 1,
                    ),
                    child: ListTile(
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
