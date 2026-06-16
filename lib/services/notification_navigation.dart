import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Routes local notification taps to in-app navigation.
typedef NotificationRouteHandler = void Function(String location);

NotificationRouteHandler? _routeHandler;

void setNotificationRouteHandler(NotificationRouteHandler? handler) {
  _routeHandler = handler;
}

/// Map notification id → go_router location.
String routeForNotificationId(int id) {
  return switch (id) {
    1 || 7 => '/home',
    2 || 5 => '/clients',
    3 || 6 => '/transactions',
    4 || 8 => '/settings',
    9 => '/finance?tab=wishlist',
    _ => '/home',
  };
}

void handleNotificationResponse(NotificationResponse response) {
  final payload = response.payload?.trim();
  if (payload != null && payload.isNotEmpty && payload.startsWith('/')) {
    _routeHandler?.call(payload);
    return;
  }
  final id = response.id;
  if (id == null) return;
  final route = routeForNotificationId(id);
  debugPrint('Notification tap id=$id → $route');
  _routeHandler?.call(route);
}

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  handleNotificationResponse(response);
}
