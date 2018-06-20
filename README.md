This saltstack formula repository is designed to support flowmatrix.

```
├── monitoring
│   ├── bin
│   │   └── telegraf # patched telegraf binary, with nftables input plugin
│   ├── files
│   │   ├── telegraf.conf # telegraf configuration, to capture nftables data and push them to influxdb
│   │   ├── telegraf.service # register telegraf as a service
│   ├── nftables.sls # nftables installation and configuration with container-based flow monitoring
│   ├── telegraf.sls # telegraf configuration and installation
│   └── tickstack.sls # monitoring stack configuration (influxdb, chronograf, flow matrix)
```
