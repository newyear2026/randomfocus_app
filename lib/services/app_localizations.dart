import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'wheel': 'Wheel',
      'history': 'History',
      'settings': 'Settings',

      // Roulette Page
      'spin': 'Spin',
      'spinsLeft': 'Spins left today',
      'noSpinsLeft': 'No spins left today',
      'comeBackTomorrow': 'Come back tomorrow!',
      'selectedTime': 'Selected time',
      'startFocus': 'Start Focus',
      'seconds': 'seconds',

      // History Page
      'noHistoryYet': 'No History Yet',
      'completeSessionToSee': 'Complete a focus session to see it here',
      'noSessionsOnThisDay': 'No sessions on this day',
      'selectAnotherDate': 'Select another date to view sessions',
      'sessions': 'Sessions',
      'monthlySessions': 'Monthly',
      'dailySessions': 'Today',
      'monthlyFocused': 'Monthly Focused',
      'dailyFocused': 'Today Focused',
      'focused': 'Focused',
      'minutes': 'minutes',
      'completed': 'Completed',
      'stopped': 'Stopped',
      'actual': 'Actual',

      // Timer Page
      'focus': 'Focus',
      'break': 'Break',
      'ready': 'Ready',
      'running': 'Running...',
      'paused': 'Paused',
      'start': 'Start',
      'stop': 'Stop',
      'endFocusSession': 'End Focus Session',
      'endSessionConfirm': 'Are you sure you want to end this session?',
      'cancel': 'Cancel',
      'end': 'End',

      // Settings Page
      'notifications': 'Notifications',
      'manageAlerts': 'Manage your alerts',
      'language': 'Language',
      'about': 'About',
      'appInformation': 'App information',
      'help': 'Help',
      'howToUse': 'How to Use',
      'howToUseContent':
          '1. Spin the wheel to choose your study time\n'
          '2. Complete your focus session\n'
          '3. Take a break\n'
          '4. Repeat and stay motivated!\n\n'
          'You have 2 attempts per day.',
      'gotIt': 'Got it',
      'close': 'Close',
      'selectLanguage': 'Select Language',
      'appTitle': 'RandomFocus',
      'appVersion': 'Version 1.0.0',
      'appDescription':
          'An app to help you maintain focus with random timer sessions.',

      // Common
      'delete': 'Delete',
      'deleteHistory': 'Delete History',
      'deleteConfirm': 'Are you sure you want to delete this item?',
      'deleteSelectedConfirm':
          'Are you sure you want to delete {count} item(s)?',
      'refresh': 'Refresh',
      'result': 'Result',
      'oneMoreChance': 'You have 1 more chance to spin!',
      'lastAttempt': 'This is your last attempt!',
      'startingTimer': 'Starting timer now...',
      'spinAgain': 'Spin Again',
      'startTimer': 'Start',
      'continue': 'Continue',
      'spinToChoose': 'Spin to choose your focus time',
      'loading': 'Loading...',
      'attemptsToday': 'Attempts today',
      'focusWithRandomTimer': 'Focus with Random Timer',
      'privacyPolicy': 'Privacy Policy',
      'viewPrivacyPolicy': 'View our privacy policy',
      'couldNotOpenUrl': 'Could not open URL',
    },
    'es': {
      // Navigation
      'wheel': 'Rueda',
      'history': 'Historial',
      'settings': 'Configuración',

      // Roulette Page
      'spin': 'Girar',
      'spinsLeft': 'Giros restantes hoy',
      'noSpinsLeft': 'No quedan giros hoy',
      'comeBackTomorrow': '¡Vuelve mañana!',
      'selectedTime': 'Tiempo seleccionado',
      'startFocus': 'Iniciar Enfoque',
      'seconds': 'segundos',

      // History Page
      'noHistoryYet': 'Sin Historial Aún',
      'completeSessionToSee': 'Completa una sesión de enfoque para verla aquí',
      'noSessionsOnThisDay': 'No hay sesiones en este día',
      'selectAnotherDate': 'Selecciona otra fecha para ver sesiones',
      'sessions': 'Sesiones',
      'monthlySessions': 'Mensual',
      'dailySessions': 'Hoy',
      'monthlyFocused': 'Enfocado Mensual',
      'dailyFocused': 'Enfocado Hoy',
      'focused': 'Enfocado',
      'minutes': 'minutos',
      'completed': 'Completado',
      'stopped': 'Detenido',
      'actual': 'Real',

      // Timer Page
      'focus': 'Enfoque',
      'break': 'Descanso',
      'ready': 'Listo',
      'running': 'Ejecutando...',
      'paused': 'Pausado',
      'start': 'Iniciar',
      'stop': 'Detener',
      'endFocusSession': 'Finalizar Sesión de Enfoque',
      'endSessionConfirm':
          '¿Estás seguro de que quieres finalizar esta sesión?',
      'cancel': 'Cancelar',
      'end': 'Finalizar',

      // Settings Page
      'notifications': 'Notificaciones',
      'manageAlerts': 'Administra tus alertas',
      'language': 'Idioma',
      'about': 'Acerca de',
      'appInformation': 'Información de la aplicación',
      'help': 'Ayuda',
      'howToUse': 'Cómo Usar',
      'howToUseContent':
          '1. Gira la rueda para elegir tu tiempo de estudio\n'
          '2. Completa tu sesión de enfoque\n'
          '3. Toma un descanso\n'
          '4. ¡Repite y mantente motivado!\n\n'
          'Tienes 2 intentos por día.',
      'gotIt': 'Entendido',
      'close': 'Cerrar',
      'selectLanguage': 'Seleccionar Idioma',
      'appTitle': 'RandomFocus',
      'appVersion': 'Versión 1.0.0',
      'appDescription':
          'Una aplicación para ayudarte a mantener el enfoque con sesiones de temporizador aleatorias.',

      // Common
      'delete': 'Eliminar',
      'deleteHistory': 'Eliminar Historial',
      'deleteConfirm': '¿Estás seguro de que quieres eliminar este elemento?',
      'deleteSelectedConfirm':
          '¿Estás seguro de que quieres eliminar {count} elemento(s)?',
      'refresh': 'Actualizar',
      'result': 'Resultado',
      'oneMoreChance': '¡Tienes 1 oportunidad más para girar!',
      'lastAttempt': '¡Este es tu último intento!',
      'startingTimer': 'Iniciando temporizador ahora...',
      'spinAgain': 'Girar de Nuevo',
      'startTimer': 'Iniciar Temporizador',
      'continue': 'Continuar',
      'spinToChoose': 'Gira para elegir tu tiempo de enfoque',
      'loading': 'Cargando...',
      'attemptsToday': 'Intentos hoy',
      'focusWithRandomTimer': 'Enfócate con Temporizador Aleatorio',
      'privacyPolicy': 'Política de Privacidad',
      'viewPrivacyPolicy': 'Ver nuestra política de privacidad',
      'couldNotOpenUrl': 'No se pudo abrir la URL',
    },
    'zh': {
      // Navigation
      'wheel': '转盘',
      'history': '历史',
      'settings': '设置',

      // Roulette Page
      'spin': '旋转',
      'spinsLeft': '今日剩余次数',
      'noSpinsLeft': '今日无剩余次数',
      'comeBackTomorrow': '明天再来！',
      'selectedTime': '选择的时间',
      'startFocus': '开始专注',
      'seconds': '秒',

      // History Page
      'noHistoryYet': '暂无历史记录',
      'completeSessionToSee': '完成专注会话后即可查看',
      'noSessionsOnThisDay': '这一天没有会话',
      'selectAnotherDate': '选择其他日期查看会话',
      'sessions': '会话',
      'monthlySessions': '本月',
      'dailySessions': '今日',
      'monthlyFocused': '本月专注',
      'dailyFocused': '今日专注',
      'focused': '专注',
      'minutes': '分钟',
      'completed': '已完成',
      'stopped': '已停止',
      'actual': '实际',

      // Timer Page
      'focus': '专注',
      'break': '休息',
      'ready': '准备',
      'running': '运行中...',
      'paused': '已暂停',
      'start': '开始',
      'stop': '停止',
      'endFocusSession': '结束专注会话',
      'endSessionConfirm': '确定要结束此会话吗？',
      'cancel': '取消',
      'end': '结束',

      // Settings Page
      'notifications': '通知',
      'manageAlerts': '管理您的提醒',
      'language': '语言',
      'about': '关于',
      'appInformation': '应用信息',
      'help': '帮助',
      'howToUse': '使用方法',
      'howToUseContent':
          '1. 转动转盘选择学习时间\n'
          '2. 完成专注会话\n'
          '3. 休息一下\n'
          '4. 重复并保持动力！\n\n'
          '您每天有2次机会。',
      'gotIt': '知道了',
      'close': '关闭',
      'selectLanguage': '选择语言',
      'appTitle': 'RandomFocus',
      'appVersion': '版本 1.0.0',
      'appDescription': '一款通过随机计时器会话帮助您保持专注的应用。',

      // Common
      'delete': '删除',
      'deleteHistory': '删除历史记录',
      'deleteConfirm': '确定要删除此项吗？',
      'deleteSelectedConfirm': '确定要删除 {count} 项吗？',
      'refresh': '刷新',
      'result': '结果',
      'oneMoreChance': '您还有1次旋转机会！',
      'lastAttempt': '这是您的最后一次尝试！',
      'startingTimer': '正在启动计时器...',
      'spinAgain': '再次旋转',
      'startTimer': '启动计时器',
      'continue': '继续',
      'spinToChoose': '旋转选择您的专注时间',
      'loading': '加载中...',
      'attemptsToday': '今日尝试',
      'focusWithRandomTimer': '使用随机计时器专注',
      'privacyPolicy': '隐私政策',
      'viewPrivacyPolicy': '查看我们的隐私政策',
      'couldNotOpenUrl': '无法打开URL',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String translateWithParams(String key, Map<String, String> params) {
    String text = translate(key);
    params.forEach((param, value) {
      text = text.replaceAll('{$param}', value);
    });
    return text;
  }

  // Getters for convenience
  String get wheel => translate('wheel');
  String get history => translate('history');
  String get settings => translate('settings');
  String get spin => translate('spin');
  String get spinsLeft => translate('spinsLeft');
  String get noSpinsLeft => translate('noSpinsLeft');
  String get comeBackTomorrow => translate('comeBackTomorrow');
  String get selectedTime => translate('selectedTime');
  String get startFocus => translate('startFocus');
  String get seconds => translate('seconds');
  String get noHistoryYet => translate('noHistoryYet');
  String get completeSessionToSee => translate('completeSessionToSee');
  String get noSessionsOnThisDay => translate('noSessionsOnThisDay');
  String get selectAnotherDate => translate('selectAnotherDate');
  String get sessions => translate('sessions');
  String get monthlySessions => translate('monthlySessions');
  String get dailySessions => translate('dailySessions');
  String get monthlyFocused => translate('monthlyFocused');
  String get dailyFocused => translate('dailyFocused');
  String get focused => translate('focused');
  String get minutes => translate('minutes');
  String get completed => translate('completed');
  String get stopped => translate('stopped');
  String get actual => translate('actual');
  String get focus => translate('focus');
  String get breakTime => translate('break');
  String get ready => translate('ready');
  String get running => translate('running');
  String get paused => translate('paused');
  String get start => translate('start');
  String get stop => translate('stop');
  String get endFocusSession => translate('endFocusSession');
  String get endSessionConfirm => translate('endSessionConfirm');
  String get cancel => translate('cancel');
  String get end => translate('end');
  String get notifications => translate('notifications');
  String get manageAlerts => translate('manageAlerts');
  String get language => translate('language');
  String get about => translate('about');
  String get appInformation => translate('appInformation');
  String get help => translate('help');
  String get howToUse => translate('howToUse');
  String get howToUseContent => translate('howToUseContent');
  String get gotIt => translate('gotIt');
  String get close => translate('close');
  String get selectLanguage => translate('selectLanguage');
  String get appTitle => translate('appTitle');
  String get appVersion => translate('appVersion');
  String get appDescription => translate('appDescription');
  String get delete => translate('delete');
  String get deleteHistory => translate('deleteHistory');
  String get deleteConfirm => translate('deleteConfirm');
  String deleteSelectedConfirm(int count) =>
      translateWithParams('deleteSelectedConfirm', {'count': count.toString()});
  String get refresh => translate('refresh');
  String get privacyPolicy => translate('privacyPolicy');
  String get viewPrivacyPolicy => translate('viewPrivacyPolicy');
  String get couldNotOpenUrl => translate('couldNotOpenUrl');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
