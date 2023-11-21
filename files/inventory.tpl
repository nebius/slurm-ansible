[master]
${master}


[nodes]
${nodes}


[master:vars]
is_mysql=%{ if is_mysql }1%{ else }0%{ endif }

[nodes:vars]
topo_file=%{ if platform_id == "gpu-h100-b" }inspur_topo_nccl_fix_qemu_orig.xml%{ else }giga_topo_nccl_fix_qemu_fix.xml%{ endif }
