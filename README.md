# cfca_util

Utilities for end-users of NAOJ CfCA.

## cron.pl
A command like cron. The calling sequence is following:  

    nohup cron.pl > log.cron 2>&1 &

dot.crontab is a sample of the configuration file for cron.pl. This file is located on the home directory, ~/.crontab usually.

## qsubs
A command which submits sequential jobs as follows:

    qsubs N  script.sh [jobid]

    N : number of jobs
    script.sh : script name for jobs
    jobid : a job id followed by script.sh (*.sdb)

## qdels
A command which delets jobs as follows:

    qdels jobname [N]

    jobname : a jobname printed by the qstat command.
    N : number of jebs to be deleted    

## vpnconnect.sh, vpndiconnect.sh, vpnstat.sh
Command line tools of VPN for connecting, disconnecting, showing status. The user ID and password are written in vpnconnect.sh
