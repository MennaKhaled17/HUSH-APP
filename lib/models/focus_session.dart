import 'package:flutter/material.dart';

class FocusMode {
  final String name;
  final String description;
  final int defaultMinutes;
  final Color color;
  final Color bgColor;
  List<String> blockedApps;
  final bool isCustom;

  FocusMode({
    required this.name,
    required this.description,
    required this.defaultMinutes,
    required this.color,
    required this.bgColor,
    List<String>? blockedApps,
    this.isCustom = false,
  }) : blockedApps = blockedApps ?? [];

  static final List<FocusMode> defaults = [
    FocusMode(
      name: 'Study',
      description: 'Deep focus for learning',
      defaultMinutes: 25,
      color: const Color(0xFF4CAF7D),
      bgColor: const Color(0xFF0D1F16),
      blockedApps: ['Instagram', 'TikTok', 'YouTube', 'Twitter'],
    ),
    FocusMode(
      name: 'Work',
      description: 'Professional deep work',
      defaultMinutes: 50,
      color: const Color(0xFF5B8AF0),
      bgColor: const Color(0xFF0D1226),
      blockedApps: ['Instagram', 'TikTok', 'Games'],
    ),
    FocusMode(
      name: 'Gym',
      description: 'Workout without distractions',
      defaultMinutes: 60,
      color: const Color(0xFFE05C5C),
      bgColor: const Color(0xFF1F0D0D),
      blockedApps: ['Instagram', 'Twitter', 'News'],
    ),
    FocusMode(
      name: 'Me Time',
      description: 'Rest and recharge',
      defaultMinutes: 30,
      color: const Color(0xFF9B7FD4),
      bgColor: const Color(0xFF130F1E),
      blockedApps: ['Work emails', 'Slack'],
    ),
    FocusMode(
      name: 'Family',
      description: 'Quality family time',
      defaultMinutes: 120,
      color: const Color(0xFFE8855A),
      bgColor: const Color(0xFF1F110A),
      blockedApps: ['Instagram', 'TikTok', 'Twitter', 'Work apps'],
    ),
  ];

  static const List<String> allApps = [
    'Instagram', 'TikTok', 'YouTube', 'Twitter',
    'Facebook', 'Snapchat', 'WhatsApp', 'Telegram',
    'Games', 'News', 'Slack', 'Work emails', 'All apps',
  ];

  static const List<Color> customColors = [
    Color(0xFF4CAF7D),
    Color(0xFF5B8AF0),
    Color(0xFFE05C5C),
    Color(0xFF9B7FD4),
    Color(0xFFE8855A),
    Color(0xFFC9A84C),
  ];
}

class FocusSession {
  final FocusMode mode;
  final DateTime startTime;
  DateTime? endTime;
  bool completed;
  bool interrupted; // interrupted by prayer

  FocusSession({
    required this.mode,
    required this.startTime,
    this.endTime,
    this.completed = false,
    this.interrupted = false,
  });
}