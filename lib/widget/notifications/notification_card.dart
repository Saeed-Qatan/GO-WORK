import 'package:flutter/material.dart';

import '../../model/notification_model.dart';
import '../../theme/app_colors.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    final accentColor = _typeColor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: unread
            ? AppColors.primary.withValues(alpha: 0.06)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: unread
                    ? accentColor.withValues(alpha: 0.34)
                    : AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeading(accentColor, unread),
                const SizedBox(width: 12),
                Expanded(child: _buildContent(context, unread)),
                const SizedBox(width: 8),
                _buildTrailing(unread),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(Color color, bool unread) {
    final imageUrl = notification.imageUrl;
    if (imageUrl != null && Uri.tryParse(imageUrl)?.isAbsolute == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imageUrl,
          width: 46,
          height: 46,
          cacheWidth: 138,
          cacheHeight: 138,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildIcon(color, unread),
        ),
      );
    }

    return _buildIcon(color, unread);
  }

  Widget _buildIcon(Color color, bool unread) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: unread
            ? color.withValues(alpha: 0.13)
            : AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        _typeIcon(),
        color: unread ? color : AppColors.textHint,
        size: 22,
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool unread) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
<<<<<<< HEAD
                notification.title,
=======
                notification.displayTitle,
>>>>>>> e-all
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unread) ...[const SizedBox(width: 8), _buildUnreadDot()],
          ],
        ),
        const SizedBox(height: 5),
        Text(
<<<<<<< HEAD
          notification.body,
=======
          notification.displayBody,
>>>>>>> e-all
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.schedule, size: 13, color: AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              _formatDate(notification.createdAt),
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrailing(bool unread) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton(
        tooltip: 'حذف',
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onDelete,
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 20,
          color: unread ? AppColors.error : AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildUnreadDot() {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  IconData _typeIcon() {
    switch (notification.type) {
      case NotificationType.jobCreated:
        return Icons.work_outline;
      case NotificationType.applicationAccepted:
        return Icons.check_circle_outline;
      case NotificationType.applicationRejected:
        return Icons.cancel_outlined;
      case NotificationType.interviewScheduled:
        return Icons.event_available_outlined;
      case NotificationType.general:
      case NotificationType.unknown:
        return Icons.notifications_outlined;
    }
  }

  Color _typeColor() {
    switch (notification.type) {
      case NotificationType.applicationAccepted:
        return AppColors.success;
      case NotificationType.applicationRejected:
        return AppColors.error;
      case NotificationType.interviewScheduled:
        return AppColors.warning;
      case NotificationType.jobCreated:
        return AppColors.primary;
      case NotificationType.general:
      case NotificationType.unknown:
        return AppColors.info;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date.toLocal());

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';

    final localDate = date.toLocal();
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');
    return '${localDate.year}/$month/$day';
  }
}
