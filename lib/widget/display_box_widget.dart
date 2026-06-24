import 'package:gowork/theme/app_colors.dart';
import 'package:flutter/material.dart';

class DisplayBoxWidget extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const DisplayBoxWidget({super.key, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Icon(icon, size: 45, color: Colors.white),
          ),
          child,
        ],
      ),
    );
  }
}
