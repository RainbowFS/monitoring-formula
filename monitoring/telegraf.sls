/var/log/telegraf/:
  file.directory

/usr/bin/telegraf:
  file.managed:
       - source: salt://monitoring/bin/telegraf
       - mode: 0775
       - skip_verify: True
       - makedirs: True
       - required_in:
         -  /etc/telegraf/telegraf.conf

/etc/telegraf/telegraf.conf:
  file.managed:
    - source: salt://monitoring/files/telegraf.conf
    - template: jinja
    - makedirs: True


telegraf_systemd_unit:
  file.managed:
    - name: /etc/systemd/system/telegraf.service
    - source: salt://monitoring/files/telegraf.service
    - template: jinja
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /usr/bin/telegraf
      - file: /etc/telegraf/telegraf.conf

telegraf:
  service.running:
    - watch:
      - module: telegraf_systemd_unit
    - require:
       - module:
          telegraf_systemd_unit
      
