<p align="center" dir="auto">
  <a href="https://github.com/Kirael12/Cardano-Node-Audit/releases">
    <img src="https://img.shields.io/github/v/release/Kirael12/Cardano-Node-Audit?style=for-the-badge" style="max-width: 100%;">
  </a>
</p>

# Cardano-Node-Audit

## Full revamp (v7.0.0 - september 2024)

The script has been completely revamped and reworked. It now supports **various** types of Cardano installations :

- Coincashew
- CNODE (Guild Operators)
- Other installations

The code has been optimized and reorganized for greater efficiency. Configuration parsing is more accurate and now includes more parameters and checks.

For installations that are not based on Coincashew or CNODE, a more general parsing is performed by searching for systemd service files containing cardano. More configuration detection options will be added in future releases.

A selection menu is now available when launching the script, allowing users to choose the target installation type. It also offers the option to perform only SecOps security checks on the server.

It runs the following checks :

### Cardano compliance

- New 9.1.0 Cardano-Node version requirement for Chang hardfork
- Cardano-node latest version verification
- Cardano bootstrap check
- Environment Variables
- Systemd cardano-node file verification and parsing
- Cardano startup script verification and parsing
- Node operation mode (Block Producer ? Relay ?)
- Topology mode (p2p enabled)
- Topology configuration file parsing and compliance checks
- Cardano security checks (hot keys permissions, cold keys detection)
- KES keys rotation alert

### SecOps checks

- SSHD hardening
- Null passwords check
- Important services running (ufw, fail2ban, ntp server...)
- Firewalling rules extract
- sysctl.conf hardening check

# Pre-Requisites :

cardano-node up and running. You can setup a Cardano node with :
- Coincashew guide : https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node)
- CNODE (Guild-Operators) : https://cardano-community.github.io/guild-operators/
- Developper Portal guide : https://developers.cardano.org/docs/operate-a-stake-pool/

Several bash commands are necessary (tput, date, grep, awk, jq). A check is performed when the script starts.

cardano-cli is also used for KES key rotate check.

# How to use

The script must be run with sudo an -E flag (to include env variables)

```shell
sudo -E ./cardano-node-audit.sh
```

You will be asked to select the type of your Cardano setup with a menu. You can choose to perform only security checks.

![Capture d’écran 2024-09-21 à 13 07 12](https://github.com/user-attachments/assets/5a904976-d88c-4104-bd55-3456691a0249)

You will then be asked if you want to export the results to a file.

![Capture d’écran 2024-09-21 à 13 07 28](https://github.com/user-attachments/assets/fb22ef2b-0e25-4a4e-98f7-a1f5b3986ab0)

# Screenshots

![Capture d’écran 2024-09-21 à 13 13 25](https://github.com/user-attachments/assets/7eaee8bd-c1c4-4003-9a02-53fb72996f97)
![Capture d’écran 2024-09-21 à 13 12 19](https://github.com/user-attachments/assets/b8953db7-101a-4e64-99ef-0c0283b027ea)
![Capture d’écran 2024-09-21 à 13 08 50](https://github.com/user-attachments/assets/455b5c39-bd98-4955-8475-a0e05facc090)

# Changelog

v7.0.0 (september 2024)

- Full revamp
- The script now works with CNODE setup, or other Cardano setups
- New selection menu
- Major code optimization
- Improvements in configuration detection, and file parsing

v6.0.0 (july 2024)

- Major improvements in code optimization
- Major improvements in parsing configuration files
- Cardano-node 9.1.0 new requirement for Chang harfork
- New P2P checks (topology and config)
- Optional results export to a file

v5.0.0 (march 2024)

- Added new Cardano P2P checks for relays
- Added new Cardano P2P checks for block producer
- Added topology bootstrap check
- Several code improvements

v4.0.0

- Updated new Cardano github path

v3.0.0

- Added Cardano Node latest version verification
- Added Cardano Cli latest version verification
- Added option for non coincashew users
- Several code improvements

v2.0.1

- Minor bug correction

v2.0.0

- Improved Cardano config parsing accuracy
- Improved KES files detection and checks
- Added KES expiry calculation and alerts
- Added sysctl hardening check

v1.0.2

- KES files permission check update

v1.0.1

- Minor bug corrections

v1.0.0 (april 2023)

Initial release
