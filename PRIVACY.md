# ServerDeck privacy policy

Last updated: 7 October 2026

ServerDeck is an SSH client for managing your own Linux servers from a phone.
It is made by szabolevi98 (info@levente.net) and is open source under the
GNU AGPL-3.0: https://github.com/szabolevi98/serverdeck

## In short

ServerDeck collects nothing. It has no account, no analytics, no advertising,
no crash reporting and no server of its own. Everything you enter stays on your
phone, and the app talks to nothing but the servers you add.

## What is stored, and where

Everything below is stored only on your device, in the app's private storage:

- **Server details** you enter: name, address, port and user name.
- **Private keys and passwords**, kept in the Android Keystore (on iOS, the
  Keychain). A key's passphrase is used once to unlock it and is not kept. A
  password used to install a key is not kept either.
- **Host keys** of servers you have accepted, to recognise them later.
- **Saved commands and log sources** you create.
- **Monitoring results**: the checks of the last 30 days and the last 500
  outages of the servers you choose to monitor.
- **Settings**, such as the theme, the language and the app lock.

App backups are turned off, so this data is not copied to Google Drive or any
other backup. Uninstalling the app deletes all of it.

## Network connections

ServerDeck connects only to:

- **The servers you add**, over SSH, to show their status, services, logs, a
  terminal and the commands you run. What is sent to a server is what you ask
  for; what comes back is shown to you and not sent anywhere else.
- **1.1.1.1, 8.8.8.8 or 9.9.9.9**, only when background monitoring cannot reach
  a server, to tell whether the phone itself is offline. The app opens a TCP
  connection and closes it at once without sending any data.

No data is shared with the developer or with any third party.

## Permissions

- **Internet and network state**: to connect to your servers.
- **Biometrics**: for the optional app lock. Fingerprints and faces are
  checked by the phone's system; the app never receives them.
- **Notifications**: to tell you when a monitored server goes down or comes
  back.
- **Run in the background and at startup**: for the monitoring checks you turn
  on, which Android schedules at most every 15 minutes.

## Children

ServerDeck is a tool for system administrators and is not directed at
children.

## Changes

Changes to this policy are published at this address, with a new date at the
top. Its history is in the project's Git repository.

## Contact

Questions about this policy: info@levente.net
