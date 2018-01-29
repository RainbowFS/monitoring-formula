{% if grains.id ==  salt['pillar.get']('monitoring:host')   %}

include:
  - docker

chronograf:latest:
  docker_image.present:
    - require:
      - sls: docker


influxdb:latest:
   docker_image.present:
     - require:
       - sls: docker


{% set monitoring_host = salt['pillar.get']('monitoring:host') %}

{% set monitoring_host_ip = salt['mine.get'](grains.id,"controlpath_ip")[grains.id][0]  %}


chronograf:
  docker_container.running:
    - image: chronograf:latest
    - port_bindings:
      - {{ monitoring_host_ip }}:8888:8888
    - link: influxdb
    - environment:
      - INFLUXDB_URL=http://{{ monitoring_host_ip  }}:8086
    - require:
      - chronograf:latest
      - influxdb:latest

influxdb:
  docker_container.running:
      - image: influxdb:latest
      - detach: True
      - port_bindings:
        - {{ monitoring_host_ip  }}:8086:8086
      - require:
        - influxdb:latest

nherbaut/flowmatrix:
  docker_image.present:
    - require:
      - sls: docker
  docker_container.running:
    - name: flowmatrix
    - detach: True
    - image: nherbaut/flowmatrix
    - port_bindings:
      - {{ monitoring_host_ip }}:5011:5011
    - environment:
      - INFLUX_DB_HOST: {{ monitoring_host_ip  }}
    - require:
      - docker_container: influxdb

{% endif %}
