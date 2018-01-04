FROM openjdk:8u141-jdk-latest

# install software
RUN apt-get update && apt-get -qy dist-upgrade && apt-get install -qy rsync curl net-tools openssh-server openssh-client vim nfs-common

# install Hadoop
ARG HADOOP_VERSION=2.7.4
ENV HADOOP_VERSION=${HADOOP_VERSION}
ARG CLUSTER_NUMBER=5
ENV CLUSTER_NUMBER=${CLUSTER_NUMBER}
# RUN wget -c http://apache.crihan.fr/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -o /opt/hadoop-${HADOOP_VERSION}.tar.gz && \
COPY hadoop-2.7.4.tar.gz /opt/hadoop-2.7.4.tar.gz
RUN tar -zxvf /opt/hadoop-${HADOOP_VERSION}.tar.gz -C /opt/ && \
    ln -s /opt/hadoop-${HADOOP_VERSION} /opt/hadoop && \
    rm -rf /opt/hadoop-${HADOOP_VERSION}.tar.gz

# set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV PATH=/opt/hadoop/bin:/opt/hadoop/sbin:$PATH
RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
RUN echo "HADOOP_HOME=/opt/hadoop" >> /etc/environment
RUN echo "HIVE_HOME=/opt/hive" >> /etc/environment

# ssh without key
RUN ssh-keygen -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
COPY config/ssh_config /root/.ssh/config
RUN chmod 0600 /root/.ssh/authorized_keys && \
    chown root:root /root/.ssh/config

# Disable sshd authentication
RUN echo "root:root" | chpasswd
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# Setup
RUN mkdir -p /data/hdfs/namenode && \
    mkdir -p /data/hdfs/datanode && \
    mkdir -p $HADOOP_HOME/logs

COPY config/hadoop/* /opt/hadoop/etc/hadoop/

WORKDIR /opt/hadoop

# format namenode
RUN /opt/hadoop/bin/hdfs namenode -format

# SSH, hdfs://localhost:8020, HDFS namenode, HDFS Web browser, HDFS datanodes \
# HDFS secondary namenode, HDFS App Web browser
EXPOSE 22 8020 50020 50070 50075 50090 8088

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
# CMD [ "sh", "-c", "service ssh start; tail -f /etc/ssh/sshd_config"]

