#!/usr/bin/env bash
#
# Expose s390x /proc/sysinfo
# https://github.com/prometheus/node_exporter
# https://github.com/prometheus-community/node-exporter-textfile-collector-scripts
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
# 7 7 * * *  /home/andersonz/sysinfo_prom.sh > /home/andersonz/sysinfo_metrics.prom.$$ && mv -f /home/andersonz/sysinfo_metrics.prom.$$ /home/andersonz/sysinfo_metrics.prom
#
# Author: Anderson Augusto <andersonz@ibm.com>
# Date: Aug 2024

# CEC Details:
cec_details(){
m0=$(awk '/Manufacturer:/ {print $2}' /proc/sysinfo)
m1=$(awk '/Type:/ {print $2}' /proc/sysinfo)
m2=$(awk '/Model:/ {print $2" "$3}' /proc/sysinfo)
m3=$(awk '/Sequence Code:/ {print $3}' /proc/sysinfo)
echo "# HELP sysinfo_cec exposes IBM s390x cec info from /proc/sysinfo"
echo "# TYPE sysinfo_cec gauge"

echo "sysinfo_cec{cec_manufacturer=\"${m0}\", cec_type=\"${m1}\", cec_model=\"${m2}\", cec_sequence_code=\"${m3}\"} ${1}"
}

#First Level
first_level(){
l0=$(awk '/LIC Identifier:/ {print $3}' /proc/sysinfo)
l1=$(awk '/LPAR Characteristics:/ {print $3}' /proc/sysinfo)
l2=$(awk '/LPAR Name:/ {print $3}' /proc/sysinfo)
l3=$(awk '/LPAR Adjustment:/ {print $3}' /proc/sysinfo)
l4=$(awk '/LPAR CPUs Total:/ {print $4}' /proc/sysinfo)
l5=$(awk '/LPAR CPUs Configured:/ {print $4}' /proc/sysinfo)
l6=$(awk '/LPAR CPUs Standby:/ {print $4}' /proc/sysinfo)
l7=$(awk '/LPAR CPUs Reserved:/ {print $4}' /proc/sysinfo)
l8=$(awk '/LPAR CPUs Dedicated:/ {print $4}' /proc/sysinfo)
l9=$(awk '/LPAR CPUs Shared:/ {print $4}' /proc/sysinfo)
la=$(awk '/LPAR Extended Name:/ {print $4}' /proc/sysinfo)
lb=$(awk '/LPAR UUID:/ {print $3}' /proc/sysinfo)
echo "# HELP sysinfo_firstlevel exposes IBM s390x lpar info from /proc/sysinfo"
echo "# TYPE sysinfo_firstlevel gauge"

echo "sysinfo_firstlevel{lpar_number=\"${l0}\", lpar_characteristics=\"${l1}\", lpar_name=\"${l2}\", lpar_adjustment=\"${l3}\", lpar_cpus_total=\"${l4}\", lpar_cpus_configured=\"${l5}\", lpar_cpus_standby=\"${l6}\", lpar_cpus_reserved=\"${l7}\", lpar_cpus_dedicated=\"${l8}\", lpar_cpus_shared=\"${l9}\", lpar_extended_name=\"${la}\", lpar_uuid=\"${lb}\"} ${1}"
}

#Second Level
second_level(){

#KVM Guests:
if grep -iq kvm /proc/sysinfo; then
  g0=$(awk '/VM00 Name:/ {print $3}' /proc/sysinfo)
  g1=$(awk '/VM00 Control Program:/ {print $4}' /proc/sysinfo)
  g2=$(awk '/VM00 Adjustment:/ {print $3}' /proc/sysinfo)
  g3=$(awk '/VM00 CPUs Total:/ {print $4}' /proc/sysinfo)
  g4=$(awk '/VM00 CPUs Configured:/ {print $4}' /proc/sysinfo)
  g5=$(awk '/VM00 CPUs Standby:/ {print $4}' /proc/sysinfo)
  g6=$(awk '/VM00 CPUs Reserved:/ {print $4}' /proc/sysinfo)
  g7=$(awk '/VM00 Extended Name:/ {print $4}' /proc/sysinfo)
  g8=$(awk '/VM00 UUID:/ {print $3}' /proc/sysinfo)
  echo "# HELP sysinfo_secondlevel exposes IBM s390x guests from /proc/sysinfo"
  echo "# TYPE sysinfo_secondlevel gauge"

  echo "sysinfo_secondlevel{vm_name=\"${g0}\",vm_control_program=\"${g1}\", vm_adjustment=\"${g2}\", vm_cpu_total=\"${g3}\", vm_cpu_configured=\"${g4}\", vm_cpu_standby=\"${g5}\", vm_cpu_reserved=\"${g6}\", vm_extended_name=\"${g7}\", vm_uuid=\"${g8}\"} ${1}"
fi

#zVM Guests:
if grep -iq z/vm /proc/sysinfo; then
  g0=$(awk '/VM00 Name:/ {print $3}' /proc/sysinfo)
  g1=$(awk '/VM00 Control Program:/ {print $4" "$5}' /proc/sysinfo)
  g2=$(awk '/VM00 Adjustment:/ {print $3}' /proc/sysinfo)
  g3=$(awk '/VM00 CPUs Total:/ {print $4}' /proc/sysinfo)
  g4=$(awk '/VM00 CPUs Configured:/ {print $4}' /proc/sysinfo)
  g5=$(awk '/VM00 CPUs Standby:/ {print $4}' /proc/sysinfo)
  g6=$(awk '/VM00 CPUs Reserved:/ {print $4}' /proc/sysinfo)
  g7=$(awk '/VM00 Extended Name:/ {print $4}' /proc/sysinfo)
  g8=$(awk '/VM00 UUID:/ {print $3}' /proc/sysinfo)
  echo "# HELP sysinfo_secondlevel exposes IBM s390x guests from /proc/sysinfo"
  echo "# TYPE sysinfo_secondlevel gauge"

  echo "sysinfo_secondlevel{vm_name=\"${g0}\",vm_control_program=\"${g1}\", vm_adjustment=\"${g2}\", vm_cpu_total=\"${g3}\", vm_cpu_configured=\"${g4}\", vm_cpu_standby=\"${g5}\", vm_cpu_reserved=\"${g6}\", vm_extended_name=\"${g7}\", vm_uuid=\"${g8}\"} ${1}"
fi
}

# Main Function
if grep -iq vm /proc/sysinfo; then
  cec_details "1"
  first_level "0"
  second_level "1"
else
  cec_details "1"
  first_level "1"
# second_level "0"
fi

