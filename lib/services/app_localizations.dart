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
      // 7-day focus challenge
      "focusChallengeTitle": "Collect 7 focus days",
      "focusChallengeBadgeTitle": "7-day focus badge",
      "focusChallengeProgress": "{done} / {total} days",
      "focusChallengeProgressSemantics":
          "{done} of {total} focus days collected",
      "focusChallengeTodayCounted": "Today counts. Come back tomorrow.",
      "focusChallengeTodayPending":
          "Finish a focus session to count today. Days do not have to be in a row.",
      "focusChallengeBadgeEarned": "Earned. All 7 days collected.",
      "focusChallengeLoadError": "Could not load your challenge progress.",
      "releaseNoteFocusChallenge":
          "Collect 7 focus days, on any days you like, to earn the focus badge.",
      "ddayRecoveryNeeded": "Saved goal is damaged. Tap to reset.",
      "ddayRecoveryTitle": "Reset saved goal?",
      "ddayRecoveryMessage":
          "Back up the unreadable goal and clear it so you can create a new one. Your timer and history stay unchanged.",
      "ddayRecoveryAction": "Reset goal",
      "ddayRecoveryError": "Could not reset your goal. Please try again.",
      "releaseNoteDDay":
          "Set a D-Day goal in Settings and edit it from your focus screen.",
      // D-Day goal
      "ddayTitle": "D-Day goal",
      "ddayEditorHint": "Choose a goal and date to focus toward.",
      "ddayName": "Goal name",
      "ddayNameHint": "Exam or project deadline",
      "ddayNameError": "Enter a goal name with 1–40 characters.",
      "ddayDate": "Target date",
      "ddayDisplayHint": "Your goal appears on the focus screen.",
      "ddaySave": "Save goal",
      "ddaySaving": "Saving…",
      "ddaySaveError": "Could not save your goal. Please try again.",
      "ddayDeleteTitle": "Delete goal",
      "ddayDeleteMessage":
          "Remove this goal from Settings and the focus screen? Your timer and history will stay as they are.",
      "ddayEdit": "Edit D-Day goal",
      "ddayEmpty": "Set a goal name and target date",
      "ddayLoading": "Loading goal…",
      "ddayLoadError": "Could not load your goal. Tap to retry.",

      // Pro phase 1
      "proTitle": "RandomFocus Pro",
      "proTagline": "Focus your way",
      "proOneTime": "One-time purchase · No subscription",
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
      "proUpgradePrice": "Unlock Pro · {price}",
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
      // 7-day focus challenge
      "focusChallengeTitle": "Reúne 7 días de concentración",
      "focusChallengeBadgeTitle": "Insignia de 7 días",
      "focusChallengeProgress": "{done} / {total} días",
      "focusChallengeProgressSemantics":
          "{done} de {total} días de concentración reunidos",
      "focusChallengeTodayCounted": "Hoy ya cuenta. Vuelve mañana.",
      "focusChallengeTodayPending":
          "Completa una sesión para contar hoy. Los días no tienen que ser seguidos.",
      "focusChallengeBadgeEarned": "Conseguida. Reuniste los 7 días.",
      "focusChallengeLoadError": "No se pudo cargar tu progreso del reto.",
      "releaseNoteFocusChallenge":
          "Reúne 7 días de concentración, los días que quieras, para ganar la insignia.",
      "ddayRecoveryNeeded":
          "La meta guardada está dañada. Toca para restablecerla.",
      "ddayRecoveryTitle": "¿Restablecer la meta?",
      "ddayRecoveryMessage":
          "Se hará una copia de la meta ilegible y se borrará para crear otra. El temporizador y el historial se conservarán.",
      "ddayRecoveryAction": "Restablecer meta",
      "ddayRecoveryError":
          "No se pudo restablecer la meta. Inténtalo de nuevo.",
      "releaseNoteDDay":
          "Define una meta D-Day en Ajustes y edítala desde la pantalla de concentración.",
      // D-Day goal
      "ddayTitle": "Meta D-Day",
      "ddayEditorHint": "Elige una meta y una fecha para concentrarte.",
      "ddayName": "Nombre de la meta",
      "ddayNameHint": "Examen o entrega de un proyecto",
      "ddayNameError": "Escribe un nombre de entre 1 y 40 caracteres.",
      "ddayDate": "Fecha objetivo",
      "ddayDisplayHint": "Tu meta aparece en la pantalla de concentración.",
      "ddaySave": "Guardar meta",
      "ddaySaving": "Guardando…",
      "ddaySaveError": "No se pudo guardar la meta. Inténtalo de nuevo.",
      "ddayDeleteTitle": "Eliminar meta",
      "ddayDeleteMessage":
          "¿Eliminar esta meta de Ajustes y la pantalla de concentración? El temporizador y el historial se conservarán.",
      "ddayEdit": "Editar meta D-Day",
      "ddayEmpty": "Define el nombre y la fecha de tu meta",
      "ddayLoading": "Cargando meta…",
      "ddayLoadError": "No se pudo cargar la meta. Toca para reintentar.",

      // Pro phase 1
      "proTitle": "RandomFocus Pro",
      "proTagline": "Concéntrate a tu manera",
      "proOneTime": "Pago único · Sin suscripción",
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
      // 7-day focus challenge
      "focusChallengeTitle": "集齐 7 个专注日",
      "focusChallengeBadgeTitle": "7 日专注徽章",
      "focusChallengeProgress": "{done} / {total} 天",
      "focusChallengeProgressSemantics": "已集齐 {total} 天中的 {done} 天",
      "focusChallengeTodayCounted": "今天已计入，明天再来。",
      "focusChallengeTodayPending": "完成一次专注即可计入今天，无需连续。",
      "focusChallengeBadgeEarned": "已达成，集齐 7 天。",
      "focusChallengeLoadError": "无法加载挑战进度。",
      "releaseNoteFocusChallenge": "集齐 7 个专注日（无需连续）即可获得专注徽章。",
      "ddayRecoveryNeeded": "保存的目标已损坏，点按重置。",
      "ddayRecoveryTitle": "重置已保存的目标？",
      "ddayRecoveryMessage": "备份无法读取的目标并清除它，以便重新创建。计时器和历史记录将保留。",
      "ddayRecoveryAction": "重置目标",
      "ddayRecoveryError": "无法重置目标，请重试。",
      "releaseNoteDDay": "在设置中添加 D-Day 目标，并在专注页面中查看和编辑。",
      // D-Day goal
      "ddayTitle": "D-Day 目标",
      "ddayEditorHint": "设置目标和日期，专注于你的计划。",
      "ddayName": "目标名称",
      "ddayNameHint": "考试或项目截止日期",
      "ddayNameError": "请输入 1–40 个字符的目标名称。",
      "ddayDate": "目标日期",
      "ddayDisplayHint": "目标将显示在专注页面。",
      "ddaySave": "保存目标",
      "ddaySaving": "正在保存…",
      "ddaySaveError": "无法保存目标，请重试。",
      "ddayDeleteTitle": "删除目标",
      "ddayDeleteMessage": "要从设置和专注页面移除此目标吗？计时器和历史记录将保留。",
      "ddayEdit": "编辑 D-Day 目标",
      "ddayEmpty": "设置目标名称和日期",
      "ddayLoading": "正在加载目标…",
      "ddayLoadError": "无法加载目标，点按重试。",

      // Pro phase 1
      "proTitle": "RandomFocus Pro",
      "proTagline": "按自己的节奏专注",
      "proOneTime": "一次购买 · 无需订阅",
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
    'ko': {
      // 7-day focus challenge
      "focusChallengeTitle": "집중한 날 7일 모으기",
      "focusChallengeBadgeTitle": "7일 집중 배지",
      "focusChallengeProgress": "{done} / {total}일",
      "focusChallengeProgressSemantics": "집중한 날 {total}일 중 {done}일 모았습니다",
      "focusChallengeTodayCounted": "오늘은 기록됐습니다. 내일 다시 오세요.",
      "focusChallengeTodayPending":
          "집중 세션을 마치면 오늘이 기록됩니다. 연속이 아니어도 됩니다.",
      "focusChallengeBadgeEarned": "달성했습니다. 7일을 모두 모았습니다.",
      "focusChallengeLoadError": "챌린지 진행 상황을 불러오지 못했습니다.",
      "releaseNoteFocusChallenge":
          "원하는 날에 집중한 날 7일을 모으면 집중 배지를 받습니다.",
      "ddayRecoveryNeeded": "저장된 목표가 손상됐습니다. 눌러서 초기화하세요.",
      "ddayRecoveryTitle": "저장된 목표를 초기화할까요?",
      "ddayRecoveryMessage":
          "읽을 수 없는 목표를 백업하고 지워서 새로 만들 수 있게 합니다. 타이머와 기록은 그대로 유지됩니다.",
      "ddayRecoveryAction": "목표 초기화",
      "ddayRecoveryError": "목표를 초기화하지 못했습니다. 다시 시도해 주세요.",
      "releaseNoteDDay": "설정에서 D-Day 목표를 정하고 집중 화면에서 수정할 수 있습니다.",
      // D-Day goal
      "ddayTitle": "D-Day 목표",
      "ddayEditorHint": "집중할 목표와 날짜를 정하세요.",
      "ddayName": "목표 이름",
      "ddayNameHint": "시험 또는 프로젝트 마감",
      "ddayNameError": "목표 이름을 1~40자로 입력하세요.",
      "ddayDate": "목표 날짜",
      "ddayDisplayHint": "목표가 집중 화면에 표시됩니다.",
      "ddaySave": "목표 저장",
      "ddaySaving": "저장 중…",
      "ddaySaveError": "목표를 저장하지 못했습니다. 다시 시도해 주세요.",
      "ddayDeleteTitle": "목표 삭제",
      "ddayDeleteMessage":
          "설정과 집중 화면에서 이 목표를 지울까요? 타이머와 기록은 그대로 유지됩니다.",
      "ddayEdit": "D-Day 목표 수정",
      "ddayEmpty": "목표 이름과 날짜를 정하세요",
      "ddayLoading": "목표 불러오는 중…",
      "ddayLoadError": "목표를 불러오지 못했습니다. 눌러서 다시 시도하세요.",

      // Pro phase 1
      "proTitle": "RandomFocus Pro",
      "proTagline": "내 방식대로 집중하기",
      "proOneTime": "1회 구매 · 구독 아님",
      "proAdFree": "광고 없는 집중",
      "proAdFreeDesc": "타이머에 배너와 전면 광고가 표시되지 않습니다.",
      "proCustomTimes": "시간과 확률",
      "proCustomTimesDesc": "원하는 시간을 고르고 각 시간이 얼마나 자주 나올지 조절합니다.",
      "proPresets": "집중 프리셋",
      "proPresetsDesc": "자주 쓰는 조합을 저장하고 수정해 바로 적용합니다.",
      "proKeepFree": "무료 타이머로 계속하기",
      "proUnavailable":
          "아직 구매할 수 없습니다. 무료 타이머와 기본 기록은 계속 쓸 수 있습니다.",
      "proChecking": "구매 내역 확인 중…",
      "proPending": "구매 처리 중입니다. 확인이 끝나면 Pro가 열립니다.",
      "proCanceled": "구매를 취소했습니다. 이용 범위는 그대로입니다.",
      "proError": "구매를 확인하지 못했습니다. 다시 시도하거나 구매를 복원하세요.",
      "proNoPurchases": "Pro 구매 내역이 없습니다.",
      "proUpgradePrice": "Pro 잠금 해제 · {price}",
      "proRestore": "구매 복원",
      "proPurchaseUnavailable": "구매할 수 없음",
      "proActive": "Pro 사용 중",
      "focusChoices": "집중 시간",
      "focusWeights": "선택 확률",
      "focusAutoAdjust": "다른 확률이 자동으로 조정됩니다. 선택한 시간만 뽑힙니다.",
      "focusEqualize": "균등하게",
      "focusSave": "설정 저장",
      "focusAtLeastOne": "시간을 최소 하나는 선택해 두세요.",
      "focusTotal": "합계 100%",
      "focusError": "변경 내용을 저장하지 못했습니다. 다시 시도해 주세요.",
      "focusNameError": "1~40자의 겹치지 않는 이름을 쓰세요.",
      "focusPresetName": "프리셋 이름",
      "focusNameHint": "공부 또는 업무",
      "focusNewPreset": "새 프리셋",
      "focusApply": "적용",
      "focusEdit": "수정",
      "focusInUse": "사용 중",
      "focusPresetEmpty": "조합을 저장하면 한 번 눌러 다시 쓸 수 있습니다.",
      "focusPreview": "미리보기 · 직접 설정을 저장하고 적용하려면 Pro가 필요합니다.",
      "focusCustomSummary": "저장한 확률로 결과가 정해집니다.",
      "focusProNeeded": "Pro 살펴보기",
      "focusPresetDelete": "이 프리셋을 삭제할까요? 지금 타이머는 영향받지 않습니다.",
      "focusSettingsLoadError": "저장된 설정을 불러오지 못했습니다. 다시 시도하세요.",
      "focusInvalidSaved":
          "일부 저장된 설정이 올바르지 않았습니다. 정상인 프리셋은 그대로 쓸 수 있습니다.",
      "focusPresetSave": "프리셋 저장",
      "focusRetry": "다시 시도",
      "focusSingle": "선택한 시간 1개",
      "focusDiscard": "저장하지 않은 변경을 버릴까요?",
      "focusDiscardAction": "버리기",

      // Navigation
      'wheel': '룰렛',
      'history': '기록',
      'settings': '설정',

      // Roulette Page
      'spin': '돌리기',
      'spinsLeft': '오늘 남은 횟수',
      'noSpinsLeft': '오늘 남은 횟수가 없습니다',
      'comeBackTomorrow': '내일 다시 오세요!',
      'selectedTime': '선택된 시간',
      'startFocus': '집중 시작',
      'seconds': '초',

      // History Page
      'noHistoryYet': '아직 기록이 없습니다',
      'completeSessionToSee': '집중 세션을 마치면 여기에 표시됩니다.',
      'noSessionsOnThisDay': '이 날의 세션이 없습니다',
      'selectAnotherDate': '다른 날짜를 골라 세션을 확인하세요.',
      'sessions': '세션',
      'monthlySessions': '이번 달',
      'dailySessions': '오늘',
      'monthlyFocused': '이번 달 집중',
      'dailyFocused': '오늘 집중',
      'focused': '집중',
      'minutes': '분',
      'completed': '완료',
      'stopped': '중단',
      'actual': '실제',

      // Timer Page
      'focus': '집중',
      'break': '휴식',
      'ready': '준비',
      'running': '진행 중…',
      'paused': '일시정지',
      'start': '시작',
      'stop': '정지',
      'endFocusSession': '집중 세션 종료',
      'endSessionConfirm': '이 세션을 끝낼까요?',
      'goBack': '뒤로 갈까요?',
      'goBackConfirm': '타이머 화면을 닫을까요?',
      'goBackButton': '뒤로',
      'cancel': '취소',
      'end': '종료',
      'focusCompleteTitle': '집중 완료',
      'focusCompleteBody': '수고하셨습니다. 10분 휴식을 시작합니다.',
      'breakCompleteTitle': '휴식 완료',
      'breakCompleteBody': '휴식이 끝났습니다. 다시 집중할까요?',
      'returningToWheel': '룰렛으로 돌아갑니다',
      'goNow': '지금 이동',

      // Settings Page
      'preferences': '환경설정',
      'information': '정보',
      'theme': '테마',
      'selectTheme': '테마 선택',
      'themeSystem': '기기 설정 따르기',
      'themeLight': '밝게',
      'themeDark': '어둡게',
      'themeUpdated': '테마를 변경했습니다.',
      'focusProgress': '집중 진행 상황',
      'notifications': '알림',
      'manageAlerts': '알림 관리',
      'language': '언어',
      'about': '앱 정보',
      'appInformation': '앱 정보',
      'help': '도움말',
      'howToUse': '사용 방법',
      'howToUseContent':
          '1. 룰렛을 돌려 공부 시간을 고릅니다\n'
          '2. 집중 세션을 마칩니다\n'
          '3. 휴식합니다\n'
          '4. 반복하며 동기를 유지합니다!\n\n'
          '하루 2회 돌릴 수 있습니다.',
      'gotIt': '확인',
      'close': '닫기',
      'selectLanguage': '언어 선택',
      'languageSystem': '기기 설정 따르기',
      'languageSystemDesc': '기기 언어를 따릅니다',
      'appTitle': 'RandomFocus',
      'appVersion': '버전 1.0.0',
      'version': '버전',
      'appUpdated': 'RandomFocus를 업데이트했습니다',
      'whatsNew': '새로운 기능',
      'viewLatestChanges': '최근 변경 사항 보기',
      'releaseNoteTimer': '타이머가 정확한 시간에 끝납니다.',
      'releaseNoteNotice': '새 버전을 설치하면 이 업데이트 요약을 보여줍니다.',
      'releaseNoteVersion': '앱 정보 화면에서 설치된 버전을 확인할 수 있습니다.',
      'releaseNotePlayUpdate': 'Google Play에 새 버전이 올라오면 알려줍니다.',
      'updateAvailable': '업데이트 있음',
      'updateAvailableMessage':
          'RandomFocus 새 버전이 준비됐습니다. 지금 업데이트해 최신 개선 사항을 사용하세요.',
      'updateNow': '지금 업데이트',
      'later': '나중에',
      'appDescription': '무작위 타이머 세션으로 집중을 이어가게 돕는 앱입니다.',
      'languageUpdated': '언어를 변경했습니다.',
      'selectedOption': '선택됨',
      'tapToSelect': '눌러서 선택',
      'privacyPolicySheetSummary': '정책 링크를 확인하세요.',
      'privacyPolicySheetBody': '브라우저에서 열기 전에 정책 링크를 확인하세요.',
      'policyUrlLabel': '정책 URL',
      'openInBrowser': '브라우저에서 열기',
      'openWheelTab': '룰렛 탭 열기',
      'openHistoryTab': '기록 탭 열기',
      'openSettingsTab': '설정 탭 열기',
      'closeTimerPage': '타이머 화면 닫기',
      'resetTimer': '타이머 초기화',
      'spinWheel': '룰렛 돌리기',
      'saveAppIcon': '앱 아이콘 저장',
      'refreshHistory': '기록 새로고침',

      // Common
      'delete': '삭제',
      'deleteHistory': '기록 삭제',
      'deleteConfirm': '이 항목을 삭제할까요?',
      'deleteSelectedConfirm': '{count}개 항목을 삭제할까요?',
      'refresh': '새로고침',
      'result': '결과',
      'oneMoreChance': '한 번 더 돌릴 수 있습니다!',
      'lastAttempt': '마지막 기회입니다!',
      'startingTimer': '타이머를 시작합니다…',
      'spinAgain': '다시 돌리기',
      'startTimer': '시작',
      'continue': '계속',
      'spinToChoose': '룰렛을 돌려 집중 시간을 고르세요',
      'loading': '불러오는 중…',
      'attemptsToday': '오늘 횟수',
      'focusWithRandomTimer': '무작위 타이머로 집중',
      'privacyPolicy': '개인정보 처리방침',
      'viewPrivacyPolicy': '개인정보 처리방침 보기',
      'couldNotOpenUrl': '개인정보 처리방침을 열지 못했습니다.',

      // Ads
      'adLoading': '광고 불러오는 중…',
      'adUnavailable': '광고를 불러올 수 없음',
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
