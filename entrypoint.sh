#!/bin/bash

service ssh start

N=$CLUSTER_NUMBER

# change slaves file
slaves=/opt/hadoop/etc/hadoop/slaves
hdfsite=/opt/hadoop/etc/hadoop/hdfs-site.xml
rm $slaves
for ((i=0;i<$N;i++))
do
	echo "hadoop-slave-${i}.hadoop" >> $slaves
done

datanode=`hostname |awk -F "-" '{print $2"-"$3}'`
hostname=`hostname -f`
if [[ $hostname == "hadoop-slave"* ]]; then
    sed -i "s/hdfs\/datanode/hdfs\/datanode\/${datanode}/g" $hdfsite
else
    echo $hostname
fi
echo "OK"

# start-all.sh
# start-dfs.sh
bash
tail -f /etc/ssh/sshd_config

exec "$@"
