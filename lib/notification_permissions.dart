import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class NotificationPermissions {
  static const MethodChannel _channel =
      const MethodChannel('notification_permissions');

  static Future<PermissionStatus> requestNotificationPermissions(
      {NotificationSettingsIos iosSettings = const NotificationSettingsIos(),
      bool openSettings = true}) async {
    final map = iosSettings.toMap();
    map["openSettings"] = openSettings;
    String status = await _channel.invokeMethod('requestNotificationPermissions', map);
    return _getPermissionStatus(status);
  }

  static Future<PermissionStatus> navigateToNotificationSettings() async {
    String status = await _channel.invokeMethod('navigateToNotificationSettings');
    return _getPermissionStatus(status);
  }

  static Future<PermissionStatus> getNotificationPermissionStatus() async {
    final String status =
        await _channel.invokeMethod('getNotificationPermissionStatus');
    return _getPermissionStatus(status);
  }

  /// Android only. if [channelIds] is null or empty, check all channels status.
  /// Returns [ChannelStatus.available] if at least one of channels is available.
  /// Returns [ChannelStatus.none] if channels has not been created.
  static Future<ChannelStatus> checkChannelsStatus(List<String> channelIds) async {
    if (Platform.isIOS) return ChannelStatus.available;
    final String status = await _channel.invokeMethod('checkChannelsStatus', channelIds ?? []);
    return _getChannelStatus(status);
  }

  /// Gets the PermissionStatus from the channel Method
  ///
  /// Given a [String] status from the method channel, it returns a
  /// [PermissionStatus]
  static PermissionStatus _getPermissionStatus(String status) {
    switch (status) {
      case "denied":
        return PermissionStatus.denied;
      case "granted":
        return PermissionStatus.granted;
      default:
        return PermissionStatus.unknown;
    }
  }

  /// Gets the ChannelStatus from the channel Method
  ///
  /// Given a [String] status from the method channel, it returns a
  /// [ChannelStatus]
  static ChannelStatus _getChannelStatus(String status) {
    switch (status) {
      case "none":
        return ChannelStatus.none;
      case "unavailable":
        return ChannelStatus.unavailable;
      default:
        return ChannelStatus.available;
    }
  }
}

enum PermissionStatus { granted, unknown, denied }
enum ChannelStatus { none, unavailable, available }

class NotificationSettingsIos {
  const NotificationSettingsIos({
    this.sound = true,
    this.alert = true,
    this.badge = true,
  });

  NotificationSettingsIos._fromMap(Map<String, bool> settings)
      : sound = settings['sound'],
        alert = settings['alert'],
        badge = settings['badge'];

  final bool sound;
  final bool alert;
  final bool badge;

  @visibleForTesting
  Map<String, dynamic> toMap() {
    return <String, bool>{'sound': sound, 'alert': alert, 'badge': badge};
  }

  @override
  String toString() => 'PushNotificationSettings ${toMap()}';
}
