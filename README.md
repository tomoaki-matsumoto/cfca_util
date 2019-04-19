# cfca_util

Utilities for end-users of NAOJ CfCA.

## cron.pl
A cron like command. The calling sequence is following:  

    nohup cron.pl > log.cron 2>&1 &

dot.crontab is a onfiguration file of cron.pl.

## qsubs, qdels
A command qsubs submits sequential jobs as follows:

    qsubs N  script.sh [jobid]

    N : number of jobs
    script.sh : script name for jobs
    jobid : a job id followed by script.sh (*.sdb)


## vpnconnect.sh, vpndiconnect.sh, vpnstat.sh
Command line tools of VPN for connecting, disconnecting, showing status. The user ID and password are written in vpnconnect.sh
