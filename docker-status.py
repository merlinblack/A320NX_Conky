#!/usr/bin/env python

import docker
client = docker.from_env()
containers = client.containers.list()
if len(containers):
  print('${color white}Docker:')
for container in containers:
  status = container.status
  if status == 'exited':
    status = '${color red}' + status
  print(' ${{color grey}}{:1.29}$alignr${{color}}{}'.format(container.attrs['Config']['Image'], status))
