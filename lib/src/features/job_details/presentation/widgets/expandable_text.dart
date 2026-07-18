import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shows [text] justified. When the text is longer than [trimLength]
/// characters it is collapsed to a preview and a "Read more" / "Read less"
/// toggle is shown. Shorter text is displayed in full with no toggle.
class ExpandableText extends StatefulWidget {
  const ExpandableText({
    super.key,
    required this.text,
    this.trimLength = 1000,
    this.style,
  });

  final String text;
  final int trimLength;
  final TextStyle? style;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.text.trim();
    final bool isLong = text.length > widget.trimLength;

    final textStyle = widget.style ??
        const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.black87,
        );

    // Trim on a word boundary so the preview doesn't cut a word in half.
    String displayText = text;
    if (isLong && !_expanded) {
      var cut = text.substring(0, widget.trimLength);
      final lastSpace = cut.lastIndexOf(' ');
      if (lastSpace > 0) cut = cut.substring(0, lastSpace);
      displayText = '$cut…';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Text(
            displayText,
            textAlign: TextAlign.justify,
            style: textStyle,
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'Read less' : 'Read more',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
