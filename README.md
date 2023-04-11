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

![Capture d’écran 2023-04-10 à 20 40 11](https://user-images.githubusercontent.com/113426048/231139235-a2969e14-1e80-4f16-936c-92b7afeb339e.png)

![Capture d’écran 2023-04-10 à 20 40 28](https://user-images.githubusercontent.com/113426048/231141468-f25c790a-a76c-4fd6-bc3a-955a5ed03f8c.png)

# Pre-Requisites :

Cardano Node setup with Coincashew Guide : https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node)

# How to use

The script must be ran with sudo an -E flag (to include env variables)

```shell
sudo -E ./audit-coincashew.sh
```

# Changelog

v1.0.1

Minor bug corrections

v1.0.0

Initial release

# Future improvements

- KES rotation calculation and warning
- /etc/sysctl.conf hardening
