#!/bin/bash

## Test io in a block device
## *** Caution, this test has Write operations, use this only in a Free block device ***
## Reference: https://docs.oracle.com/en-us/iaas/Content/Block/References/samplefiocommandslinux.htm

## Install fio package case not already installed
if ! rpm -qa | grep -qw fio; then
    yum install fio -y
fi

## Basic Help print
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo -e "`basename $0`: Script to test read and write i/o to block devices.\nBe careful to use this only against free blocks.\nUsage:\n ./fiotest.sh /dev/mapper/mpathXX\n"
  exit 0
fi

## Check  input argument
if [ $# -eq 0 ]
  then
    echo -e "`basename $0` requires a block device as argument.\nUse -h or --help for example."
    exit 0
fi

## Parsing first arg for block device
block_dev=$1;

## Ask for confirmation
read -p "You are about to run read and WRITE i/o tests to block devices. Are you sure you want to continue [y/Y] ?  " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then

## IOPS:

## IOPS Block Random Reads:
sudo fio --filename=${block_dev} --direct=1 --rw=randread --bs=8k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1 --readonly
echo -e "\n---------------------------------\n---------------------------------\n---------------------------------\n"

## IOPS Block Sequential Reads:
sudo fio --filename=${block_dev} --direct=1 --rw=read --bs=8k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1 --readonly
echo -e "\n---------------------------------\n---------------------------------\n---------------------------------\n"

## IOPS Block RANDOM Read / Writes:
sudo fio --filename=${block_dev} --direct=1 --rw=randrw --bs=8k --ioengine=libaio --iodepth=256 --runtime=120 --numjobs=4 --time_based --group_reporting --name=iops-test-job --eta-newline=1
echo -e "\n---------------------------------\n---------------------------------\n---------------------------------\n"

## THROUGHPUT:

## Throughput Block Random Reads:
sudo fio --filename=${block_dev} --direct=1 --rw=randread --bs=64k --ioengine=libaio --iodepth=64 --runtime=120 --numjobs=4 --time_based --group_reporting --name=throughput-test-job --eta-newline=1 --readonly
echo -e "\n---------------------------------\n---------------------------------\n---------------------------------\n"

##  Throughput Block Sequential Reads:
sudo fio --filename=${block_dev} --direct=1 --rw=read --bs=64k --ioengine=libaio --iodepth=64 --runtime=120 --numjobs=4 --time_based --group_reporting --name=throughput-test-job --eta-newline=1 --readonly
echo -e "\n---------------------------------\n---------------------------------\n---------------------------------\n"

## *** Caution Workload Write ***
## Throughput Block RANDOM Read / Writes:
sudo fio --filename=${block_dev} --direct=1 --rw=randrw --bs=64k --ioengine=libaio --iodepth=64 --runtime=120 --numjobs=4 --time_based --group_reporting --name=throughput-test-job --eta-newline=1
echo -e "\n---------------------------------\n---------------------------------\n---------------------------------\n"

## LATENCY:

## Latency Block Random Reads:
sudo fio --filename=${block_dev} --direct=1 --rw=randread --bs=8k --ioengine=libaio --iodepth=1 --numjobs=1 --time_based --group_reporting --name=readlatency-test-job --runtime=120 --eta-newline=1 --readonly
echo -e "\n---------------------------------\n---------------------------------\n---------------------------------\n"

## *** Caution Workload Write ***
## Latency Block Random Read/Write:
sudo fio --filename=${block_dev} --direct=1 --rw=randrw --bs=8k --ioengine=libaio --iodepth=1 --numjobs=1 --time_based --group_reporting --name=rwlatency-test-job --runtime=120 --eta-newline=1 --readonly

fi
