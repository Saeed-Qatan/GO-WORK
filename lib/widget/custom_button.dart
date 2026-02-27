import 'package:flutter/material.dart';
import 'package:gowork/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final Icon? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // 2. Responsive internal padding based on screen width rather than hardcoded pixels
    final horizontalPadding = MediaQuery.of(context).size.width * 0.05;
    final verticalPadding = 16.0;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          // 2. Removed fixed height, using responsive padding
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          // 4. Minimum tap target of 48x48 dp (Material accessibility standard)
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height:
                    24, // slightly larger to scale proportionally with the new padding
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                // 3. Perfect horizontal centering
                mainAxisAlignment: MainAxisAlignment.center,
                // 3. Perfect vertical centering
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  // 5. Handle long text gracefully with Flexible + ellipsis
                  Flexible(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height:
                            1.2, // Ensures stable vertical alignment across languages
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
