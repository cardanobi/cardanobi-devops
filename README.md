# CardanoBI DevOps Toolkit

Collections of devops tools, scripts and automations for CardanoBI.

## Installation

This will install all dependencies required to run CardanoBI:
- [.Net 6.0](https://learn.microsoft.com/en-us/dotnet/core/install/linux-ubuntu-2204)
- [postgresql](https://www.postgresql.org/)
- [cardano-node](https://github.com/input-output-hk/cardano-node)
- [cardano-db-sync](https://github.com/input-output-hk/cardano-db-sync)
- [nginx](https://www.nginx.com/)

```sh
$ git clone https://github.com/cardanobi/cardanobi-devops.git
$ cd cardanobi-devops
$ install-all.sh
```

## .Net 6.0 Installation

```sh
$ cd cardanobi-devops
$ dotnet-init.sh
```

## Postgresql Installation

```sh
$ cd cardanobi-devops
$ postgres-init.sh
```

## Cardano-node Installation

```sh
$ cd cardanobi-devops
$ cardano-node-init.sh
```

## Cardano-db-sync Installation

```sh
$ cd cardanobi-devops
$ cardano-db-sync-init.sh
```

## Nginx Installation

```sh
$ cd cardanobi-devops
$ nginx-init.sh
```

## Contributions

CardanoBI is fully open-source and everyone is welcome to contribute. Please reach out to us via twitter (@CardanoBI), email (info@cardanobi.io) or by submitting a PR. :heart: