import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:provider/provider.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/constants.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final theme = Theme.of(context);

    // 🎨 Detect current theme mode based on themeIndex
    final int index = themeController.themeIndex;
    final bool isDark = index == 2; // 0 = Default, 1 = Light, 2 = Dark

    // 🌗 Adjust shimmer colors based on theme
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade600 : Colors.grey.shade100;

    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(10),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              // ✅ Uses theme card color dynamically
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: theme.dividerColor.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
