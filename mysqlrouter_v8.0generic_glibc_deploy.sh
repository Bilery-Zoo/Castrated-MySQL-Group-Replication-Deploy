#!/usr/bin/env bash
# author  : Bilery Zoo(bilery.zoo@gmail.com)
# date    : 2021-04-24
# program : install & init & launch MySQL Router V-8.0.24-linux-glibc2.12 at CentOS 8


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
base_dir=/usr/local/mysqlrouter
router_port=33066
router_host=$(ip address | grep -E '([[:digit:]]{1,3}[.]){3}([[:digit:]]{1,3})' | grep -v '127.0.0.1' | awk '{ print $2 }' | awk -F / '{ print $1 }')
router_destination=192.168.67.128:3306,192.168.67.139:3306
#
# *******************************************************************************


function localize_os_setting() {
    firewall-cmd --add-port=${router_port}/tcp --permanent > /dev/null && systemctl restart firewalld.service
    local exit_code_add_port=$?
    timedatectl set-timezone Asia/Tokyo && timedatectl set-local-rtc off && timedatectl set-ntp yes
    local exit_code_set_tz=$?
    if [ ${exit_code_add_port} -eq 0 ] && [ ${exit_code_set_tz} -eq 0 ]; then
        echo 'Localize OS setting success'
    else
        echo 'Localize OS setting failed'
    fi
    return 0
}


function create_conf_file() {
    if [ -e /etc/mysqlrouter.conf ]; then
        mv /etc/mysqlrouter.conf /etc/mysqlrouter.conf.default
    fi
    (
        cat << EOF
# author  : Bilery Zoo(bilery.zoo@gmail.com)
# date    : 2021-04-24


# This option file(--config) is generally configured for MySQL Router 8.0.24-linux-glibc2.12
# It is official recommended to install this proxy middleware with application deploying server together and set 'bind_address' as localhost
# castrated(save money) MySQL "one PRIMARY - one SECONDARY" group replication with "first available" routing strategy performs


[DEFAULT]
logging_folder = ${base_dir}/log
pid_file = ${base_dir}/mysqlrouter.pid
plugin_folder = ${base_dir}/lib/mysqlrouter


[logger]
level = INFO
filename = mysqlrouter.log
timestamp_precision = second


[routing:failover]
routing_strategy = first-available
bind_port = ${router_port}
bind_address = ${router_host}
destinations = ${router_destination}

EOF
    ) > /etc/mysqlrouter.conf
    if [ $? -eq 0 ]; then
        echo 'Create option file /etc/mysqlrouter.conf success'
        return 0
    else
        echo 'Create option file /etc/mysqlrouter.conf failed'
        exit 1
    fi
}


function prepare_mysqlrouter_install() {
    yum -y install protobuf mysql-libs > /dev/null 2>&1
    if [ ! -e mysql-router-8.0.24-linux-glibc2.12-x86_64.tar.xz ]; then
        wget https://dev.mysql.com/get/Downloads/MySQL-Router/mysql-router-8.0.24-linux-glibc2.12-x86_64.tar.xz > /dev/null 2>&1
    fi
    if [ $? -eq 0 ]; then
        tar -xf mysql-router-8.0.24-linux-glibc2.12-x86_64.tar.xz
        mv mysql-router-8.0.24-linux-glibc2.12-x86_64 ${base_dir}
    else
        echo 'Download mysqlrouter source package failed'
        exit 1
    fi
    grep mysqlrouter /etc/group > /dev/null
    if [ $? -eq 1 ]; then
        groupadd mysqlrouter
    fi
    grep mysqlrouter /etc/passwd > /dev/null
    if [ $? -eq 1 ]; then
        useradd -g mysqlrouter mysqlrouter
    fi
    grep "${base_dir}/bin" /etc/profile > /dev/null
    if [ $? -eq 1 ]; then
        echo -e "\n# MySQL Router PATH\nexport PATH=${base_dir}/bin:$PATH\n" >> /etc/profile && source /etc/profile
    fi
    if [ $? -eq 0 ]; then
        echo 'Prepare mysqlrouter install success'
        return 0
    else
        echo 'Prepare mysqlrouter install failed'
        exit 1
    fi
}


function launch_mysqlrouter_service() {
    chown -R mysqlrouter:mysqlrouter ${base_dir}
    wget https://raw.githubusercontent.com/mysql/mysql-server/8.0/scripts/systemd/mysqlrouter.service.in > /dev/null 2>&1 &&\
    mv mysqlrouter.service.in /usr/lib/systemd/system/mysqlrouter.service &&\
    sed -i 's/@MYSQLROUTER_USER@/mysqlrouter/g ; s#^ExecStart.*$#ExecStart='${base_dir}'/bin/mysqlrouter -c /etc/mysqlrouter.conf# ; /# Start main service/a PIDFile='${base_dir}'/mysqlrouter.pid' /usr/lib/systemd/system/mysqlrouter.service
    if [ $? -eq 0 ]; then
        echo 'Create service file /usr/lib/systemd/system/mysqlrouter.service success'
    else
        echo 'Create service file /usr/lib/systemd/system/mysqlrouter.service failed'
        exit 1
    fi
    restorecon -R /usr/local/mysqlrouter
    restorecon /usr/lib/systemd/system/mysqlrouter.service
    systemctl start mysqlrouter > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo 'Launch mysqlrouter service success'
        return 0
    else
        echo 'Launch mysqlrouter service failed'
        exit 1
    fi
}


function init_mysqlrouter_service() {
    systemctl enable mysqlrouter > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo 'Init mysqlrouter service success'
        return 0
    else
        echo 'Init mysqlrouter service failed'
        exit 1
    fi
}


function main() {
	localize_os_setting && create_conf_file && prepare_mysqlrouter_install && launch_mysqlrouter_service && init_mysqlrouter_service
}


main
