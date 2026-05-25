import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:gowork/model/feedback_model.dart';
import 'package:gowork/theme/app_colors.dart';
import 'package:gowork/viewmodel/feedback_view_model.dart';
import 'package:gowork/widget/custom_button.dart';

class FeedbackView extends StatelessWidget {
  const FeedbackView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackViewModel(),
      child: const _FeedbackBody(),
    );
  }
}

class _FeedbackBody extends StatefulWidget {
  const _FeedbackBody();

  @override
  State<_FeedbackBody> createState() => _FeedbackBodyState();
}

class _FeedbackBodyState extends State<_FeedbackBody> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  FeedbackType _selectedType = FeedbackType.suggestion;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final viewModel = context.read<FeedbackViewModel>();
    final success = await viewModel.submitFeedback(
      type: _selectedType,
      message: _messageController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? viewModel.successMessage ?? 'تم إرسال الرسالة بنجاح'
              : viewModel.errorMessage ?? 'حدث خطأ غير متوقع',
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
      ),
    );

    if (success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FeedbackViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'الشكاوى والاقتراحات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نوع الرسالة',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _FeedbackTypeOption(
                              type: FeedbackType.suggestion,
                              selectedType: _selectedType,
                              icon: Icons.lightbulb_outline,
                              onSelected: _setFeedbackType,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _FeedbackTypeOption(
                              type: FeedbackType.complaint,
                              selectedType: _selectedType,
                              icon: Icons.report_problem_outlined,
                              onSelected: _setFeedbackType,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _messageController,
                        minLines: 6,
                        maxLines: 8,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: 'اكتب رسالتك',
                          alignLabelWithHint: true,
                          hintText: 'شاركنا اقتراحك أو اكتب تفاصيل الشكوى',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        validator: (value) {
                          final message = value?.trim() ?? '';
                          if (message.isEmpty) {
                            return 'يرجى كتابة الرسالة';
                          }
                          if (message.length < 10) {
                            return 'الرسالة قصيرة جداً';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                CustomButton(
                  text: 'إرسال',
                  isLoading: viewModel.isLoading,
                  onPressed: viewModel.isLoading ? null : _submit,
                  icon: const Icon(Icons.send_outlined, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setFeedbackType(FeedbackType type) {
    setState(() => _selectedType = type);
  }
}

class _FeedbackTypeOption extends StatelessWidget {
  const _FeedbackTypeOption({
    required this.type,
    required this.selectedType,
    required this.icon,
    required this.onSelected,
  });

  final FeedbackType type;
  final FeedbackType selectedType;
  final IconData icon;
  final ValueChanged<FeedbackType> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = type == selectedType;

    return InkWell(
      onTap: () => onSelected(type),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              type.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
