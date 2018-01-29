# nftables installation



apt-transport-https:
  pkg.installed


#python-software-properties:
#  pkg.installed


#software-properties-common:
#  pkg.installed



#nftables-ppa:
#  pkgrepo.managed:
#    - humanname: erGW team PPA
#    - name: deb http://ppa.launchpad.net/ergw/backports/ubuntu xenial main
#    - dist: xenial
#    - file: /etc/apt/sources.list.d/nftables.list
#    - keyid: 01305F4CF29AFD6AD18309C074EA811C58A14C3D
#    - keyserver: keyserver.ubuntu.com
#    - required_in:
#      - nftables
#    - require:
#      - apt-transport-https
#      - python-software-properties
#      - software-properties-common


nftables:
  pkg.installed:
    - required_in:
      - nft flush ruleset


nft flush ruleset:
  cmd.run

nft add table filter:
  cmd.run:
    - check_cmd:
      - nft list table filter


{% for hook in ["prerouting","output"]%}
{{hook}}:
  cmd.run:
    - name: nft add chain filter {{hook}} { type filter hook {{hook}} priority 0 \; }
    - require:
      - cmd: nft add table filter


{% endfor %}



{% set local_host=grains.id %}
{% set contnet = salt['mine.get']("*","docker_spy") %}
{% set local_containers = salt['mine.get'](grains.id,"docker_spy")[grains.id]|default ([]) %}
{% set docker_bridge = salt['mine.get'](grains.id,"dockerbridge_ip")[grains.id]%}

{% for remote_host in contnet  %}
  {% for remote_container, remote_container_config in contnet[remote_host].iteritems() %}

    {% for local_container in local_containers  %}

      {% if remote_host != grains.id or remote_container!=local_container %}

        {% set host_ip=remote_container_config['ip'] %}
        {% set remote_container_ip=remote_container_config['private_ip'] %}
        {% set local_container_ip=local_containers[local_container]['private_ip'] %}
        {% set outbound_chain= local_host+"_"+local_container+"_"+remote_host+"_"+remote_container%}
        {% set inbound_chain=remote_host+"_"+remote_container+"_"+local_host+"_"+local_container %}
        {% set remote_ports = remote_container_config["ports"] %}

        {% set inbound_tuples = [] %}
        {% set outbound_tuples = [] %}

        
        {% for port in remote_ports %}

          {% do outbound_tuples.append(" . ".join([local_container_ip,host_ip,port|string]))%}
          {% if remote_host == grains.id  %} #same hosts
            {% do inbound_tuples.append(" . ".join([local_container_ip,docker_bridge,port|string]))%}
          {% endif %}
        {% endfor %}




{% if inbound_tuples|length>0 %}

inbound_chain {{ inbound_chain }}:
  cmd.run:
    - name: nft add chain filter {{ inbound_chain }}
    - require:
      - cmd: prerouting

inbound_chain_counter {{ inbound_chain }}:
  cmd.run:
    - name: nft add rule filter {{ inbound_chain }} counter


inbound_jump  {{ inbound_chain }}:
  cmd.run:
   - name: nft add rule filter prerouting  ip saddr . ip daddr . tcp sport { {{inbound_tuples|join(" , ") }} }  counter jump {{ inbound_chain }}

{% endif %}

{% if outbound_tuples|length>0 %}
outbound_chain {{ outbound_chain }}:
     cmd.run:
       - name: nft add chain filter {{ outbound_chain }}
       - require:
         - cmd: prerouting


outbound_chain_counter {{ outbound_chain }}:
 cmd.run:
   - name: nft add rule filter {{ outbound_chain }} counter



outbound_jump  {{ outbound_chain }} :
     cmd.run:
      - name: nft add rule filter prerouting  ip saddr . ip daddr . tcp dport { {{outbound_tuples|join(" , ") }} }  counter jump {{ outbound_chain }}

{% endif %}

      {% endif %} # {# {% if remote_host != grains.id or remote_container!=local_container %} #}
    {% endfor %} # {# {% for local_container in local_containers  %} #}
  {% endfor %} # {# {% for remote_container, remote_container_config in contnet[remote_host].iteritems() %} #}
{% endfor %} # {# {% for remote_host in contnet  %} #}

