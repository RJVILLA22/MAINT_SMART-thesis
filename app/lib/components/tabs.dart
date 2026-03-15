import 'package:app/components/all_borrowed.dart';
import 'package:app/components/all_tools.dart';
import 'package:app/components/available_tools.dart';
import 'package:app/components/borrowed_tools.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

// replace the whole ScrollableTabComponent class with this version

class ScrollableTabComponent extends StatefulWidget {
  const ScrollableTabComponent({Key? key}) : super(key: key);

  @override
  State<ScrollableTabComponent> createState() => _ScrollableTabComponentState();
}

class _ScrollableTabComponentState extends State<ScrollableTabComponent> {
  int selectedIndex = 0; // Default tab
  final List<String> tabs = ['MY TOOLS', 'BORROWED', 'AVAILABLE', 'ALL TOOLS'];

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      MyBorrowedScreen(),
      BorrowedToolsScreen(),
      AvailableToolsScreen(),
      AllToolsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar (acts like the AppBar)

        // Tabs
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tabs.length, (index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? maintColor.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : maintColor.grayText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // Content area (must be constrained — use Expanded)
        Expanded(
          child: IndexedStack(
            index: selectedIndex,
            children: [
              // Ensure screens are able to take available space (ListView, etc.)
              for (var s in screens) SizedBox.expand(child: s),
              // If you have fewer screens than tabs, fill the rest with placeholders:
              if (screens.length < tabs.length)
                for (int i = screens.length; i < tabs.length; i++)
                  Center(child: Text("${tabs[i]} (not implemented)")),
            ],
          ),
        ),
      ],
    );
  }
}
