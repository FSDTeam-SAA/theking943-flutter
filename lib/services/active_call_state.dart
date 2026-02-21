import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists active call state to SharedPreferences so the call screen
/// can be restored when the app is killed and reopened during a call.
class ActiveCallState {
  static const String _key = 'active_call_state';

  /// Save active call metadata when a call starts.
  static Future<void> saveActiveCall({
    required String chatId,
    required String userName,
    String? userAvatar,
    required String otherUserId,
    required bool isInitiator,
    required String callType, 
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'chatId': chatId,
        'userName': userName,
        'userAvatar': userAvatar,
        'otherUserId': otherUserId,
        'isInitiator': isInitiator,
        'callType': callType,
        'startTime': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_key, jsonEncode(data));
      debugPrint('Active call state saved: $callType with $userName');
    } catch (e) {
      debugPrint(' Failed to save active call state: $e');
    }
  }

  /// Clear active call state when a call ends normally.
  static Future<void> clearActiveCall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      debugPrint('🧹 Active call state cleared');
    } catch (e) {
      debugPrint('Failed to clear active call state: $e');
    }
  }

  /// Get active call data, or null if no active call.
  /// Returns null if the call is stale (older than 2 minutes).
  static Future<Map<String, dynamic>?> getActiveCall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;

      final data = jsonDecode(raw) as Map<String, dynamic>;

      // Check if the call is stale
      if (data['startTime'] != null) {
        final startTime = DateTime.parse(data['startTime']);
        final age = DateTime.now().difference(startTime).inMinutes;
        if (age > 5) {
          debugPrint(' Active call state is stale ($age min old) — clearing');
          await clearActiveCall();
          return null;
        }
      }

      return data;
    } catch (e) {
      debugPrint('Failed to get active call state: $e');
      return null;
    }
  }

  /// Quick check if there's an active call.
  static Future<bool> hasActiveCall() async {
    final data = await getActiveCall();
    return data != null;
  }
}
