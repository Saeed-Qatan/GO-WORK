import 'package:flutter/material.dart';
import 'package:gowork/viewmodel/delete_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gowork/routing/app_router.dart';
import 'package:gowork/utils/snackbar_service.dart';
import 'package:gowork/utils/session_state_reset.dart';


/// زر حذف الحساب — نفس تصميم LogoutButton تماماً
/// يتبع نمط MVVM مع Provider
class DeleteAccountButton extends StatelessWidget {
  const DeleteAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeleteAccountViewModel(),
      child: const _DeleteAccountButtonContent(),
    );
  }
}

class _DeleteAccountButtonContent extends StatelessWidget {
  const _DeleteAccountButtonContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DeleteAccountViewModel>();

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: vm.isLoading ? null : () => _handleDeleteAccount(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          foregroundColor: Colors.red,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: vm.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'حذف الحساب',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      strutStyle: StrutStyle(height: 1.0, forceStrutHeight: true),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    // ① Dialog تأكيد الحذف
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'حذف الحساب',
          textAlign: TextAlign.right,
        ),
        content: const Text(
          'هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟\nلن تتمكن من استرداد بياناتك بعد الحذف.',
          textAlign: TextAlign.right,
          style: TextStyle(height: 1.6),
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'حذف نهائي',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    // ② تنفيذ الحذف عبر ViewModel
    final vm = context.read<DeleteAccountViewModel>();
    await vm.deleteAccount();

    if (!context.mounted) return;

    // ③ معالجة النتيجة
    if (vm.isDeleted) {
      SnackbarService.showSuccess('تم حذف الحساب بنجاح');
      // مسح جميع بيانات الجلسة من الذاكرة (ViewModels)
      resetSessionState(context);
      context.go(AppRoutes.login);
    } else if (vm.errorMessage != null) {
      SnackbarService.showError(vm.errorMessage!);
    }
  }
}
