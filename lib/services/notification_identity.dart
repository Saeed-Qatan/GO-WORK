import '../model/notification_model.dart';

List<NotificationModel> dedupeNotifications(
  Iterable<NotificationModel> notifications,
) {
  final deduped = <NotificationModel>[];

  for (final notification in notifications) {
    final existingIndex = deduped.indexWhere(
      (item) => notificationsRepresentSameEvent(item, notification),
    );
    if (existingIndex == -1) {
      deduped.add(notification);
    } else {
      deduped[existingIndex] = mergeNotificationModels(
        existing: deduped[existingIndex],
        incoming: notification,
      );
    }
  }

  return deduped..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

NotificationModel mergeNotificationModels({
  required NotificationModel existing,
  required NotificationModel incoming,
}) {
  final existingIsApiBacked = isApiBackedNotification(existing);
  final incomingIsApiBacked = isApiBackedNotification(incoming);
  final canonical = incomingIsApiBacked || !existingIsApiBacked
      ? incoming
      : existing;
  final secondary = identical(canonical, incoming) ? existing : incoming;

  return canonical.copyWith(
    notificationId: canonical.notificationId ?? secondary.notificationId,
    isRead: existing.isRead || incoming.isRead,
    actionUrl: canonical.actionUrl ?? secondary.actionUrl,
    imageUrl: canonical.imageUrl ?? secondary.imageUrl,
  );
}

bool notificationsRepresentSameEvent(
  NotificationModel first,
  NotificationModel second,
) {
  if (first.id == second.id) return true;

  final firstIsApiBacked = isApiBackedNotification(first);
  final secondIsApiBacked = isApiBackedNotification(second);
  final sameType = _normalize(first.typeRaw) == _normalize(second.typeRaw);
  final sameActionUrl = _sameNonEmpty(first.actionUrl, second.actionUrl);
  final sameText =
      _sameNonEmpty(first.title, second.title) ||
      _sameNonEmpty(first.body, second.body);
  final sameNotificationId =
      first.notificationId != null &&
      first.notificationId == second.notificationId;

  if (sameNotificationId && sameType && (sameActionUrl || sameText)) {
    return true;
  }

  if (firstIsApiBacked && secondIsApiBacked) return false;

  return sameType && sameText && _sameOptionalActionUrl(first, second);
}

bool isApiBackedNotification(NotificationModel notification) {
  return notification.deliveryType != NotificationDeliveryType.unknown ||
      (notification.deliveryTypeRaw?.trim().isNotEmpty ?? false);
}

String notificationDebugIdentity(NotificationModel notification) {
  return 'id=${notification.id} '
      'notificationId=${notification.notificationId ?? "-"} '
      'type=${notification.typeRaw} '
      'deliveryType=${notification.deliveryTypeRaw ?? notification.deliveryType.name} '
      'actionUrl=${notification.actionUrl ?? "-"}';
}

String _normalize(String? value) {
  return value?.trim().toLowerCase() ?? '';
}

bool _sameNonEmpty(String? first, String? second) {
  final normalizedFirst = _normalize(first);
  return normalizedFirst.isNotEmpty && normalizedFirst == _normalize(second);
}

bool _sameOptionalActionUrl(NotificationModel first, NotificationModel second) {
  final firstActionUrl = _normalize(first.actionUrl);
  final secondActionUrl = _normalize(second.actionUrl);
  if (firstActionUrl.isEmpty || secondActionUrl.isEmpty) {
    return firstActionUrl.isEmpty && secondActionUrl.isEmpty;
  }
  return firstActionUrl == secondActionUrl;
}
