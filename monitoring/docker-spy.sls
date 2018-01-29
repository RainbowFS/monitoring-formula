python-setuptools:
  pkg.installed

python-dev:
  pkg.installed


/tmp/Docker_Spy-0.0.4-py2.7.egg:
  file.managed:
    - source: salt://docker_spy/Docker_Spy-0.0.4-py2.7.egg



easy_install /tmp/Docker_Spy-0.0.4-py2.7.egg:
  cmd.run:
    - require:
      - file: /tmp/Docker_Spy-0.0.4-py2.7.egg
      - pkg: python-setuptools
