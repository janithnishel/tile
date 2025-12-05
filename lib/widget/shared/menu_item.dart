import 'package:flutter/material.dart';

/// Enhanced navigation menu item model with flexible actions and states
class MenuItem {
  final IconData icon;
  final String title;
  final String? route; // Optional route for navigation
  final VoidCallback? onTap; // Optional custom tap handler
  final bool isEnabled;
  final int? badgeCount; // For notifications, etc.
  final Color? badgeColor;
  final String? permission; // For role-based access control

  const MenuItem({
    required this.icon,
    required this.title,
    this.route,
    this.onTap,
    this.isEnabled = true,
    this.badgeCount,
    this.badgeColor,
    this.permission,
  }) : assert(route != null || onTap != null,
            'Either route or onTap must be provided');

  /// Check if this menu item has a badge
  bool get hasBadge => badgeCount != null && badgeCount! > 0;

  /// Get badge text (max 99+ for large numbers)
  String get badgeText {
    if (badgeCount == null) return '';
    return badgeCount! > 99 ? '99+' : badgeCount.toString();
  }

  /// Create a copy with modified properties
  MenuItem copyWith({
    IconData? icon,
    String? title,
    String? route,
    VoidCallback? onTap,
    bool? isEnabled,
    int? badgeCount,
    Color? badgeColor,
    String? permission,
  }) {
    return MenuItem(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      route: route ?? this.route,
      onTap: onTap ?? this.onTap,
      isEnabled: isEnabled ?? this.isEnabled,
      badgeCount: badgeCount ?? this.badgeCount,
      badgeColor: badgeColor ?? this.badgeColor,
      permission: permission ?? this.permission,
    );
  }
}
