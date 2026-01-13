import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchBarWithFilter extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;

  const SearchBarWithFilter({
    super.key,
    this.hintText = 'Enter Job Title',
    this.onTap,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors from design
    const kSearchIconColor = Color(0xFF00A3FF); // Bright Blue
    const kBorderColor = Color(0xFF26A4FF);

    return Row(
      children: [
        // Search Input Area (Expanded Pill)
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: kBorderColor, width: 1),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  // Blue circle with search icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: kSearchIconColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hint Text
                  Text(
                    hintText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Filter Button (Separate Circle)
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kBorderColor, width: 1),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: kSearchIconColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}