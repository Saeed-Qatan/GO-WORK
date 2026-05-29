import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// A widget that displays password requirements and updates dynamically
/// as the user types.
class PasswordRulesWidget extends StatefulWidget {
  final TextEditingController controller;

  const PasswordRulesWidget({
    super.key,
    required this.controller,
  });

  @override
  State<PasswordRulesWidget> createState() => _PasswordRulesWidgetState();
}

class _PasswordRulesWidgetState extends State<PasswordRulesWidget> {
  String _password = '';

  @override
  void initState() {
    super.initState();
    _password = widget.controller.text;
    widget.controller.addListener(_updatePassword);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updatePassword);
    super.dispose();
  }

  void _updatePassword() {
    if (mounted) {
      setState(() {
        _password = widget.controller.text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMinLength = _password.length >= 8;
    final hasUppercase = _password.contains(RegExp(r'[A-Z]'));
    final hasDigit = _password.contains(RegExp(r'[0-9]'));
    final hasSpecial = _password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'شروط كلمة المرور:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          _buildRuleRow('8 أحرف على الأقل', isMinLength),
          const SizedBox(height: 6),
          _buildRuleRow('حرف كبير واحد على الأقل', hasUppercase),
          const SizedBox(height: 6),
          _buildRuleRow('رقم واحد على الأقل', hasDigit),
          const SizedBox(height: 6),
          _buildRuleRow('رمز خاص واحد على الأقل (!@#\$%^&*)', hasSpecial),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String text, bool isSatisfied) {
    final activeColor = isSatisfied ? AppColors.success : AppColors.textSecondary;
    
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSatisfied 
                ? AppColors.success.withValues(alpha: 0.15) 
                : Colors.transparent,
            border: Border.all(
              color: isSatisfied ? AppColors.success : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: 11,
              color: isSatisfied ? AppColors.success : Colors.transparent,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Cairo',
              color: activeColor,
              fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
