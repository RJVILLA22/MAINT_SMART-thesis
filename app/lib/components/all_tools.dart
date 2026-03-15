import 'dart:async';
import 'package:app/components/info_container.dart';
import 'package:app/provider/auth_provider.dart';
import 'package:app/provider/inventory_provider.dart';
import 'package:app/provider/tools_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllToolsScreen extends StatefulWidget {
  const AllToolsScreen({super.key});

  @override
  State<AllToolsScreen> createState() => _AllToolsScreenState();
}

class _AllToolsScreenState extends State<AllToolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().startAllToolsListener();
    });

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text.trim().toLowerCase();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    context.read<InventoryProvider>().stopAllToolsListener();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'borrowed':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  void _showEditModal(BuildContext context, Map<String, dynamic> tool) {
    final modelController = TextEditingController(text: tool['model']);
    final descController = TextEditingController(text: tool['description']);
    final daysController = TextEditingController(
      text: tool['borrowDays'].toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Tool"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: "Model"),
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: daysController,
                    decoration: const InputDecoration(labelText: "Borrow Days"),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final provider = context.read<ToolsProvider>();
                  await provider.updateTool(tool['id'], {
                    'model': modelController.text,
                    'description': descController.text,
                    'borrowDays': int.tryParse(daysController.text) ?? 0,
                  });
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, String toolId, String modelName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Tool"),
            content: Text("Are you sure you want to delete $modelName?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await context.read<ToolsProvider>().deleteTool(toolId);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes()..initSizes(context);

    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        if (inv.isAllToolsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (inv.allToolsError != null) {
          return Center(
            child: Text(
              "Error: ${inv.allToolsError}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (inv.allTools.isEmpty) {
          return const Center(child: Text("No tools"));
        }

        // Filter tools based on search query
        final filteredTools =
            inv.allTools.where((tool) {
              final model = (tool['model'] as String?)?.toLowerCase() ?? '';
              final description =
                  (tool['description'] as String?)?.toLowerCase() ?? '';
              return model.contains(_searchQuery) ||
                  description.contains(_searchQuery);
            }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoContainer(
              text: "All tools in the inventory",
              backgroundColor: const Color(0xffE2E5FF),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.blockSizeHorizontal * 5,
                vertical: AppSizes.blockSizeVertical * 1.5,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tools...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                  filled: true,
                  fillColor: Color(0xffF5F5F5),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: maintColor.primaryDark,
                      width: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child:
                  filteredTools.isEmpty
                      ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? "No tools"
                              : "No tools found matching '$_searchQuery'",
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredTools.length,
                        padding: EdgeInsets.symmetric(
                          vertical: AppSizes.blockSizeVertical * 0.5,
                          horizontal: AppSizes.blockSizeHorizontal * 6,
                        ),
                        itemBuilder: (context, i) {
                          final row = filteredTools[i];

                          final model = row['model'] as String? ?? 'Unknown';
                          final description =
                              row['description'] as String? ?? '';
                          final borrowDays = row['borrowDays'] as int? ?? 0;
                          final status = row['status'] as String? ?? '';

                          return Container(
                            margin: EdgeInsets.only(
                              bottom: AppSizes.blockSizeVertical * 0.8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: AppSizes.blockSizeHorizontal * 3,
                                vertical: AppSizes.blockSizeVertical * 0.5,
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(status),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSizes.blockSizeHorizontal * 2,
                                  ),
                                  Expanded(
                                    child: Text(
                                      model,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: maintColor.primaryDark,
                                        fontSize:
                                            AppSizes.blockSizeVertical * 2.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(
                                  left: AppSizes.blockSizeHorizontal * 2 + 8,
                                ),
                                child: Text(
                                  [
                                    if (description.isNotEmpty) description,
                                    "Borrow Period: $borrowDays days",
                                  ].join("\n"),
                                  style: TextStyle(
                                    fontSize: AppSizes.blockSizeVertical * 1.7,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              trailing: Consumer<UserAuthProvider>(
                                builder: (context, auth, _) {
                                  // Check if the user is an admin
                                  final isAdmin =
                                      auth.currentUserProfile?.type
                                          ?.toLowerCase() ==
                                      'admin';

                                  // If not admin, return an empty box
                                  if (!isAdmin) return const SizedBox.shrink();

                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        onPressed:
                                            () => _showEditModal(context, row),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          final id = row['id'] as String?;
                                          if (id != null) {
                                            _confirmDelete(context, id, model);
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
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
