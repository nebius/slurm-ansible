# slurm.conf file generated by configurator.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
ClusterName=Slurm-cluster
SlurmctldHost=node-master

SlurmUser=slurm
SlurmdUser=slurm
SlurmctldPort=6817
SlurmdPort=6818
AuthType=auth/munge
StateSaveLocation=/var/lib/slurm/slurmctld
StateSaveLocation=/var/lib/slurm/slurmctld
SwitchType=switch/none
MpiDefault=pmi2
SlurmctldPidFile=/run/slurmctld.pid
SlurmdPidFile=/run/slurmd.pid
ProctrackType=proctrack/pgid
ReturnToService=0

# TIMERS
SlurmctldTimeout=300
SlurmdTimeout=300
InactiveLimit=0
MinJobAge=300
KillWait=30
Waittime=0


#
DebugFlags=NO_CONF_HASH

# LOGGING/ACCOUNTNG
SlurmctldDebug=info
SlurmctldLogFile=/var/log/slurm/slurmctld.log
SlurmdDebug=info
SlurmdLogFile=/var/log/slurm/slurmd.log
JobAcctGatherType=jobacct_gather/none

#DB
%{ if is_mysql }
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageHost=node-master
JobCompType=jobcomp/mysql
JobCompUser=slurm
JobCompPass= ${password}
JobCompHost= ${hostname}
JobCompLoc=slurm-db
%{ endif }


GresTypes=gpu
SelectType=select/cons_tres
# COMPUTE NODES
NodeName=node-[1-${cluster_nodes_count}] Gres=gpu:8 CPUs=160 RealMemory=1290080 State=idle State=UNKNOWN
PartitionName=debug Nodes=ALL Default=YES MaxTime=INFINITE State=UP
