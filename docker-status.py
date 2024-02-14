#!/usr/bin/env python

import docker
client = docker.from_env()
containers = client.containers.list(all=True)
if len(containers):
  print('${color white}Docker:')
for container in containers:
  status = container.status
  if status == 'exited':
    status = '${color red}DEPARTED'
  else:
    status = '${color lightblue}' + status

  print(' ${{color yellow}}{:1.29}$alignr${{color}} {} '.format(container.attrs['Config']['Image'], status))
