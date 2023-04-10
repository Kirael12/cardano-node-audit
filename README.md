# Cardano-Audit-Coincashew

These script audits Cardano Node setup with Coincashew guide.

It runs the following checks :

- Environnement Variables
- Systemd cardano-node file verification and parsing
- Cardano startup script verification and parsing
- Node operation mode (Block Producer ? Relay ?)
- Topology mode (p2p enabled ?)
- Topology configuration
- Keys
- SSHD hardening
- Null passwords check
- key services running
- Firewalling rules extract

Pre-Requisites :

Cardano Node setup with Coincashew Guide : https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node)

# How to use

The script must be ran with sudo an -E flag

```shell
sudo -E ./audit-coincashew.sh
```

# Future improvements

- KES rotation calculation and warning
- /etc/sysctl.conf hardening
