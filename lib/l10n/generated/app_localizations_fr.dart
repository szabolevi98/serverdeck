// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ServerDeck';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get rename => 'Renommer';

  @override
  String get paste => 'Coller';

  @override
  String get fieldRequired => 'Obligatoire';

  @override
  String get serversTitle => 'Serveurs';

  @override
  String get serversEmptyTitle => 'Aucun serveur';

  @override
  String get serversEmpty =>
      'Ajoutez un serveur avec son adresse et votre nom d’utilisateur. ServerDeck se connecte en SSH ; rien n’est à installer sur le serveur.';

  @override
  String get serverAdd => 'Ajouter un serveur';

  @override
  String get serverEditTitle => 'Modifier le serveur';

  @override
  String serverDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get serverDeleteMessage =>
      'Son mot de passe enregistré, ses commandes et ses sources de journaux sont supprimés aussi. Les clés sont conservées.';

  @override
  String get serverSectionConnection => 'Connexion';

  @override
  String get serverSectionAuth => 'Identification';

  @override
  String get serverHost => 'Adresse';

  @override
  String get serverUser => 'Utilisateur';

  @override
  String get serverPort => 'Port';

  @override
  String get serverPortInvalid => '1–65535';

  @override
  String get serverName => 'Nom';

  @override
  String get serverNameHint => 'L’adresse, si laissé vide';

  @override
  String get statusChecking => '…';

  @override
  String get statusDown => 'hors ligne';

  @override
  String get authKey => 'Clé';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authKeyPick => 'Clé SSH';

  @override
  String get authKeyMissing => 'Choisissez une clé';

  @override
  String get authKeyNone =>
      'Aucune clé. Générez-en une et placez sa partie publique dans ~/.ssh/authorized_keys sur le serveur.';

  @override
  String get authPasswordKept => 'Enregistré. Laissez vide pour le conserver.';

  @override
  String get keysTitle => 'Clés SSH';

  @override
  String get keysEmptyTitle => 'Aucune clé';

  @override
  String get keysEmpty =>
      'Générez une nouvelle clé Ed25519 ou importez une clé existante. La clé privée reste dans le stockage chiffré du téléphone.';

  @override
  String get keyAdd => 'Ajouter une clé';

  @override
  String get keyGenerateNew => 'Générer une nouvelle clé';

  @override
  String get keyGenerateHint => 'Ed25519, créée ici sur le téléphone';

  @override
  String get keyGenerated =>
      'Clé prête. Copiez sa partie publique sur le serveur.';

  @override
  String get keyImport => 'Importer une clé';

  @override
  String get keyImportHint => 'Clé privée OpenSSH, RSA ou ECDSA';

  @override
  String get keyImportNote =>
      'Une clé protégée par une phrase secrète est déverrouillée une fois et enregistrée dans le stockage chiffré du téléphone. La phrase secrète n’est pas conservée.';

  @override
  String get keyImportedName => 'Clé importée';

  @override
  String get keyName => 'Nom';

  @override
  String get keyPrivate => 'Clé privée';

  @override
  String get keyPassphrase => 'Phrase secrète de la clé';

  @override
  String get keyCopy => 'Copier la clé publique';

  @override
  String get keyCopied => 'Clé publique copiée';

  @override
  String keyDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get keyDeleteMessage =>
      'La clé privée est supprimée définitivement du téléphone.';

  @override
  String keyDeleteUsed(String servers) {
    return 'La clé privée est supprimée définitivement du téléphone. Ces serveurs l’utilisent et auront besoin d’une autre clé : $servers';
  }

  @override
  String get keyErrorNotAKey =>
      'Ce n’est pas une clé privée. Collez tout le texte qui commence par -----BEGIN.';

  @override
  String get keyErrorNeedsPassphrase =>
      'Cette clé est protégée. Saisissez sa phrase secrète.';

  @override
  String get keyErrorWrongPassphrase => 'Phrase secrète incorrecte.';

  @override
  String get keyErrorUnsupported =>
      'ServerDeck ne connaît pas ce type de clé. Utilisez une clé Ed25519, RSA ou ECDSA.';

  @override
  String get sessionOnline => 'en ligne';

  @override
  String get sessionConnecting => 'connexion';

  @override
  String get sessionReconnect => 'Se reconnecter';

  @override
  String get sessionConnectingTo => 'Connexion…';

  @override
  String get problemUnreachableTitle => 'Serveur injoignable';

  @override
  String problemUnreachable(String host, int port) {
    return 'Impossible d’ouvrir une connexion vers $host sur le port $port. Vérifiez l’adresse, le port et la connexion du téléphone.';
  }

  @override
  String get problemTimeoutTitle => 'Pas de réponse à temps';

  @override
  String get problemTimeout =>
      'Le serveur n’a pas répondu en 12 secondes. Il est peut-être surchargé, ou un pare-feu bloque la connexion.';

  @override
  String get problemAuthTitle => 'Échec de l’identification';

  @override
  String problemAuthKey(String user) {
    return 'Le serveur n’a pas accepté la clé de $user. Placez la partie publique de la clé dans ~/.ssh/authorized_keys sur le serveur.';
  }

  @override
  String problemAuthPassword(String user) {
    return 'Le serveur n’a pas accepté le mot de passe de $user.';
  }

  @override
  String get problemHostKeyChangedTitle => 'La clé du serveur a changé';

  @override
  String get problemHostKeyChanged =>
      'Le serveur a présenté une clé d’identité différente de celle que vous aviez acceptée. Il peut s’agir d’une réinstallation, ou de quelqu’un entre les deux. ServerDeck ne s’est pas connecté.';

  @override
  String get problemHostKeyRefusedTitle => 'Clé refusée';

  @override
  String get problemHostKeyRefused =>
      'Vous n’avez pas accepté la clé du serveur, ServerDeck ne s’est donc pas identifié.';

  @override
  String get problemMissingTitle => 'Aucun identifiant';

  @override
  String get problemMissing =>
      'Ce serveur n’a ni clé ni mot de passe. Modifiez le serveur et ajoutez-en un.';

  @override
  String get problemDisconnectedTitle => 'Connexion perdue';

  @override
  String get problemDisconnected =>
      'La connexion a été coupée : un changement de réseau, un redémarrage du serveur, ou le téléphone s’est mis en veille.';

  @override
  String get problemOtherTitle => 'Connexion impossible';

  @override
  String get hostKeyNewTitle => 'Nouveau serveur';

  @override
  String hostKeyNew(String host) {
    return 'C’est la première fois que vous vous connectez à $host. Voici la clé d’identité du serveur :';
  }

  @override
  String get hostKeyCheck =>
      'Pour en être sûr, cette commande sur le serveur affiche la même empreinte :';

  @override
  String get hostKeyAccept => 'Accepter';

  @override
  String get hostKeyReject => 'Refuser';

  @override
  String get hostKeyKnown => 'Acceptée';

  @override
  String get hostKeyNow => 'Maintenant';

  @override
  String get hostKeyForget => 'Oublier l’ancienne clé';

  @override
  String get hostKeyForgetTitle => 'Oublier l’ancienne clé ?';

  @override
  String get hostKeyForgetMessage =>
      'Ne le faites que si vous savez pourquoi la clé a changé, par exemple parce que vous avez réinstallé le serveur. ServerDeck vous demandera alors d’accepter la nouvelle clé.';

  @override
  String get statsFailedTitle => 'Impossible de lire le serveur';

  @override
  String get statsFailed =>
      'La réponse du serveur n’avait pas de sens. Les statistiques nécessitent Linux (/proc).';

  @override
  String get statsStale =>
      'La dernière actualisation a échoué. Les valeurs ci-dessus sont plus anciennes.';

  @override
  String get statCpu => 'CPU';

  @override
  String get statMemory => 'Mémoire';

  @override
  String get statDisk => 'Disque';

  @override
  String statCores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cœurs',
      one: '1 cœur',
    );
    return '$_temp0';
  }

  @override
  String get statHistory => '3 dernières minutes';

  @override
  String get statHistoryHint =>
      'Actualisé toutes les 3 secondes tant que cet écran est ouvert.';

  @override
  String get statNetIn => 'Entrant';

  @override
  String get statNetOut => 'Sortant';

  @override
  String get statLoad => 'Charge';

  @override
  String get statLoad1 => '1 min';

  @override
  String get statLoad5 => '5 min';

  @override
  String get statLoad15 => '15 min';

  @override
  String get statDisks => 'Disques';

  @override
  String get statSwap => 'Swap';

  @override
  String get statUptime => 'En marche';

  @override
  String uptimeDays(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0, $hours h';
  }

  @override
  String uptimeHours(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get tabOverview => 'Aperçu';

  @override
  String get tabServices => 'Services';

  @override
  String get servicesFailedTitle => 'Impossible de lister les services';

  @override
  String get servicesSearch => 'Rechercher par nom ou description';

  @override
  String servicesRunning(int count) {
    return 'Actifs · $count';
  }

  @override
  String servicesFailed(int count) {
    return 'En échec · $count';
  }

  @override
  String servicesAll(int count) {
    return 'Tous · $count';
  }

  @override
  String get servicesNone => 'Aucun résultat.';

  @override
  String get servicesNoneFailed => 'Aucun service en échec.';

  @override
  String get containersNone => 'Aucun conteneur.';

  @override
  String get stateRunning => 'actif';

  @override
  String get stateExited => 'terminé';

  @override
  String get stateFailed => 'en échec';

  @override
  String get stateActivating => 'démarrage';

  @override
  String get stateInactive => 'arrêté';

  @override
  String get stateUnhealthy => 'défaillant';

  @override
  String get statePaused => 'en pause';

  @override
  String get stateRestarting => 'redémarrage';

  @override
  String get stateExitedContainer => 'terminé';

  @override
  String get stateCreated => 'créé';

  @override
  String get actionRestart => 'Redémarrer';

  @override
  String get actionReload => 'Recharger';

  @override
  String get actionStop => 'Arrêter';

  @override
  String get actionStart => 'Démarrer';

  @override
  String actionConfirmTitle(String action, String subject) {
    return '$action $subject ?';
  }

  @override
  String actionConfirmMessage(String command) {
    return 'Ceci s’exécute sur le serveur :\n$command';
  }

  @override
  String actionDone(String action, String subject) {
    return '$action : terminé pour $subject';
  }

  @override
  String actionFailed(int code, String reason) {
    return 'Cela n’a pas fonctionné (code de sortie $code). $reason';
  }

  @override
  String get actionNeedsSudo =>
      'Il faut des droits d’administrateur. Connectez-vous en root, ou autorisez sudo sans mot de passe pour cette commande.';

  @override
  String get tabLogs => 'Journaux';

  @override
  String get logsJournal => 'Journal système';

  @override
  String get logsAdd => 'Source';

  @override
  String get logsAddTitle => 'Nouvelle source de journal';

  @override
  String get logsKindUnit => 'Service';

  @override
  String get logsKindFile => 'Fichier';

  @override
  String get logsUnitLabel => 'Nom du service';

  @override
  String get logsFileLabel => 'Chemin du fichier';

  @override
  String get logsFilter => 'Filtrer';

  @override
  String get logsErrorsOnly => 'Erreurs uniquement';

  @override
  String get logsPause => 'Pause';

  @override
  String get logsResume => 'Reprendre';

  @override
  String get logsClear => 'Effacer l’écran';

  @override
  String logsNewLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles lignes',
      one: '1 nouvelle ligne',
    );
    return '$_temp0';
  }

  @override
  String logsEnded(int code) {
    return 'Le suivi du journal s’est arrêté (code de sortie $code).';
  }

  @override
  String logsDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get logsDeleteMessage =>
      'Seule la source enregistrée est supprimée, pas le journal sur le serveur.';

  @override
  String get tabCommands => 'Commandes';

  @override
  String get commandAdd => 'Nouvelle commande';

  @override
  String get commandEdit => 'Modifier la commande';

  @override
  String get commandQuick => 'Commande ponctuelle…';

  @override
  String get commandRun => 'Exécuter';

  @override
  String commandRunTitle(String name) {
    return 'Exécuter $name ?';
  }

  @override
  String get commandSaved => 'Commandes enregistrées';

  @override
  String get commandTemplates => 'Pour commencer';

  @override
  String get commandTemplatesHint =>
      'Touchez-en une pour l’ajouter à vos commandes enregistrées. Elles ne font que lire.';

  @override
  String get commandLabel => 'Commande';

  @override
  String get commandEverywhere => 'Sur tous les serveurs';

  @override
  String get commandEverywhereHint => 'Apparaît pour tous vos serveurs';

  @override
  String get commandConfirm => 'Demander avant d’exécuter';

  @override
  String get commandCopy => 'Copier la sortie';

  @override
  String get commandCopied => 'Sortie copiée';

  @override
  String get commandError => 'erreur';

  @override
  String get commandStopped => 'arrêtée';

  @override
  String commandExit(int code) {
    return 'sortie $code';
  }

  @override
  String get commandRunning => 'en cours';

  @override
  String get commandNoOutput => 'Aucune sortie.';

  @override
  String get tplDisk => 'Espace disque';

  @override
  String get tplFolders => 'Plus gros dossiers';

  @override
  String get tplUpdates => 'Mises à jour en attente';

  @override
  String get tplWho => 'Qui est connecté';

  @override
  String get tplApache => 'Test de la config Apache';

  @override
  String get tplNginx => 'Test de la config Nginx';

  @override
  String get tplTop => 'Top CPU';

  @override
  String get tplPorts => 'Ports en écoute';

  @override
  String get tabTerminal => 'Terminal';

  @override
  String get terminalClosed => '[shell fermé]';

  @override
  String get terminalReopen => 'Nouveau shell';

  @override
  String get lockReason => 'Déverrouiller ServerDeck';

  @override
  String get lockTitle => 'ServerDeck est verrouillé';

  @override
  String get lockUnlock => 'Déverrouiller';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSecurity => 'Sécurité';

  @override
  String get settingsLock => 'Verrouillage de l’app';

  @override
  String get settingsLockHint =>
      'Empreinte, visage ou code PIN du téléphone au démarrage et après une minute en arrière-plan.';

  @override
  String get settingsLockUnsupported =>
      'Configurez d’abord un verrouillage d’écran sur le téléphone.';

  @override
  String get settingsKnownHosts => 'Clés de serveur connues';

  @override
  String get settingsKnownHostsEmpty => 'Aucune clé de serveur acceptée.';

  @override
  String get settingsKnownHostsHint =>
      'Clés d’identité acceptées au premier contact. Quand la clé d’un serveur change, ServerDeck ne se connecte plus tant que vous n’oubliez pas l’ancienne ici.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutText =>
      'Gestionnaire de serveurs SSH. Open source, licence AGPL-3.0. Ne collecte rien ; tout reste sur le téléphone.';

  @override
  String get installKey => 'Installer la clé avec un mot de passe';

  @override
  String get installKeyAction => 'Installer';

  @override
  String installKeyHint(String user) {
    return 'ServerDeck se connecte une fois avec le mot de passe de $user et ajoute la partie publique de la clé à ~/.ssh/authorized_keys. Le mot de passe n’est pas conservé.';
  }

  @override
  String get installKeyDone =>
      'La clé est sur le serveur. Connexion avec la clé…';

  @override
  String get sessionError => 'erreur';

  @override
  String get themeTitle => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String monitorDownTitle(String name) {
    return '$name est hors service';
  }

  @override
  String monitorUpTitle(String name) {
    return '$name est de nouveau en ligne';
  }

  @override
  String get monitorUpBody => 'La vérification fonctionne de nouveau.';

  @override
  String monitorUpBodyFor(String duration) {
    return 'Il a été hors service pendant $duration.';
  }

  @override
  String monitorHostKeyTitle(String name) {
    return '$name : la clé du serveur a changé';
  }

  @override
  String get monitorHostKeyBody =>
      'ServerDeck ne s’est pas connecté. Examinez le serveur avant d’accepter la nouvelle clé.';

  @override
  String get monitorProblemUnreachable => 'Impossible d’ouvrir une connexion.';

  @override
  String get monitorProblemTimeout => 'Pas de réponse à temps.';

  @override
  String get monitorProblemAuth =>
      'Il répond, mais n’a pas accepté l’identification.';

  @override
  String get monitorProblemDisconnected => 'Il a coupé avant l’identification.';

  @override
  String get monitorProblemHostKeyChanged => 'Sa clé a changé.';

  @override
  String get monitorProblemHostKeyUnknown =>
      'Sa clé n’est pas encore acceptée : ouvrez-le une fois dans l’app.';

  @override
  String get monitorProblemMissing => 'Il n’a ni clé ni mot de passe.';

  @override
  String get monitorProblemOther => 'La vérification a échoué.';

  @override
  String durationSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n secondes',
      one: '1 seconde',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n minutes',
      one: '1 minute',
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
      other: '$d jours',
      one: '1 jour',
    );
    return '$_temp0 $h h';
  }

  @override
  String get monitorSection => 'Surveillance en arrière-plan';

  @override
  String get monitorEnable => 'Surveiller en arrière-plan';

  @override
  String get monitorEnableHint =>
      'Soyez prévenu quand il tombe et quand il revient.';

  @override
  String get monitorEvery => 'Fréquence';

  @override
  String get monitorHow => 'Méthode';

  @override
  String get monitorModeSsh => 'Connexion';

  @override
  String get monitorModePort => 'Port seul';

  @override
  String get monitorModeSshHint =>
      'Se connecte en SSH et exécute une commande vide. Cela vérifie aussi que la clé fonctionne toujours, et fail2ban ne le compte jamais comme une attaque.';

  @override
  String get monitorModePortHint =>
      'Ouvre et ferme seulement le port. Plus rapide, mais un fail2ban strict peut compter une connexion sans identification.';

  @override
  String everyMinutes(int n) {
    return '$n min';
  }

  @override
  String everyHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n heures',
      one: '1 heure',
    );
    return '$_temp0';
  }

  @override
  String get monitorTitle => 'Surveillance';

  @override
  String get monitorClear => 'Effacer le journal';

  @override
  String get monitorClearTitle => 'Effacer le journal de surveillance ?';

  @override
  String get monitorClearMessage =>
      'Les vérifications et les pannes sont supprimées. La surveillance continue.';

  @override
  String get monitorEmptyTitle => 'Aucun serveur surveillé';

  @override
  String get monitorEmpty =>
      'Activez la surveillance en arrière-plan en modifiant un serveur. ServerDeck le vérifie en arrière-plan et vous prévient quand il tombe.';

  @override
  String get monitorServers => 'Serveurs';

  @override
  String get monitorIncidents => 'Pannes';

  @override
  String get monitorNoIncidents => 'Aucune panne.';

  @override
  String get monitorTimingHint =>
      'Android exécute les tâches en arrière-plan au plus toutes les 15 minutes, et seulement avec un réseau. L’économiseur de batterie ou la veille profonde peuvent les retarder ; si des vérifications manquent, retirez ServerDeck de l’optimisation de la batterie.';

  @override
  String get agoNow => 'à l’instant';

  @override
  String agoMinutes(int n) {
    return 'il y a $n min';
  }

  @override
  String agoHours(int n) {
    return 'il y a $n h';
  }

  @override
  String get monitorWaiting => 'Pas encore vérifié';

  @override
  String monitorSomeDown(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n serveurs sont hors service',
      one: '1 serveur est hors service',
    );
    return '$_temp0';
  }

  @override
  String get monitorAllUp => 'Tous les serveurs sont en ligne';

  @override
  String monitorCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n serveurs surveillés',
      one: '1 serveur surveillé',
    );
    return '$_temp0';
  }

  @override
  String monitorLast(String when) {
    return 'dernière : $when';
  }

  @override
  String get monitorChecking => 'Vérification…';

  @override
  String get monitorCheckNow => 'Vérifier maintenant';

  @override
  String get monitorChecked => 'Vérifié';

  @override
  String get monitorStateUnknown => 'pas encore de données';

  @override
  String monitorDownFor(String d) {
    return 'hors service · $d';
  }

  @override
  String get window24h => '24 heures';

  @override
  String get window7d => '7 jours';

  @override
  String get window30d => '30 jours';

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
    return '$n j';
  }

  @override
  String get monitorOngoing => 'en cours';

  @override
  String everyNMinutes(int n) {
    return 'toutes les $n min';
  }

  @override
  String everyNHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'toutes les $n h',
      one: 'toutes les heures',
    );
    return '$_temp0';
  }

  @override
  String get monitorPhoneOffline =>
      'Le téléphone n’est pas connecté à internet, rien ne peut donc être vérifié maintenant.';

  @override
  String get monitorForgetTitle => 'Supprimer cette panne ?';

  @override
  String get monitorForgetMessage =>
      'Si ce n’était pas une vraie panne (le téléphone était hors ligne, par exemple), l’entrée et ses vérifications échouées sont supprimées, et la disponibilité est recalculée.';

  @override
  String get monitorIncidentsHint =>
      'Appuyez longuement sur une panne terminée pour la supprimer.';
}
