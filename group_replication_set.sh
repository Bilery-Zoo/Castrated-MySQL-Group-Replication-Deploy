#!/usr/bin/env bash
# author  : Bilery Zoo(bilery.zoo@gmail.com)
# date    : 2021-04-24
# program : set MySQL official high availability solution of synchronous group replication (recommended)


# *******************************************************************************
#
#            　　 　 　　　　 　 |＼＿/|
#            　　 　 　　　　 　 | ・x・ |
#            　　 ＼＿＿＿＿＿／　　　 |
#            　　 　 |　　　 　　　　　|    ニャンー ニャンー
#            　　　　＼　　　　　 　ノ　
#            　（（（　(/￣￣￣￣(/ヽ)
#
# User-definition Variables Area
#
    # 1 to act as bootstrap instance and init PRIMARY server
    # 0 to init SECONDARY server
is_bootstrap=1

super_user=root
super_password=1024
repl_user=repl
repl_password=1024

mgr_port=33033
    # each digit represents a instance in accordance with orders of other instance relevant args
    # 1 stands for RW(read-write) instance
    # 0 stands for RO(read-only) instance
    # 0 of suffix part act as placeholders
primary_mode_string=10000000
    # among hyphens each number part represent a `server-id' of a instance in accordance with orders of other instance relevant args
    # 0000 act as placeholder
server_id_string=1024-1025-0000

group_replication_local_address="192.168.67.139:${mgr_port}"
group_replication_ip_allowlist="192.168.67.128/24,192.168.67.139/24"
    # must be a valid UUID type
    # prefix part represent read/&write mode of each instances
    # middle part represent `server-id' unique option of each instances
    # suffix part consist of each instances' IP suffix
group_replication_group_name="${primary_mode_string}-${server_id_string}-867128867139"
group_replication_group_seeds="192.168.67.128:${mgr_port},192.168.67.139:${mgr_port}"
#
# *******************************************************************************


function localize_os_setting() {
    firewall-cmd --add-port=${mgr_port}/tcp --permanent > /dev/null && systemctl restart firewalld.service
    if [ $? -eq 0 ]; then
        echo 'Localize OS setting success'
    else
        echo 'Localize OS setting failed'
    fi
    return 0
}


function config_mgr_option() {
    sed -i '/high availability config/i \
    ## group replication\
plugin_load_add = group_replication.so\
group_replication_start_on_boot = OFF\
group_replication_bootstrap_group = OFF\
group_replication_recovery_get_public_key = ON\
group_replication_consistency = BEFORE_ON_PRIMARY_FAILOVER\
disabled_storage_engines = '\''MyISAM,BLACKHOLE,FEDERATED,ARCHIVE,MEMORY'\''\
group_replication_local_address = '\'''${group_replication_local_address}''\''\
group_replication_ip_allowlist = '\'''${group_replication_ip_allowlist}''\''\
group_replication_group_name = '\'''${group_replication_group_name}''\''\
group_replication_group_seeds = '\'''${group_replication_group_seeds}''\''
' /etc/my.cnf
    if [ $? -eq 0 ]; then
        service mysqld restart &> /dev/null
        if [ $? -eq 0 ]; then
            echo 'Config MGR option success'
            return 0
        else
            echo 'Config MGR option failed'
            exit 1
        fi
    fi
}


function create_recovery_channel() {
    mysql --user=${super_user} --password=${super_password} --connect-expired-password &> /dev/null <<EOF
SET SQL_LOG_BIN = OFF;
CREATE USER '${repl_user}'@'%' IDENTIFIED BY '${repl_password}';
GRANT BACKUP_ADMIN, REPLICATION SLAVE ON *.* TO '${repl_user}'@'%';
FLUSH PRIVILEGES;
CHANGE REPLICATION SOURCE TO SOURCE_USER = '${repl_user}', SOURCE_PASSWORD = '${repl_password}' FOR CHANNEL 'group_replication_recovery';
EOF
    if [ $? -eq 0 ]; then
        echo 'Create recovery channel success'
        return 0
    else
        echo 'Create recovery channel failed'
        exit 1
    fi
}


function start_group_replication() {
    if   [ ${is_bootstrap} -eq 0 ]; then
            mysql --user=${super_user} --password=${super_password} --connect-expired-password &> /dev/null <<EOF
START GROUP_REPLICATION;
EOF
    elif [ ${is_bootstrap} -eq 1 ]; then
            mysql --user=${super_user} --password=${super_password} --connect-expired-password &> /dev/null <<EOF
SET GLOBAL group_replication_bootstrap_group = ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group = OFF;
EOF
    else
        echo 'Type of parameter @is_bootstrap is boolean and only accepts 0 or 1'
        exit 127
    fi
    if [ $? -eq 0 ]; then
        echo -e 'Start group replication success\n'
        mysql --user=${super_user} --password=${super_password} --execute='SELECT * FROM `performance_schema`.`replication_group_members`\G' --connect-expired-password 2> /dev/null
        echo ''
        return 0
    else
        echo 'Start group replication failed'
        exit 1
    fi
}


function set_mgr_boot() {
    sed -i 's/group_replication_start_on_boot = OFF/group_replication_start_on_boot = ON/' /etc/my.cnf
    if [ $? -eq 0 ]; then
        echo 'Set MGR boot success'
        return 0
    else
        echo 'Set MGR boot failed'
        exit 1
    fi
}


function main() {
    localize_os_setting && config_mgr_option && create_recovery_channel && start_group_replication && set_mgr_boot
}


main
