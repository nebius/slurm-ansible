# What is this
This is an ansible playbook to run ML specific worloads. Developed to run gpt3 training.
This playbook installs software, runs slurm master, configures the gpu resources in slurm cluster and installs pyxis plug-in that let running container images as a workloads
## Prerequisite
To run this playbook, you need to create VMs with ubuntu 20 and CUDA 12. After that you need to put this VMs in `invetory.yaml`. Master can be a VM wihtout GPU.
Better use naming. `test` for master. and test-[1-32] for working nodes
## How to run
```
ansible-playbook -i inventory.yaml install-slurm # for slurm installation
ansible-playbook -i inventory.yaml update-conf.yaml # to update slurm.conf on all nodes
ansible-playbook -i inventory.yaml register-nvidia.yaml # for pyxis plugin
```