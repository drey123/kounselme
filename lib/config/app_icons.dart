// lib/config/app_icons.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Centralized icon system for KounselMe
/// 
/// This class maps semantic icon names to the actual icon data
/// from the Material Symbols icon package.
/// 
/// Using this abstraction makes it easy to switch icon packages in the future
/// without changing all icon references throughout the app.
class AppIcons {
  // Private constructor to prevent instantiation
  AppIcons._();
  
  // Default icon properties
  static const int defaultWeight = 400;
  static const int defaultFill = 0;
  static const int defaultGrade = 0;
  static const int defaultOpticalSize = 24;
  
  // NAVIGATION
  static IconData get home => Symbols.home_rounded;
  static IconData get chat => Symbols.chat_rounded;
  static IconData get journal => Symbols.book_rounded;
  static IconData get profile => Symbols.person_rounded;
  static IconData get settings => Symbols.settings_rounded;
  static IconData get menu => Symbols.menu_rounded;
  static IconData get back => Symbols.arrow_back_rounded;
  static IconData get close => Symbols.close_rounded;
  
  // ACTIONS
  static IconData get add => Symbols.add_rounded;
  static IconData get edit => Symbols.edit_rounded;
  static IconData get delete => Symbols.delete_rounded;
  static IconData get search => Symbols.search_rounded;
  static IconData get filter => Symbols.filter_list_rounded;
  static IconData get sort => Symbols.sort_rounded;
  static IconData get share => Symbols.share_rounded;
  static IconData get more => Symbols.more_vert_rounded;
  static IconData get send => Symbols.send_rounded;
  
  // CHAT SPECIFIC
  static IconData get microphone => Symbols.mic_rounded;
  static IconData get typing => Symbols.chat_bubble_outline_rounded;
  static IconData get addUser => Symbols.person_add_rounded;
  static IconData get timer => Symbols.timer_rounded;
  static IconData get calendar => Symbols.calendar_month_rounded;
  static IconData get time => Symbols.schedule_rounded;
  static IconData get upload => Symbols.upload_file_rounded;
  static IconData get export => Symbols.ios_share_rounded;
  static IconData get users => Symbols.group_rounded;
  static IconData get appleCalendar => Symbols.event_rounded;
  static IconData get googleCalendar => Symbols.event_note_rounded;
  
  // STATUS & FEEDBACK
  static IconData get success => Symbols.check_circle_rounded;
  static IconData get error => Symbols.error_rounded;
  static IconData get warning => Symbols.warning_rounded;
  static IconData get info => Symbols.info_rounded;
  static IconData get lock => Symbols.lock_rounded;
  static IconData get unlock => Symbols.lock_open_rounded;
  static IconData get verified => Symbols.verified_rounded;
  static IconData get person => Symbols.person_rounded;
  
  // MISC
  static IconData get star => Symbols.star_rounded;
  static IconData get heart => Symbols.favorite_rounded;
  static IconData get bell => Symbols.notifications_rounded;
  static IconData get bookmark => Symbols.bookmark_rounded;
  static IconData get attachment => Symbols.attach_file_rounded;
  static IconData get link => Symbols.link_rounded;
  static IconData get location => Symbols.location_on_rounded;
  static IconData get camera => Symbols.camera_alt_rounded;
  static IconData get image => Symbols.image_rounded;
  static IconData get video => Symbols.videocam_rounded;
  static IconData get play => Symbols.play_arrow_rounded;
  static IconData get pause => Symbols.pause_rounded;
  static IconData get stop => Symbols.stop_rounded;
  
  // ADDITIONS FOR CHAT APPLICATION
  static IconData get arrowRight => Symbols.arrow_forward_rounded;
  static IconData get addCircle => Symbols.add_circle_rounded;
  static IconData get money => Symbols.attach_money_rounded;
  static IconData get timerPause => Symbols.timer_off_rounded;
  static IconData get sendTime => Symbols.schedule_send_rounded;
  static IconData get voiceWave => Symbols.graphic_eq_rounded;
  static IconData get thinking => Symbols.psychology_rounded;  // For AI thinking indicator
  static IconData get brain => Symbols.cognition_rounded; // For AI deep thinking
  static IconData get clock => Symbols.access_time_rounded;
  static IconData get refresh => Symbols.refresh_rounded;
  static IconData get download => Symbols.download_rounded;
  static IconData get topic => Symbols.topic_rounded;
  static IconData get sentiment => Symbols.sentiment_satisfied_alt_rounded;
  
  // Get icon with custom properties (for Material Symbols)
  static IconData getWithProperties({
    required IconData icon,
    int weight = defaultWeight,
    int fill = defaultFill,
    int grade = defaultGrade,
    int opticalSize = defaultOpticalSize,
  }) {
    // Only works with Material Symbols icons
    if (icon.fontFamily == 'MaterialSymbols') {
      return IconData(
        icon.codePoint,
        fontFamily: icon.fontFamily,
        fontPackage: icon.fontPackage,
        matchTextDirection: icon.matchTextDirection,
      );
    }
    
    // Return the original icon if not a Material Symbols icon
    return icon;
  }
  
  // Convenience method to get filled version of an icon
  static IconData filled(IconData icon) {
    return getWithProperties(icon: icon, fill: 1);
  }
  
  // Convenience method to get bold version of an icon
  static IconData bold(IconData icon) {
    return getWithProperties(icon: icon, weight: 700);
  }
  
  // Convenience method to get light version of an icon
  static IconData light(IconData icon) {
    return getWithProperties(icon: icon, weight: 300);
  }
  
  // Convenience method to get large version of an icon (for titles, headers)
  static IconData large(IconData icon) {
    return getWithProperties(icon: icon, opticalSize: 40, weight: 500);
  }
  
  // Convenience method for small icons (for dense UIs)
  static IconData small(IconData icon) {
    return getWithProperties(icon: icon, opticalSize: 20);
  }
  
  // Specific combinations for chat UI
  
  // Navigation bar icons - slightly bolder, slightly filled
  static IconData navBar(IconData icon) {
    return getWithProperties(
      icon: icon, 
      weight: 500, 
      fill: 1, 
      opticalSize: 24
    );
  }
  
  // Action icons - bold but not filled
  static IconData action(IconData icon) {
    return getWithProperties(
      icon: icon, 
      weight: 600, 
      fill: 0, 
      opticalSize: 24
    );
  }
}