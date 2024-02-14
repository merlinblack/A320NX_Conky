#!/usr/bin/sh

# get sensor data as json
data=$(sensors -j 2> /dev/null)

cpu_package=$(echo $data | jq '."coretemp-isa-0000"."Package id 0"."temp1_input"')

gpu_fan=$(echo $data | jq '."amdgpu-pci-0300"."fan1"."fan1_input"')
gpu_edge=$(echo $data | jq '."amdgpu-pci-0300"."edge"."temp1_input"')
gpu_junction=$(echo $data | jq '."amdgpu-pci-0300"."junction"."temp2_input"')
gpu_mem=$(echo $data | jq '."amdgpu-pci-0300"."mem"."temp3_input"')
gpu_power=$(echo $data | jq '."amdgpu-pci-0300"."PPT"."power1_average"')

nvme_temp1=$(echo $data | jq '."nvme-pci-0d00"."Sensor 1"."temp2_input"')
nvme_temp2=$(echo $data | jq '."nvme-pci-0d00"."Sensor 2"."temp3_input"')
nvme_temp3=$(echo $data | jq '."nvme-pci-0d00"."Sensor 8"."temp9_input"')

printf '${color white}EGT - CPU:${color}${alignr}%2.1f°\n' ${cpu_package}
printf '${color white}    - GPU:${color}${alignr}%4.0f RPM %3.0f W\n' ${gpu_fan} ${gpu_power}
printf '${color}${alignr}%2.1f° %2.1f° %2.1f°\n' ${gpu_edge} ${gpu_junction} ${gpu_mem}
printf '${color white}    - NVME:${color}${alignr}%2.1f° %2.1f° %2.1f°\n' ${nvme_temp1} ${nvme_temp2} ${nvme_temp3}
