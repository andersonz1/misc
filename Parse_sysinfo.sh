#!/usr/bin/env bash
#
# Expose s390x /proc/sysinfo
#
# To use it, set the --collector.textfile.directory flag on the node_exporter commandline.
# The collector will parse all files in that directory matching the glob *.prom using the text format.
# Note: Timestamps are not supported.
# To atomically push completion time, either direct rename of file or sponge can be used in a cron job.
# Option1 using sponge: 
#<collector_script> | sponge <output_file>
# Sponge comes from moreutils
# Option2 renaming direct in crontab:
# Usage: add this to crontab:
#
# 7 7 * * *  /home/andersonz/prom_sysinfo.sh > /home/andersonz/sysinfo_metrics.prom.$$ && mv -f /home/andersonz/sysinfo_metrics.prom.$$ /home/andersonz/sysinfo_metrics.prom
#
# Author: Anderson Augusto <andersonz@ibm.com>


# First Level:
first_level () {
echo "# HELP sysinfo_firstlevel parsing kvm/s390x /proc/sysinfo hosts"
echo "# TYPE sysinfo_firstlevel gauge"

v1=$(awk '/LPAR Number:/ {print $3}' /proc/sysinfo)
v2=$(awk '/LPAR Characteristics:/ {print $3}' /proc/sysinfo)
v3=$(awk '/LPAR Name:/ {print $3}' /proc/sysinfo)
v4=$(awk '/LPAR Adjustment:/ {print $3}' /proc/sysinfo)
v5=$(awk '/LPAR UUID:/ {print $3}' /proc/sysinfo)

echo "sysinfo_firstlevel{lpar_number=\"${v1}\", lpar_characteristics=\"${v2}\", lpar_name=\"${v3}\", lpar_adjustment=\"${v4}\", lpar_uuid=\"${v5}\"} 1"
}

# Second Level:
second_level () {
echo "# HELP sysinfo_secondlevel parsing kvm/s390x /proc/sysinfo guests"
echo "# TYPE sysinfo_secondlevel gauge"

z1=$(awk '/VM00 Control Program:/ {print $4}' /proc/sysinfo)
z2=$(awk '/VM00 Adjustment:/ {print $3}' /proc/sysinfo)
z3=$(awk '/VM00 CPUs Total:/ {print $4}' /proc/sysinfo)
z4=$(awk '/VM00 CPUs Configured:/ {print $4}' /proc/sysinfo)
z5=$(awk '/VM00 CPUs Standby:/ {print $4}' /proc/sysinfo)
z6=$(awk '/VM00 CPUs Reserved:/ {print $4}' /proc/sysinfo)
z7=$(awk '/VM00 Extended Name:/ {print $4}' /proc/sysinfo)
z8=$(awk '/VM00 UUID:/ {print $3}' /proc/sysinfo)

echo sysinfo_secondlevel{vm_control_program=\"$z1\", vm_adjustments=\"$z2\", vm_cpu_total=\"$z3\", vm_cpu_configured=\"$z4\", vm_cpu_standby=\"$z5\", vm_cpu_reserved=\"$z6\", vm_extended_name=\"$z7\", vm_uuid=\"$z8\"} 1
}