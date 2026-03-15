import 'package:app/components/info_container.dart';
import 'package:app/pages/profile.dart';
import 'package:app/provider/user_directory_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InstructorsScreen extends StatefulWidget {
  const InstructorsScreen({super.key});

  @override
  State<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserDirectoryProvider>().startListening();
    });
  }

  @override
  void dispose() {
    context.read<UserDirectoryProvider>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return Consumer<UserDirectoryProvider>(
      builder: (context, userDir, _) {
        if (userDir.instructors.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No instructors found",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoContainer(
              text: "All registered instructors",
              backgroundColor: Color(0xffE2E5FF),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  vertical: AppSizes.blockSizeVertical * 2,
                ),
                itemCount: userDir.instructors.length,
                itemBuilder: (context, i) {
                  final instructor = userDir.instructors[i];
                  final name =
                      '${instructor.first_name} ${instructor.last_name}';
                  final department = instructor.department ?? 'N/A';
                  final email = instructor.email;

                  return Card(
                    color: Color(0xffF5F5F5),
                    margin: EdgeInsets.symmetric(
                      horizontal: AppSizes.blockSizeHorizontal * 5,
                      vertical: AppSizes.blockSizeVertical * 0.5,
                    ),
                    child: ListTile(
                      onTap: () {
                        if (instructor.id != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ProfileScreen(userId: instructor.id!),
                            ),
                          );
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: maintColor.primary.withOpacity(0.2),
                        child: Text(
                          instructor.first_name[0].toUpperCase(),
                          style: TextStyle(
                            color: maintColor.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizes.blockSizeVertical * 2.5,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: maintColor.primaryDark,
                          fontSize: AppSizes.blockSizeVertical * 2.4,
                        ),
                      ),
                      subtitle: Text(
                        'Department: $department\nEmail: $email',
                        style: TextStyle(
                          fontSize: AppSizes.blockSizeVertical * 1.7,
                          color: maintColor.blackText,
                          height: 1.3,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: AppSizes.blockSizeVertical * 2,
                        color: maintColor.primaryDark,
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
