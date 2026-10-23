import 'package:flutter/material.dart';

import '../models/app_language.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static String text(BuildContext context, String key) =>
      (of(context) ?? AppLocalizations(const Locale('en'))).translate(key);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Pro phase 1
      "proTitle": "RandomFocus Pro",
      "proTagline": "Focus your way",
      "proAdFree": "Ad-free focus",
      "proAdFreeDesc": "Keep the timer clear of banner and interstitial ads.",
      "proCustomTimes": "Times & probabilities",
      "proCustomTimesDesc":
          "Choose durations and adjust how often each is selected.",
      "proPresets": "Focus presets",
      "proPresetsDesc": "Save, edit and apply your favorite combinations.",
      "proKeepFree": "Continue with the free timer",
      "proUnavailable":
          "Purchases are not available yet. Your free timer and basic history remain available.",
      "proChecking": "Checking your purchases…",
      "proPending": "Purchase pending. Pro unlocks after verification.",
      "proCanceled": "Purchase canceled. Your access has not changed.",
      "proError":
          "The purchase could not be verified. Try again or restore purchases.",
      "proNoPurchases": "No Pro purchase was found.",
      "proUpgradePrice": "Upgrade · {price}",
      "proRestore": "Restore purchases",
      "proPurchaseUnavailable": "Purchase unavailable",
      "proActive": "Pro is active",
      "focusChoices": "Focus durations",
      "focusWeights": "Selection probabilities",
      "focusAutoAdjust":
          "Other probabilities adjust automatically. Only selected durations are drawn.",
      "focusEqualize": "Equalize",
      "focusSave": "Save settings",
      "focusAtLeastOne": "Keep at least one duration selected.",
      "focusTotal": "Total 100%",
      "focusError": "Could not save your changes. Please try again.",
      "focusNameError": "Use a unique name with 1–40 characters.",
      "focusPresetName": "Preset name",
      "focusNameHint": "Study or Work",
      "focusNewPreset": "New preset",
      "focusApply": "Apply",
      "focusEdit": "Edit",
      "focusInUse": "In use",
      "focusPresetEmpty": "Save a combination to use it again with one tap.",
      "focusPreview":
          "Preview · Pro is required to save and apply custom settings.",
      "focusCustomSummary": "Your saved probabilities determine the result.",
      "focusProNeeded": "Explore Pro",
      "focusPresetDelete":
          "Delete this preset? Your current timer will not be affected.",
      "focusSettingsLoadError":
          "Saved settings could not be loaded. Try again.",
      "focusInvalidSaved":
          "Some saved settings were invalid. Your valid presets are still available.",
      "focusPresetSave": "Save preset",
      "focusRetry": "Try again",
      "focusSingle": "One selected duration",
      "focusDiscard": "Discard unsaved changes?",
      "focusDiscardAction": "Discard",

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
      'noHistoryYet': 'No history yet',
      'completeSessionToSee': 'Complete a focus session to view it here.',
      'noSessionsOnThisDay': 'No sessions for this day',
      'selectAnotherDate': 'Choose another date to view sessions.',
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
      'goBack': 'Would you like to go back?',
      'goBackConfirm': 'Would you like to exit the timer page?',
      'goBackButton': 'Go Back',
      'cancel': 'Cancel',
      'end': 'End',
      'focusCompleteTitle': 'Focus complete',
      'focusCompleteBody': 'Great work. Your 10-minute break starts now.',
      'breakCompleteTitle': 'Break complete',
      'breakCompleteBody': 'Your break is over. Ready to focus again?',
      'returningToWheel': 'Returning to Wheel',
      'goNow': 'Go now',

      // Settings Page
      'preferences': 'Preferences',
      'information': 'Information',
      'theme': 'Theme',
      'selectTheme': 'Select theme',
      'themeSystem': 'System default',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeUpdated': 'Theme updated.',
      'focusProgress': 'Focus progress',
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
      'languageSystem': 'System default',
      'languageSystemDesc': 'Follow your device language',
      'appTitle': 'RandomFocus',
      'appVersion': 'Version 1.0.0',
      'version': 'Version',
      'appUpdated': 'RandomFocus has been updated',
      'whatsNew': "What's new",
      'viewLatestChanges': 'View the latest changes',
      'releaseNoteTimer': 'The timer now completes at the correct time.',
      'releaseNoteNotice':
          'See this update summary when a new version is installed.',
      'releaseNoteVersion':
          'The About screen now shows your installed app version.',
      'releaseNotePlayUpdate':
          'Get a friendly reminder when a new version is available on Google Play.',
      'updateAvailable': 'Update available',
      'updateAvailableMessage':
          'A new version of RandomFocus is ready. Update now to enjoy the latest improvements.',
      'updateNow': 'Update now',
      'later': 'Later',
      'appDescription':
          'An app to help you maintain focus with random timer sessions.',
      'languageUpdated': 'Language updated.',
      'selectedOption': 'Selected',
      'tapToSelect': 'Tap to choose',
      'privacyPolicySheetSummary': 'Review the policy link.',
      'privacyPolicySheetBody':
          'Review the policy link before opening it in your browser.',
      'policyUrlLabel': 'Policy URL',
      'openInBrowser': 'Open in browser',
      'openWheelTab': 'Open wheel tab',
      'openHistoryTab': 'Open history tab',
      'openSettingsTab': 'Open settings tab',
      'closeTimerPage': 'Close timer page',
      'resetTimer': 'Reset timer',
      'spinWheel': 'Spin wheel',
      'saveAppIcon': 'Save app icon',
      'refreshHistory': 'Refresh history',

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
      'couldNotOpenUrl': 'Could not open the privacy policy.',

      // Ads
      'adLoading': 'Loading ad...',
      'adUnavailable': 'Ad unavailable',
    },
    'es': {
      // Pro phase 1
      "proTitle": "RandomFocus Pro",
      "proTagline": "Concéntrate a tu manera",
      "proAdFree": "Concentración sin anuncios",
      "proAdFreeDesc":
          "Usa el temporizador sin banners ni anuncios intersticiales.",
      "proCustomTimes": "Tiempos y probabilidades",
      "proCustomTimesDesc":
          "Elige duraciones y ajusta la frecuencia de cada una.",
      "proPresets": "Preajustes de enfoque",
      "proPresetsDesc": "Guarda, edita y aplica tus combinaciones favoritas.",
      "proKeepFree": "Continuar con el temporizador gratuito",
      "proUnavailable":
          "Las compras aún no están disponibles. El temporizador y el historial básico siguen siendo gratuitos.",
      "proChecking": "Comprobando tus compras…",
      "proPending": "Compra pendiente. Pro se activa tras la verificación.",
      "proCanceled": "Compra cancelada. Tu acceso no ha cambiado.",
      "proError":
          "No se pudo verificar la compra. Reintenta o restaura las compras.",
      "proNoPurchases": "No se encontró ninguna compra de Pro.",
      "proUpgradePrice": "Mejorar · {price}",
      "proRestore": "Restaurar compras",
      "proPurchaseUnavailable": "Compra no disponible",
      "proActive": "Pro está activo",
      "focusChoices": "Duraciones de enfoque",
      "focusWeights": "Probabilidades de selección",
      "focusAutoAdjust":
          "Las demás probabilidades se ajustan automáticamente. Solo se sortean las duraciones seleccionadas.",
      "focusEqualize": "Igualar",
      "focusSave": "Guardar ajustes",
      "focusAtLeastOne": "Mantén al menos una duración seleccionada.",
      "focusTotal": "Total 100 %",
      "focusError": "No se pudieron guardar los cambios. Inténtalo de nuevo.",
      "focusNameError": "Usa un nombre único de 1 a 40 caracteres.",
      "focusPresetName": "Nombre del preajuste",
      "focusNameHint": "Estudio o Trabajo",
      "focusNewPreset": "Nuevo preajuste",
      "focusApply": "Aplicar",
      "focusEdit": "Editar",
      "focusInUse": "En uso",
      "focusPresetEmpty":
          "Guarda una combinación para volver a usarla con un toque.",
      "focusPreview":
          "Vista previa · Necesitas Pro para guardar y aplicar ajustes personalizados.",
      "focusCustomSummary":
          "Las probabilidades guardadas determinan el resultado.",
      "focusProNeeded": "Explorar Pro",
      "focusPresetDelete":
          "¿Eliminar este preajuste? Tu temporizador actual no se verá afectado.",
      "focusSettingsLoadError":
          "No se pudieron cargar los ajustes guardados. Reintenta.",
      "focusInvalidSaved":
          "Algunos ajustes no eran válidos. Tus preajustes válidos siguen disponibles.",
      "focusPresetSave": "Guardar preajuste",
      "focusRetry": "Reintentar",
      "focusSingle": "Una duración seleccionada",
      "focusDiscard": "¿Descartar los cambios sin guardar?",
      "focusDiscardAction": "Descartar",

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
      'noHistoryYet': 'Aún no hay historial',
      'completeSessionToSee': 'Completa una sesión de enfoque para verla aquí.',
      'noSessionsOnThisDay': 'No hay sesiones para este día',
      'selectAnotherDate': 'Elige otra fecha para ver las sesiones.',
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
      'goBack': '¿Deseas volver?',
      'goBackConfirm': '¿Deseas salir de la página del temporizador?',
      'goBackButton': 'Volver',
      'cancel': 'Cancelar',
      'end': 'Finalizar',
      'focusCompleteTitle': 'Enfoque completado',
      'focusCompleteBody':
          'Buen trabajo. Ahora comienza tu descanso de 10 minutos.',
      'breakCompleteTitle': 'Descanso completado',
      'breakCompleteBody':
          'Tu descanso ha terminado. ¿Listo para concentrarte de nuevo?',
      'returningToWheel': 'Volviendo a la rueda',
      'goNow': 'Ir ahora',

      // Settings Page
      'preferences': 'Preferencias',
      'information': 'Información',
      'theme': 'Tema',
      'selectTheme': 'Seleccionar tema',
      'themeSystem': 'Predeterminado del sistema',
      'themeLight': 'Claro',
      'themeDark': 'Oscuro',
      'themeUpdated': 'Tema actualizado.',
      'focusProgress': 'Progreso de enfoque',
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
      'languageSystem': 'Predeterminado del sistema',
      'languageSystemDesc': 'Seguir el idioma del dispositivo',
      'appTitle': 'RandomFocus',
      'appVersion': 'Versión 1.0.0',
      'version': 'Versión',
      'appUpdated': 'RandomFocus se ha actualizado',
      'whatsNew': 'Novedades',
      'viewLatestChanges': 'Ver los cambios recientes',
      'releaseNoteTimer':
          'El temporizador ahora termina en el momento correcto.',
      'releaseNoteNotice':
          'Consulta este resumen cuando se instale una nueva versión.',
      'releaseNoteVersion':
          'La pantalla Acerca de ahora muestra la versión instalada.',
      'releaseNotePlayUpdate':
          'Recibe un recordatorio cuando haya una nueva versión en Google Play.',
      'updateAvailable': 'Actualización disponible',
      'updateAvailableMessage':
          'Hay una nueva versión de RandomFocus. Actualiza ahora para disfrutar de las últimas mejoras.',
      'updateNow': 'Actualizar ahora',
      'later': 'Más tarde',
      'appDescription':
          'Una aplicación para ayudarte a mantener el enfoque con sesiones de temporizador aleatorias.',
      'languageUpdated': 'Idioma actualizado.',
      'selectedOption': 'Seleccionada',
      'tapToSelect': 'Toca para elegir',
      'privacyPolicySheetSummary': 'Revisa el enlace de la política.',
      'privacyPolicySheetBody':
          'Revisa el enlace de la política antes de abrirlo en tu navegador.',
      'policyUrlLabel': 'URL de la política',
      'openInBrowser': 'Abrir en el navegador',
      'openWheelTab': 'Abrir pestaña de rueda',
      'openHistoryTab': 'Abrir pestaña de historial',
      'openSettingsTab': 'Abrir pestaña de configuración',
      'closeTimerPage': 'Cerrar página del temporizador',
      'resetTimer': 'Reiniciar temporizador',
      'spinWheel': 'Girar la rueda',
      'saveAppIcon': 'Guardar icono de la aplicación',
      'refreshHistory': 'Actualizar historial',

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
      'couldNotOpenUrl': 'No se pudo abrir la política de privacidad.',

      // Ads
      'adLoading': 'Cargando anuncio...',
      'adUnavailable': 'Anuncio no disponible',
    },
    'zh': {
      // Pro phase 1
      "proTitle": "RandomFocus Pro",
      "proTagline": "按自己的节奏专注",
      "proAdFree": "无广告专注",
      "proAdFreeDesc": "计时器不显示横幅或插屏广告。",
      "proCustomTimes": "时间与概率",
      "proCustomTimesDesc": "选择时长并调整各时长被抽中的概率。",
      "proPresets": "专注预设",
      "proPresetsDesc": "保存、编辑和应用常用组合。",
      "proKeepFree": "继续使用免费计时器",
      "proUnavailable": "购买功能暂未开放。免费计时器和基本记录仍可使用。",
      "proChecking": "正在检查购买记录…",
      "proPending": "购买待处理，验证后将开通 Pro。",
      "proCanceled": "购买已取消，使用权限未改变。",
      "proError": "无法验证购买，请重试或恢复购买。",
      "proNoPurchases": "未找到 Pro 购买记录。",
      "proUpgradePrice": "升级 · {price}",
      "proRestore": "恢复购买",
      "proPurchaseUnavailable": "暂时无法购买",
      "proActive": "Pro 已启用",
      "focusChoices": "专注时长",
      "focusWeights": "抽取概率",
      "focusAutoAdjust": "其他概率会自动调整，只有选中的时长会参与抽取。",
      "focusEqualize": "平均分配",
      "focusSave": "保存设置",
      "focusAtLeastOne": "请至少保留一个时长。",
      "focusTotal": "合计 100%",
      "focusError": "无法保存更改，请重试。",
      "focusNameError": "请使用 1–40 个字符的唯一名称。",
      "focusPresetName": "预设名称",
      "focusNameHint": "学习或工作",
      "focusNewPreset": "新建预设",
      "focusApply": "应用",
      "focusEdit": "编辑",
      "focusInUse": "使用中",
      "focusPresetEmpty": "保存一个组合，下次即可一键应用。",
      "focusPreview": "预览 · 保存和应用自定义设置需要 Pro。",
      "focusCustomSummary": "抽取结果由已保存的概率决定。",
      "focusProNeeded": "了解 Pro",
      "focusPresetDelete": "删除此预设？当前计时器不受影响。",
      "focusSettingsLoadError": "无法加载已保存的设置，请重试。",
      "focusInvalidSaved": "部分设置无效，有效预设仍可使用。",
      "focusPresetSave": "保存预设",
      "focusRetry": "重试",
      "focusSingle": "已选择一个时长",
      "focusDiscard": "放弃未保存的更改？",
      "focusDiscardAction": "放弃",

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
      'completeSessionToSee': '完成一次专注会话后即可在这里查看。',
      'noSessionsOnThisDay': '当天没有会话',
      'selectAnotherDate': '选择其他日期查看会话。',
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
      'goBack': '要返回吗？',
      'goBackConfirm': '要退出计时器页面吗？',
      'goBackButton': '返回',
      'cancel': '取消',
      'end': '结束',
      'focusCompleteTitle': '专注完成',
      'focusCompleteBody': '做得很好。现在开始休息 10 分钟。',
      'breakCompleteTitle': '休息结束',
      'breakCompleteBody': '休息时间结束了。准备好再次专注了吗？',
      'returningToWheel': '正在返回转盘',
      'goNow': '立即前往',

      // Settings Page
      'preferences': '偏好设置',
      'information': '信息',
      'theme': '主题',
      'selectTheme': '选择主题',
      'themeSystem': '跟随系统',
      'themeLight': '浅色',
      'themeDark': '深色',
      'themeUpdated': '主题已更新。',
      'focusProgress': '专注进度',
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
      'languageSystem': '跟随系统',
      'languageSystemDesc': '使用设备的语言',
      'appTitle': 'RandomFocus',
      'appVersion': '版本 1.0.0',
      'version': '版本',
      'appUpdated': 'RandomFocus 已更新',
      'whatsNew': '更新内容',
      'viewLatestChanges': '查看最新变化',
      'releaseNoteTimer': '计时器现在会在正确的时间结束。',
      'releaseNoteNotice': '安装新版本后可查看此更新摘要。',
      'releaseNoteVersion': '“关于”页面现在会显示已安装的应用版本。',
      'releaseNotePlayUpdate': 'Google Play 有新版本时会收到友好提醒。',
      'updateAvailable': '有可用更新',
      'updateAvailableMessage': 'RandomFocus 有新版本。立即更新以体验最新改进。',
      'updateNow': '立即更新',
      'later': '稍后',
      'appDescription': '一款通过随机计时器会话帮助您保持专注的应用。',
      'languageUpdated': '语言已更新。',
      'selectedOption': '已选择',
      'tapToSelect': '点按以选择',
      'privacyPolicySheetSummary': '查看隐私政策链接。',
      'privacyPolicySheetBody': '在浏览器中打开前，请先查看隐私政策链接。',
      'policyUrlLabel': '政策链接',
      'openInBrowser': '在浏览器中打开',
      'openWheelTab': '打开转盘标签',
      'openHistoryTab': '打开历史标签',
      'openSettingsTab': '打开设置标签',
      'closeTimerPage': '关闭计时器页面',
      'resetTimer': '重置计时器',
      'spinWheel': '旋转转盘',
      'saveAppIcon': '保存应用图标',
      'refreshHistory': '刷新历史记录',

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
      'couldNotOpenUrl': '无法打开隐私政策。',

      // Ads
      'adLoading': '广告加载中...',
      'adUnavailable': '广告不可用',
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
  String get goBack => translate('goBack');
  String get goBackConfirm => translate('goBackConfirm');
  String get goBackButton => translate('goBackButton');
  String get cancel => translate('cancel');
  String get end => translate('end');
  String get focusCompleteTitle => translate('focusCompleteTitle');
  String get focusCompleteBody => translate('focusCompleteBody');
  String get breakCompleteTitle => translate('breakCompleteTitle');
  String get breakCompleteBody => translate('breakCompleteBody');
  String get returningToWheel => translate('returningToWheel');
  String get goNow => translate('goNow');
  String get notifications => translate('notifications');
  String get manageAlerts => translate('manageAlerts');
  String get preferences => translate('preferences');
  String get information => translate('information');
  String get theme => translate('theme');
  String get selectTheme => translate('selectTheme');
  String get themeUpdated => translate('themeUpdated');
  String get language => translate('language');
  String get about => translate('about');
  String get appInformation => translate('appInformation');
  String get help => translate('help');
  String get howToUse => translate('howToUse');
  String get howToUseContent => translate('howToUseContent');
  String get gotIt => translate('gotIt');
  String get close => translate('close');
  String get selectLanguage => translate('selectLanguage');
  String get languageSystem => translate('languageSystem');
  String get languageSystemDesc => translate('languageSystemDesc');
  String get appTitle => translate('appTitle');
  String get appVersion => translate('appVersion');
  String get appDescription => translate('appDescription');
  String get languageUpdated => translate('languageUpdated');
  String get selectedOption => translate('selectedOption');
  String get tapToSelect => translate('tapToSelect');
  String get privacyPolicySheetSummary =>
      translate('privacyPolicySheetSummary');
  String get privacyPolicySheetBody => translate('privacyPolicySheetBody');
  String get policyUrlLabel => translate('policyUrlLabel');
  String get openInBrowser => translate('openInBrowser');
  String get openWheelTab => translate('openWheelTab');
  String get openHistoryTab => translate('openHistoryTab');
  String get openSettingsTab => translate('openSettingsTab');
  String get closeTimerPage => translate('closeTimerPage');
  String get resetTimer => translate('resetTimer');
  String get spinWheel => translate('spinWheel');
  String get saveAppIcon => translate('saveAppIcon');
  String get refreshHistory => translate('refreshHistory');
  String get delete => translate('delete');
  String get deleteHistory => translate('deleteHistory');
  String get deleteConfirm => translate('deleteConfirm');
  String deleteSelectedConfirm(int count) =>
      translateWithParams('deleteSelectedConfirm', {'count': count.toString()});
  String get refresh => translate('refresh');
  String get privacyPolicy => translate('privacyPolicy');
  String get viewPrivacyPolicy => translate('viewPrivacyPolicy');
  String get couldNotOpenUrl => translate('couldNotOpenUrl');
  String get adLoading => translate('adLoading');
  String get adUnavailable => translate('adUnavailable');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // 지원 목록은 AppLanguage 한 곳에만 둔다 — 여기에 코드를 또 적으면
    // 언어를 추가할 때 한쪽만 고쳐 번역이 통째로 빠진다.
    return AppLanguage.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
