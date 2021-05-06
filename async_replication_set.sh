#!/usr/bin/env bash
# author  : Bilery Zoo(bilery.zoo@gmail.com)
# date    : 2021-04-24
# program : set GTID-based MySQL classic asynchronous "one master - one slave" replication (deprecated)


# *******************************************************************************
#
#            　　 　 　　　　 　 |＼＿/|
#            　　 　 　　　　 　 | ・x・ |
#            　　 ＼＿＿＿＿＿／　　　 |
#            　　 　 |　　　 　　　　　|    ニャンー ニャンー
#            　　　　＼　　　　　 　ノ　
#            　（（（　(/￣￣￣￣(/ヽ)
#
# *** this script is for reference and acts as a place-holding file ***
# *** from MySQL 5.7.17 and 8.0 GA versions official high availability solution of group replication released ***
# *** it is highly advisable to deploy the most advanced synchronous group replication at online transaction service ***
#
# User-definition Variables Area
#
host_master=192.168.67.128
user_master=root
password_master=1024

host_slave=192.168.67.129
user_slave=root
password_slave=1024

user_replication=repl
password_replication=1024
#
# *******************************************************************************


# MASTER
mysql --host=${host_master} --user=${user_master} --password=${password_master} --execute="CREATE USER '${user_replication}'@'%' IDENTIFIED BY '${password_replication}'; GRANT REPLICATION SLAVE ON *.* TO '${user_replication}'@'%';" --connect-expired-password > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo 'MASTER OK'
else
    echo 'MASTER GG'
    exit 1
fi


# SLAVE
mysql --host=${host_slave} --user=${user_slave} --password=${password_slave} --execute="CHANGE MASTER TO MASTER_HOST = '${host_master}', MASTER_PORT = 3306, MASTER_USER = '${user_replication}', MASTER_PASSWORD = '${password_replication}', MASTER_AUTO_POSITION = 1, GET_MASTER_PUBLIC_KEY = 1; START SLAVE;" --connect-expired-password > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo 'SLAVE OK'
else
    echo 'SLAVE GG'
    exit 1
fi
