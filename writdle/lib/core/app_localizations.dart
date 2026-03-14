import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return localizations ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'app_title': 'Writdle App',
      'settings': 'Settings',
      'appearance': 'Appearance',
      'language': 'Language',
      'theme_mode': 'Theme mode',
      'theme_mode_subtitle': 'Choose how the whole app looks.',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'english': 'English',
      'arabic': 'Arabic',
      'text_size': 'Text size',
      'current_scale': 'Current scale: {value}x',
      'reduce_motion': 'Reduce motion',
      'reduce_motion_subtitle': 'Use calmer transitions and animations.',
      'wordle_setup': 'Wordle Setup',
      'difficulty_level': 'Difficulty level',
      'next_round_time': 'Next round time',
      'every_6_hours': 'Every 6 hours',
      'every_12_hours': 'Every 12 hours',
      'every_24_hours': 'Every 24 hours',
      'daily_game_reminder': 'Daily game reminder',
      'daily_game_reminder_subtitle': 'Show a local reminder outside the app every day.',
      'reminder_time': 'Reminder time',
      'wordle_setup_help': 'Difficulty controls the number of attempts. Next round time controls when the game becomes available again after finishing. Daily reminder shows a local notification at your chosen time.',
      'competitive_layout': 'Competitive layout',
      'competitive_layout_subtitle': 'Use a sharper, match-style game presentation.',
      'high_contrast_colors': 'High contrast colors',
      'high_contrast_colors_subtitle': 'Improve tile and keyboard visibility.',
      'manual_restart_only': 'Manual restart only',
      'manual_restart_only_subtitle': 'Keep finished rounds until you restart yourself.',
      'show_gameplay_hints': 'Show gameplay hints',
      'show_gameplay_hints_subtitle': 'Display helper text around results and states.',
      'show_attempt_badge': 'Show attempt badge',
      'show_attempt_badge_subtitle': 'Display the live attempt counter on the game HUD.',
      'show_countdown_badge': 'Show countdown badge',
      'show_countdown_badge_subtitle': 'Display cooldown timer on the game HUD after finishing.',
      'home': 'Home',
      'wordle': 'Wordle',
      'notes': 'Notes',
      'activity': 'Activity',
      'profile': 'Profile',
      'quick_focus': 'Quick Focus',
      'quick_focus_subtitle': 'Move fast between your core spaces.',
      'play_wordle': 'Play Wordle',
      'play_wordle_subtitle': 'Warm up your mind with today\'s challenge.',
      'open_notes': 'Open Notes',
      'open_notes_subtitle': 'Capture ideas before they fade.',
      'view_activity': 'View Activity',
      'view_activity_subtitle': 'Track your progress for today.',
      'today_snapshot': 'Today Snapshot',
      'today_snapshot_subtitle': 'A compact pulse on your momentum.',
      'completed': 'Completed',
      'remaining': 'Remaining',
      'win_rate': 'Win Rate',
      'tasks_done_today': 'Tasks done today',
      'tasks_still_open': 'Tasks still open',
      'game_performance': 'Game performance',
      'recent_wins': 'Recent Wins',
      'recent_wins_subtitle': 'Small highlights keep the rhythm going.',
      'your_daily_activity': 'Your Daily Activity',
      'daily_progress': 'Daily Progress: {completed} / {total}',
      'activity_saved_locally': 'All activity data and task changes are saved locally on this phone.',
      'manage_tasks': 'Manage Tasks',
      'no_tasks_for_day': 'No tasks for this day. Add some!',
      'all_caught_up': 'All caught up for today!',
      'wordle_game': 'Wordle Game',
      'game_settings_applied': 'Game settings applied.',
      'new_round_started': 'New round started.',
      'round_in_progress': 'Round In Progress',
      'victory_locked': 'Victory Locked',
      'round_closed': 'Round Closed',
      'attempt': 'Attempt',
      'restart': 'Restart',
      'stats': 'Stats',
      'match_state': 'Match State',
      'performance_overview': 'Performance Overview',
      'performance_overview_subtitle': 'Your local Wordle record, win spread, and latest round summary.',
      'games': 'Games',
      'wins': 'Wins',
      'losses': 'Losses',
      'attempt_breakdown': 'Attempt Breakdown',
      'attempt_breakdown_subtitle': 'See how often you finish in each round window.',
      'back_to_game': 'Back to game',
      'reset_statistics': 'Reset statistics',
      'reset_statistics_message': 'This will clear all saved Wordle performance data on this device.',
      'cancel': 'Cancel',
      'reset': 'Reset',
      'notes_empty': 'No notes yet',
      'new_note': 'New Note',
      'manage_tasks_title': 'Manage Tasks',
      'back_to_activity': 'Back to activity',
      'task_title_required': 'Task title is required.',
      'reminder_future': 'Reminder time must be in the future.',
      'task_saved_reminder': 'Task saved and reminder scheduled.',
      'task_added': 'Task added.',
      'task_updated': 'Task updated.',
      'note_saved': 'Note saved successfully.',
      'note_updated': 'Note updated successfully.',
      'note_deleted': 'Note deleted.',
      'note_title_required': 'Please enter a note title.',
      'my_profile': 'My Profile',
      'profile_updated': 'Profile updated successfully.',
      'login_name_title': 'Your name',
      'continue': 'Continue',
      'writer': 'Writer',
      'profile_saved_local': 'Profile saved on this device.',
      'profile_save_failed': 'Unable to save your profile right now.',
    },
    'ar': {
      'app_title': 'وريتدل',
      'settings': 'الإعدادات',
      'appearance': 'المظهر',
      'language': 'اللغة',
      'theme_mode': 'وضع المظهر',
      'theme_mode_subtitle': 'اختر شكل التطبيق بالكامل.',
      'system': 'النظام',
      'light': 'فاتح',
      'dark': 'داكن',
      'english': 'الإنجليزية',
      'arabic': 'العربية',
      'text_size': 'حجم النص',
      'current_scale': 'المقياس الحالي: {value}x',
      'reduce_motion': 'تقليل الحركة',
      'reduce_motion_subtitle': 'استخدم انتقالات وحركات أهدأ.',
      'wordle_setup': 'إعدادات ووردل',
      'difficulty_level': 'مستوى الصعوبة',
      'next_round_time': 'وقت الجولة التالية',
      'every_6_hours': 'كل 6 ساعات',
      'every_12_hours': 'كل 12 ساعة',
      'every_24_hours': 'كل 24 ساعة',
      'daily_game_reminder': 'تذكير اللعبة اليومي',
      'daily_game_reminder_subtitle': 'أظهر تذكيرًا محليًا خارج التطبيق كل يوم.',
      'reminder_time': 'وقت التذكير',
      'wordle_setup_help': 'الصعوبة تتحكم في عدد المحاولات. وقت الجولة التالية يحدد متى تتاح اللعبة مرة أخرى بعد الانتهاء. التذكير اليومي يرسل إشعارًا محليًا في الوقت الذي تختاره.',
      'competitive_layout': 'واجهة تنافسية',
      'competitive_layout_subtitle': 'استخدم عرضًا أكثر حدة وأقرب لأجواء المباريات.',
      'high_contrast_colors': 'ألوان عالية التباين',
      'high_contrast_colors_subtitle': 'حسّن وضوح المربعات ولوحة المفاتيح.',
      'manual_restart_only': 'إعادة تشغيل يدوية فقط',
      'manual_restart_only_subtitle': 'احتفظ بالجولة المنتهية حتى تعيد التشغيل بنفسك.',
      'show_gameplay_hints': 'إظهار تلميحات اللعب',
      'show_gameplay_hints_subtitle': 'اعرض نصوصًا مساعدة حول النتائج والحالات.',
      'show_attempt_badge': 'إظهار شارة المحاولة',
      'show_attempt_badge_subtitle': 'اعرض عداد المحاولة الحالي في واجهة اللعبة.',
      'show_countdown_badge': 'إظهار شارة العد التنازلي',
      'show_countdown_badge_subtitle': 'اعرض مؤقت التهدئة بعد انتهاء الجولة.',
      'home': 'الرئيسية',
      'wordle': 'ووردل',
      'notes': 'الملاحظات',
      'activity': 'النشاط',
      'profile': 'الملف الشخصي',
      'quick_focus': 'وصول سريع',
      'quick_focus_subtitle': 'تحرك بسرعة بين أقسامك الأساسية.',
      'play_wordle': 'العب ووردل',
      'play_wordle_subtitle': 'ابدأ يومك بتحدي ذهني سريع.',
      'open_notes': 'افتح الملاحظات',
      'open_notes_subtitle': 'سجّل أفكارك قبل أن تضيع.',
      'view_activity': 'عرض النشاط',
      'view_activity_subtitle': 'تابع تقدمك لليوم.',
      'today_snapshot': 'ملخص اليوم',
      'today_snapshot_subtitle': 'نظرة سريعة ومركزة على تقدمك.',
      'completed': 'المكتمل',
      'remaining': 'المتبقي',
      'win_rate': 'نسبة الفوز',
      'tasks_done_today': 'مهام أُنجزت اليوم',
      'tasks_still_open': 'مهام ما زالت مفتوحة',
      'game_performance': 'أداء اللعبة',
      'recent_wins': 'الإنجازات الأخيرة',
      'recent_wins_subtitle': 'النجاحات الصغيرة تحافظ على الإيقاع.',
      'your_daily_activity': 'نشاطك اليومي',
      'daily_progress': 'تقدم اليوم: {completed} / {total}',
      'activity_saved_locally': 'جميع بيانات النشاط وتغييرات المهام محفوظة محليًا على هذا الهاتف.',
      'manage_tasks': 'إدارة المهام',
      'no_tasks_for_day': 'لا توجد مهام لهذا اليوم. أضف بعضًا منها!',
      'all_caught_up': 'تم إنجاز كل شيء لهذا اليوم!',
      'wordle_game': 'لعبة ووردل',
      'game_settings_applied': 'تم تطبيق إعدادات اللعبة.',
      'new_round_started': 'بدأت جولة جديدة.',
      'round_in_progress': 'الجولة جارية',
      'victory_locked': 'تم تثبيت الفوز',
      'round_closed': 'أغلقت الجولة',
      'attempt': 'محاولة',
      'restart': 'إعادة',
      'stats': 'الإحصائيات',
      'match_state': 'حالة المباراة',
      'performance_overview': 'ملخص الأداء',
      'performance_overview_subtitle': 'سجلك المحلي في ووردل وتوزيع الفوز وملخص آخر جولة.',
      'games': 'الألعاب',
      'wins': 'الانتصارات',
      'losses': 'الخسائر',
      'attempt_breakdown': 'توزيع المحاولات',
      'attempt_breakdown_subtitle': 'شاهد عدد مرات إنهاء الجولة في كل نافذة محاولة.',
      'back_to_game': 'العودة إلى اللعبة',
      'reset_statistics': 'إعادة ضبط الإحصائيات',
      'reset_statistics_message': 'سيؤدي هذا إلى مسح جميع بيانات أداء ووردل المحفوظة على هذا الجهاز.',
      'cancel': 'إلغاء',
      'reset': 'إعادة ضبط',
      'notes_empty': 'لا توجد ملاحظات بعد',
      'new_note': 'ملاحظة جديدة',
      'manage_tasks_title': 'إدارة المهام',
      'back_to_activity': 'العودة إلى النشاط',
      'task_title_required': 'عنوان المهمة مطلوب.',
      'reminder_future': 'وقت التذكير يجب أن يكون في المستقبل.',
      'task_saved_reminder': 'تم حفظ المهمة وجدولة التذكير.',
      'task_added': 'تمت إضافة المهمة.',
      'task_updated': 'تم تحديث المهمة.',
      'note_saved': 'تم حفظ الملاحظة بنجاح.',
      'note_updated': 'تم تحديث الملاحظة بنجاح.',
      'note_deleted': 'تم حذف الملاحظة.',
      'note_title_required': 'من فضلك أدخل عنوان الملاحظة.',
      'my_profile': 'ملفي الشخصي',
      'profile_updated': 'تم تحديث الملف الشخصي بنجاح.',
      'login_name_title': 'اسمك',
      'continue': 'متابعة',
      'writer': 'كاتب',
      'profile_saved_local': 'تم حفظ الملف الشخصي على هذا الجهاز.',
      'profile_save_failed': 'تعذر حفظ الملف الشخصي الآن.',
    },
  };

  String t(String key, [Map<String, String>? args]) {
    final languageCode = _values.containsKey(locale.languageCode)
        ? locale.languageCode
        : 'en';
    var text = _values[languageCode]?[key] ?? _values['en']?[key] ?? key;
    args?.forEach((placeholder, value) {
      text = text.replaceAll('{$placeholder}', value);
    });
    return text;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}


