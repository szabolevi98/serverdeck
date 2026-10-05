// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ServerDeck';

  @override
  String get ok => 'Aceptar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get rename => 'Renombrar';

  @override
  String get paste => 'Pegar';

  @override
  String get fieldRequired => 'Obligatorio';

  @override
  String get serversTitle => 'Servidores';

  @override
  String get serversEmptyTitle => 'Aún no hay servidores';

  @override
  String get serversEmpty =>
      'Añade un servidor con su dirección y tu nombre de usuario. ServerDeck se conecta por SSH; no hace falta instalar nada en el servidor.';

  @override
  String get serverAdd => 'Añadir servidor';

  @override
  String get serverEditTitle => 'Editar servidor';

  @override
  String serverDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get serverDeleteMessage =>
      'También se eliminan su contraseña guardada, sus comandos y sus fuentes de registros. Las claves se conservan.';

  @override
  String get serverSectionConnection => 'Conexión';

  @override
  String get serverSectionAuth => 'Inicio de sesión';

  @override
  String get serverHost => 'Dirección';

  @override
  String get serverUser => 'Usuario';

  @override
  String get serverPort => 'Puerto';

  @override
  String get serverPortInvalid => '1–65535';

  @override
  String get serverName => 'Nombre';

  @override
  String get serverNameHint => 'La dirección, si se deja vacío';

  @override
  String get statusChecking => '…';

  @override
  String get statusDown => 'sin conexión';

  @override
  String get authKey => 'Clave';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authKeyPick => 'Clave SSH';

  @override
  String get authKeyMissing => 'Elige una clave';

  @override
  String get authKeyNone =>
      'Aún no hay claves. Genera una y pon su parte pública en ~/.ssh/authorized_keys en el servidor.';

  @override
  String get authPasswordKept => 'Guardada. Déjalo vacío para conservarla.';

  @override
  String get keysTitle => 'Claves SSH';

  @override
  String get keysEmptyTitle => 'Aún no hay claves';

  @override
  String get keysEmpty =>
      'Genera una nueva clave Ed25519 o importa una que ya tengas. La clave privada se queda en el almacenamiento cifrado del teléfono.';

  @override
  String get keyAdd => 'Añadir clave';

  @override
  String get keyGenerateNew => 'Generar una clave nueva';

  @override
  String get keyGenerateHint => 'Ed25519, creada aquí en el teléfono';

  @override
  String get keyGenerated => 'Clave lista. Copia su parte pública al servidor.';

  @override
  String get keyImport => 'Importar una clave';

  @override
  String get keyImportHint => 'Clave privada OpenSSH, RSA o ECDSA';

  @override
  String get keyImportNote =>
      'Una clave protegida con frase de contraseña se desbloquea una vez y se guarda en el almacenamiento cifrado del teléfono. La frase de contraseña no se guarda.';

  @override
  String get keyImportedName => 'Clave importada';

  @override
  String get keyName => 'Nombre';

  @override
  String get keyPrivate => 'Clave privada';

  @override
  String get keyPassphrase => 'Frase de contraseña de la clave';

  @override
  String get keyCopy => 'Copiar la clave pública';

  @override
  String get keyCopied => 'Clave pública copiada';

  @override
  String keyDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get keyDeleteMessage =>
      'La clave privada se elimina del teléfono para siempre.';

  @override
  String keyDeleteUsed(String servers) {
    return 'La clave privada se elimina del teléfono para siempre. Estos servidores la usan y necesitarán otra clave: $servers';
  }

  @override
  String get keyErrorNotAKey =>
      'Esto no es una clave privada. Pega todo el texto que empieza por -----BEGIN.';

  @override
  String get keyErrorNeedsPassphrase =>
      'Esta clave está protegida. Introduce su frase de contraseña.';

  @override
  String get keyErrorWrongPassphrase => 'Frase de contraseña incorrecta.';

  @override
  String get keyErrorUnsupported =>
      'ServerDeck no conoce este tipo de clave. Usa una clave Ed25519, RSA o ECDSA.';

  @override
  String get sessionOnline => 'en línea';

  @override
  String get sessionConnecting => 'conectando';

  @override
  String get sessionReconnect => 'Reconectar';

  @override
  String get sessionConnectingTo => 'Conectando…';

  @override
  String get problemUnreachableTitle => 'Servidor inaccesible';

  @override
  String problemUnreachable(String host, int port) {
    return 'No se pudo abrir una conexión con $host en el puerto $port. Revisa la dirección, el puerto y la conexión del teléfono.';
  }

  @override
  String get problemTimeoutTitle => 'Sin respuesta a tiempo';

  @override
  String get problemTimeout =>
      'El servidor no respondió en 12 segundos. Puede estar sobrecargado, o un cortafuegos está descartando la conexión.';

  @override
  String get problemAuthTitle => 'Error de inicio de sesión';

  @override
  String problemAuthKey(String user) {
    return 'El servidor no aceptó la clave de $user. Pon la parte pública de la clave en ~/.ssh/authorized_keys en el servidor.';
  }

  @override
  String problemAuthPassword(String user) {
    return 'El servidor no aceptó la contraseña de $user.';
  }

  @override
  String get problemHostKeyChangedTitle => 'La clave del servidor ha cambiado';

  @override
  String get problemHostKeyChanged =>
      'El servidor mostró una clave de identidad distinta de la que aceptaste antes. Puede ser una reinstalación o alguien en medio. ServerDeck no se ha conectado.';

  @override
  String get problemHostKeyRefusedTitle => 'Clave rechazada';

  @override
  String get problemHostKeyRefused =>
      'No aceptaste la clave del servidor, así que ServerDeck no inició sesión.';

  @override
  String get problemMissingTitle => 'Sin datos de inicio de sesión';

  @override
  String get problemMissing =>
      'Este servidor no tiene clave ni contraseña. Edita el servidor y añade una.';

  @override
  String get problemDisconnectedTitle => 'Conexión perdida';

  @override
  String get problemDisconnected =>
      'La conexión se cortó: un cambio de red, un reinicio del servidor o el teléfono entró en reposo.';

  @override
  String get problemOtherTitle => 'No se pudo conectar';

  @override
  String get hostKeyNewTitle => 'Servidor nuevo';

  @override
  String hostKeyNew(String host) {
    return 'Es la primera vez que te conectas a $host. Esta es la clave de identidad del servidor:';
  }

  @override
  String get hostKeyCheck =>
      'Para estar seguro, este comando en el servidor muestra la misma huella:';

  @override
  String get hostKeyAccept => 'Aceptar';

  @override
  String get hostKeyReject => 'Rechazar';

  @override
  String get hostKeyKnown => 'Aceptada';

  @override
  String get hostKeyNow => 'Ahora';

  @override
  String get hostKeyForget => 'Olvidar la clave antigua';

  @override
  String get hostKeyForgetTitle => '¿Olvidar la clave antigua?';

  @override
  String get hostKeyForgetMessage =>
      'Hazlo solo si sabes por qué cambió la clave, por ejemplo porque reinstalaste el servidor. ServerDeck preguntará entonces por la clave nueva.';

  @override
  String get statsFailedTitle => 'No se pudo leer el servidor';

  @override
  String get statsFailed =>
      'La respuesta del servidor no tenía sentido. Las estadísticas necesitan Linux (/proc).';

  @override
  String get statsStale =>
      'La última actualización falló. Las cifras de arriba son anteriores.';

  @override
  String get statCpu => 'CPU';

  @override
  String get statMemory => 'Memoria';

  @override
  String get statDisk => 'Disco';

  @override
  String statCores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count núcleos',
      one: '1 núcleo',
    );
    return '$_temp0';
  }

  @override
  String get statHistory => 'Últimos 3 minutos';

  @override
  String get statHistoryHint =>
      'Se actualiza cada 3 segundos mientras esta pantalla está abierta.';

  @override
  String get statNetIn => 'Entrada';

  @override
  String get statNetOut => 'Salida';

  @override
  String get statLoad => 'Carga';

  @override
  String get statLoad1 => '1 min';

  @override
  String get statLoad5 => '5 min';

  @override
  String get statLoad15 => '15 min';

  @override
  String get statDisks => 'Discos';

  @override
  String get statSwap => 'Swap';

  @override
  String get statUptime => 'Activo';

  @override
  String uptimeDays(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0, $hours h';
  }

  @override
  String uptimeHours(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get tabOverview => 'Resumen';

  @override
  String get tabServices => 'Servicios';

  @override
  String get servicesFailedTitle => 'No se pudieron listar los servicios';

  @override
  String get servicesSearch => 'Buscar por nombre o descripción';

  @override
  String servicesRunning(int count) {
    return 'En ejecución · $count';
  }

  @override
  String servicesFailed(int count) {
    return 'Con error · $count';
  }

  @override
  String servicesAll(int count) {
    return 'Todos · $count';
  }

  @override
  String get servicesNone => 'No hay coincidencias.';

  @override
  String get servicesNoneFailed => 'No hay servicios con error.';

  @override
  String get containersNone => 'No hay contenedores.';

  @override
  String get stateRunning => 'en ejecución';

  @override
  String get stateExited => 'finalizado';

  @override
  String get stateFailed => 'con error';

  @override
  String get stateActivating => 'iniciando';

  @override
  String get stateInactive => 'detenido';

  @override
  String get stateUnhealthy => 'no saludable';

  @override
  String get statePaused => 'en pausa';

  @override
  String get stateRestarting => 'reiniciando';

  @override
  String get stateExitedContainer => 'finalizado';

  @override
  String get stateCreated => 'creado';

  @override
  String get actionRestart => 'Reiniciar';

  @override
  String get actionReload => 'Recargar';

  @override
  String get actionStop => 'Detener';

  @override
  String get actionStart => 'Iniciar';

  @override
  String actionConfirmTitle(String action, String subject) {
    return '¿$action $subject?';
  }

  @override
  String actionConfirmMessage(String command) {
    return 'Esto se ejecuta en el servidor:\n$command';
  }

  @override
  String actionDone(String action, String subject) {
    return '$action: hecho en $subject';
  }

  @override
  String actionFailed(int code, String reason) {
    return 'No funcionó (código de salida $code). $reason';
  }

  @override
  String get actionNeedsSudo =>
      'Esto necesita permisos de administrador. Inicia sesión como root o permite sudo sin contraseña para este comando.';

  @override
  String get tabLogs => 'Registros';

  @override
  String get logsJournal => 'Diario del sistema';

  @override
  String get logsAdd => 'Fuente';

  @override
  String get logsAddTitle => 'Nueva fuente de registros';

  @override
  String get logsKindUnit => 'Servicio';

  @override
  String get logsKindFile => 'Archivo';

  @override
  String get logsUnitLabel => 'Nombre del servicio';

  @override
  String get logsFileLabel => 'Ruta del archivo';

  @override
  String get logsFilter => 'Filtro';

  @override
  String get logsErrorsOnly => 'Solo errores';

  @override
  String get logsPause => 'Pausar';

  @override
  String get logsResume => 'Reanudar';

  @override
  String get logsClear => 'Limpiar la pantalla';

  @override
  String logsNewLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count líneas nuevas',
      one: '1 línea nueva',
    );
    return '$_temp0';
  }

  @override
  String logsEnded(int code) {
    return 'El seguimiento del registro se detuvo (código de salida $code).';
  }

  @override
  String logsDeleteTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get logsDeleteMessage =>
      'Solo se elimina la fuente guardada, no el registro del servidor.';

  @override
  String get tabCommands => 'Comandos';

  @override
  String get commandAdd => 'Nuevo comando';

  @override
  String get commandEdit => 'Editar comando';

  @override
  String get commandQuick => 'Comando puntual…';

  @override
  String get commandRun => 'Ejecutar';

  @override
  String commandRunTitle(String name) {
    return '¿Ejecutar $name?';
  }

  @override
  String get commandSaved => 'Comandos guardados';

  @override
  String get commandTemplates => 'Para empezar';

  @override
  String get commandTemplatesHint =>
      'Toca uno para añadirlo a tus comandos guardados. Solo leen.';

  @override
  String get commandLabel => 'Comando';

  @override
  String get commandEverywhere => 'En todos los servidores';

  @override
  String get commandEverywhereHint => 'Aparece en todos tus servidores';

  @override
  String get commandConfirm => 'Preguntar antes de ejecutar';

  @override
  String get commandCopy => 'Copiar la salida';

  @override
  String get commandCopied => 'Salida copiada';

  @override
  String get commandError => 'error';

  @override
  String get commandStopped => 'detenido';

  @override
  String commandExit(int code) {
    return 'salida $code';
  }

  @override
  String get commandRunning => 'en ejecución';

  @override
  String get commandNoOutput => 'Sin salida.';

  @override
  String get tplDisk => 'Uso del disco';

  @override
  String get tplFolders => 'Carpetas más grandes';

  @override
  String get tplUpdates => 'Actualizaciones pendientes';

  @override
  String get tplWho => 'Quién ha iniciado sesión';

  @override
  String get tplApache => 'Prueba de configuración de Apache';

  @override
  String get tplNginx => 'Prueba de configuración de Nginx';

  @override
  String get tplTop => 'Mayor uso de CPU';

  @override
  String get tplPorts => 'Puertos a la escucha';

  @override
  String get tabTerminal => 'Terminal';

  @override
  String get terminalClosed => '[shell cerrada]';

  @override
  String get terminalReopen => 'Nueva shell';

  @override
  String get lockReason => 'Desbloquear ServerDeck';

  @override
  String get lockTitle => 'ServerDeck está bloqueado';

  @override
  String get lockUnlock => 'Desbloquear';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsSecurity => 'Seguridad';

  @override
  String get settingsLock => 'Bloqueo de la app';

  @override
  String get settingsLockHint =>
      'Huella, rostro o el PIN del teléfono al iniciar y tras un minuto en segundo plano.';

  @override
  String get settingsLockUnsupported =>
      'Primero configura un bloqueo de pantalla en el teléfono.';

  @override
  String get settingsKnownHosts => 'Claves de servidor conocidas';

  @override
  String get settingsKnownHostsEmpty =>
      'Aún no se ha aceptado ninguna clave de servidor.';

  @override
  String get settingsKnownHostsHint =>
      'Claves de identidad aceptadas en el primer contacto. Si la clave de un servidor cambia, ServerDeck no se conectará hasta que olvides aquí la antigua.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutText =>
      'Gestor de servidores SSH. Código abierto, licencia AGPL-3.0. No recopila nada; todo se queda en el teléfono.';

  @override
  String get installKey => 'Instalar la clave con una contraseña';

  @override
  String get installKeyAction => 'Instalar';

  @override
  String installKeyHint(String user) {
    return 'ServerDeck inicia sesión una vez con la contraseña de $user y añade la parte pública de la clave a ~/.ssh/authorized_keys. La contraseña no se guarda.';
  }

  @override
  String get installKeyDone =>
      'La clave está en el servidor. Conectando con ella…';

  @override
  String get sessionError => 'error';

  @override
  String get themeTitle => 'Apariencia';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Idioma del teléfono';

  @override
  String monitorDownTitle(String name) {
    return '$name está caído';
  }

  @override
  String monitorUpTitle(String name) {
    return '$name vuelve a funcionar';
  }

  @override
  String get monitorUpBody => 'La comprobación vuelve a funcionar.';

  @override
  String monitorUpBodyFor(String duration) {
    return 'Estuvo caído durante $duration.';
  }

  @override
  String monitorHostKeyTitle(String name) {
    return '$name: la clave del servidor ha cambiado';
  }

  @override
  String get monitorHostKeyBody =>
      'ServerDeck no inició sesión. Revisa el servidor antes de aceptar la clave nueva.';

  @override
  String get monitorProblemUnreachable => 'No se pudo abrir una conexión.';

  @override
  String get monitorProblemTimeout => 'Sin respuesta a tiempo.';

  @override
  String get monitorProblemAuth =>
      'Responde, pero no aceptó el inicio de sesión.';

  @override
  String get monitorProblemDisconnected => 'Cortó antes del inicio de sesión.';

  @override
  String get monitorProblemHostKeyChanged => 'Su clave ha cambiado.';

  @override
  String get monitorProblemHostKeyUnknown =>
      'Su clave aún no está aceptada: ábrelo una vez en la app.';

  @override
  String get monitorProblemMissing => 'No tiene clave ni contraseña.';

  @override
  String get monitorProblemOther => 'La comprobación falló.';

  @override
  String durationSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n segundos',
      one: '1 segundo',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutos',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int h, int m) {
    return '$h h $m min';
  }

  @override
  String durationDays(int d, int h) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$d días',
      one: '1 día',
    );
    return '$_temp0 $h h';
  }

  @override
  String get monitorSection => 'Supervisión en segundo plano';

  @override
  String get monitorEnable => 'Supervisar en segundo plano';

  @override
  String get monitorEnableHint =>
      'Recibe un aviso cuando se cae y cuando vuelve.';

  @override
  String get monitorEvery => 'Con qué frecuencia';

  @override
  String get monitorHow => 'Cómo';

  @override
  String get monitorModeSsh => 'Iniciar sesión';

  @override
  String get monitorModePort => 'Solo puerto';

  @override
  String get monitorModeSshHint =>
      'Inicia sesión por SSH y ejecuta un comando vacío. Así también comprueba que la clave sigue funcionando, y fail2ban nunca lo cuenta como un ataque.';

  @override
  String get monitorModePortHint =>
      'Solo abre y cierra el puerto. Más rápido, pero un fail2ban estricto puede contar una conexión sin inicio de sesión.';

  @override
  String everyMinutes(int n) {
    return '$n min';
  }

  @override
  String everyHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String get monitorTitle => 'Supervisión';

  @override
  String get monitorClear => 'Borrar el registro';

  @override
  String get monitorClearTitle => '¿Borrar el registro de supervisión?';

  @override
  String get monitorClearMessage =>
      'Se eliminan las comprobaciones y las caídas. La supervisión continúa.';

  @override
  String get monitorEmptyTitle => 'Ningún servidor supervisado';

  @override
  String get monitorEmpty =>
      'Activa la Supervisión en segundo plano al editar un servidor. ServerDeck lo comprueba en segundo plano y te avisa cuando se cae.';

  @override
  String get monitorServers => 'Servidores';

  @override
  String get monitorIncidents => 'Caídas';

  @override
  String get monitorNoIncidents => 'Aún no hay caídas.';

  @override
  String get monitorTimingHint =>
      'Android ejecuta tareas en segundo plano como mucho cada 15 minutos, y solo con red. El ahorro de batería o el reposo profundo pueden retrasarlas; si faltan comprobaciones, quita ServerDeck de la optimización de batería.';

  @override
  String get agoNow => 'ahora mismo';

  @override
  String agoMinutes(int n) {
    return 'hace $n min';
  }

  @override
  String agoHours(int n) {
    return 'hace $n h';
  }

  @override
  String get monitorWaiting => 'Aún sin comprobar';

  @override
  String monitorSomeDown(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n servidores están caídos',
      one: '1 servidor está caído',
    );
    return '$_temp0';
  }

  @override
  String get monitorAllUp => 'Todos los servidores funcionan';

  @override
  String monitorCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n servidores supervisados',
      one: '1 servidor supervisado',
    );
    return '$_temp0';
  }

  @override
  String monitorLast(String when) {
    return 'última: $when';
  }

  @override
  String get monitorChecking => 'Comprobando…';

  @override
  String get monitorCheckNow => 'Comprobar ahora';

  @override
  String get monitorChecked => 'Comprobado';

  @override
  String get monitorStateUnknown => 'aún sin datos';

  @override
  String monitorDownFor(String d) {
    return 'caído · $d';
  }

  @override
  String get window24h => '24 horas';

  @override
  String get window7d => '7 días';

  @override
  String get window30d => '30 días';

  @override
  String shortMinutes(int n) {
    return '$n min';
  }

  @override
  String shortHours(int n) {
    return '$n h';
  }

  @override
  String shortDays(int n) {
    return '$n d';
  }

  @override
  String get monitorOngoing => 'en curso';

  @override
  String everyNMinutes(int n) {
    return 'cada $n min';
  }

  @override
  String everyNHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'cada $n h',
      one: 'cada hora',
    );
    return '$_temp0';
  }

  @override
  String get monitorPhoneOffline =>
      'El teléfono no tiene conexión a internet, así que ahora no se puede comprobar nada.';

  @override
  String get monitorForgetTitle => '¿Eliminar esta caída?';

  @override
  String get monitorForgetMessage =>
      'Si no fue una caída real (por ejemplo, el teléfono estaba sin conexión), se eliminan la entrada y sus comprobaciones fallidas, y se vuelve a calcular la disponibilidad.';

  @override
  String get monitorIncidentsHint =>
      'Mantén pulsada una caída cerrada para eliminarla.';
}
