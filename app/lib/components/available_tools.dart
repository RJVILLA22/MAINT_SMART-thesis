import 'dart:async';
import 'package:app/components/info_container.dart';
import 'package:app/provider/inventory_provider.dart';
import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AvailableToolsScreen extends StatefulWidget {
  const AvailableToolsScreen({super.key});

  @override
  State<AvailableToolsScreen> createState() => _AvailableToolsScreenState();
}

class _AvailableToolsScreenState extends State<AvailableToolsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().startAvailableListener();
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
    context.read<InventoryProvider>().stopAvailableListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizes = AppSizes()..initSizes(context);

    return Consumer<InventoryProvider>(
      builder: (context, inv, _) {
        if (inv.isAvailableLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (inv.availableError != null) {
          return Center(
            child: Text(
              "Error: ${inv.availableError}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (inv.availableTools.isEmpty) {
          return const Center(child: Text("No available tools"));
        }

        // Filter tools based on search query
        final filteredTools =
            inv.availableTools.where((tool) {
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
              text: "Tools that are currently available",
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
                              ? "No available tools"
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
                              title: Text(
                                model,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: maintColor.primaryDark,
                                  fontSize: AppSizes.blockSizeVertical * 2.4,
                                ),
                              ),
                              subtitle: Text(
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
