#!/usr/bin/env bash
# author  : Bilery Zoo(bilery.zoo@gmail.com)
# date    : 2021-04-24
# program : install & init & launch MySQL V-8.0.24-linux-glibc at CentOS 8


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
server_id=1024
root_password=1024
base_dir=/usr/local/mysql
local_host=$(ip address | grep -E '([[:digit:]]{1,3}[.]){3}([[:digit:]]{1,3})' | grep -v '127.0.0.1' | awk '{ print $2 }' | awk -F / '{ print $1 }')
#
# *******************************************************************************


function localize_os_setting() {
    systemctl start firewalld && firewall-cmd --add-port=3306/tcp --permanent > /dev/null && systemctl restart firewalld.service
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


function create_cnf_file() {
    if [ -e /etc/my.cnf ]; then
        mv /etc/my.cnf /etc/my.cnf.default
    fi
    (
        cat << EOF
# author    : xinle.zhao@healthcare-tech.co.jp
# create_ts : 2021-03-31


# This option file(--defaults-file) is generally configured for MySQL 8.0.24
# Hardware relevant args are set based on IBM Cloud VM(CentOS8) 'BL2.2x8' set menu (2 CPUs & 8G MEMs)


[client]
default-character-set = utf8mb4
socket	= ${base_dir}/data/mysql.sock


[mysql]
no-auto-rehash
default-character-set = utf8mb4


[mysqld]
    ## file system
basedir = ${base_dir}
datadir = ${base_dir}/data
socket	= ${base_dir}/data/mysql.sock
mysqlx_socket = ${base_dir}/data/mysqlx.sock
pid-file = ${base_dir}/data/mysql.pid
log_error = ${base_dir}/data/mysql.err
log-bin = ${base_dir}/data/mysql-bin
relay_log = ${base_dir}/data/mysql-relay-bin
log-bin-index = ${base_dir}/data/mysql-bin.index
relay_log_index = ${base_dir}/data/mysql-relay-bin.index
slow_query_log_file = ${base_dir}/data/mysql-slow.log
    ## server general config
back_log = 1024
skip_name_resolve = ON
log_timestamps = SYSTEM
log_error_verbosity = 3
lower_case_table_names = 1
default-time-zone = '+9:00'
character_set_server = utf8mb4
plugin-load-add = mysql_clone.so
	## timeout args
wait_timeout = 600
interactive_timeout = 600
mysqlx_wait_timeout = 600
mysqlx_interactive_timeout = 600
	## slow log
log_output = FILE
slow_query_log = ON
long_query_time = 10
log_slow_admin_statements = ON
log_queries_not_using_indexes = ON
log_throttle_queries_not_using_indexes = 24
	## correlation args
open_files_limit = 65535
table_open_cache = 65535
innodb_open_files = 65535
table_definition_cache = 65535
# InnoDB general config
	## hardware rely(CPUs & MEMs)
innodb_purge_threads = 6
innodb_page_cleaners = 6
innodb_read_io_threads = 6
innodb_write_io_threads = 6
innodb_buffer_pool_size = 6G
innodb_buffer_pool_instances = 6
innodb_io_capacity = 4096
innodb_io_capacity_max = 8192
innodb_print_all_deadlocks = ON
innodb_log_buffer_size = 64M
innodb_log_file_size = 2G
innodb_log_files_in_group = 3
innodb_data_file_path = ibdata0:1G;ibdata1:1G;ibdata2:1G;ibdata3:1G:autoextend
	## async replication
server-id = ${server_id}
report_host = ${local_host}
gtid_mode = ON
binlog_format = ROW
relay_log_purge = ON
log_slave_updates = ON
relay_log_recovery = ON
slave_parallel_workers = 6
enforce_gtid_consistency = ON
slave_transaction_retries = 256
slave_preserve_commit_order = ON
slave_parallel_type = LOGICAL_CLOCK
binlog_expire_logs_seconds = 604800
explicit_defaults_for_timestamp = ON
transaction_write_set_extraction = XXHASH64
binlog_transaction_dependency_tracking = WRITESET
	## high availability config
sync_binlog = 1
innodb_doublewrite = ON
innodb_flush_method = O_DIRECT
innodb_flush_log_at_trx_commit = 1
binlog_group_commit_sync_delay = 0
binlog_group_commit_sync_no_delay_count = 0
	## PMM
performance_schema = ON
innodb_monitor_enable = all
performance-schema-instrument = 'statement/%=ON'
performance-schema-consumer-statements-digest = ON


[mysqldump]
quick

EOF
    ) > /etc/my.cnf
    if [ $? -eq 0 ]; then
        echo 'Create option file /etc/my.cnf success'
        return 0
    else
        echo 'Create option file /etc/my.cnf failed'
        exit 1
    fi
}


function prepare_mysql_install() {
    yum -y install libaio ncurses-compat-libs > /dev/null 2>&1
    if [ ! -e mysql-8.0.24-linux-glibc2.12-x86_64.tar.xz ]; then
        wget https://cdn.mysql.com//Downloads/MySQL-8.0/mysql-8.0.24-linux-glibc2.12-x86_64.tar.xz > /dev/null 2>&1
    fi
    if [ $? -eq 0 ]; then
        tar -xf mysql-8.0.24-linux-glibc2.12-x86_64.tar.xz
        mv mysql-8.0.24-linux-glibc2.12-x86_64 ${base_dir}
    else
        echo 'Download MySQL source package failed'
        exit 1
    fi
    grep mysql /etc/group > /dev/null
    if [ $? -eq 1 ]; then
        groupadd mysql
    fi
    grep mysql /etc/passwd > /dev/null
    if [ $? -eq 1 ]; then
        useradd -g mysql mysql
    fi
    grep "${base_dir}/bin" /etc/profile > /dev/null
    if [ $? -eq 1 ]; then
        echo -e "\n# MySQL PATH\nexport PATH=${base_dir}/bin:$PATH\n" >> /etc/profile && source /etc/profile
    fi
    if [ $? -eq 0 ]; then
        echo 'Prepare MySQL install success'
        return 0
    else
        echo 'Prepare MySQL install failed'
        exit 1
    fi
}


function launch_mysql_service() {
    mkdir -p ${base_dir}/data
    chown -R mysql:mysql ${base_dir}
    chmod o+x ${base_dir}/bin
    chmod 750 ${base_dir}/data
    mysqld --defaults-file=/etc/my.cnf --initialize --user=mysql
    if [ $? -eq 0 ]; then
        echo 'Init mysqld service success'
    else
        echo 'Init mysqld service failed'
        exit 1
    fi
    mysql_ssl_rsa_setup --defaults-file=/etc/my.cnf --user=mysql
    cp -p ${base_dir}/support-files/mysql.server /etc/init.d/mysqld
    chmod +x /etc/init.d/mysqld
    grep 'service mysqld start' /etc/rc.d/rc.local > /dev/null
    if [ $? -eq 1 ]; then
        echo -e 'service mysqld start\n' >> /etc/rc.d/rc.local
        chmod +x /etc/rc.d/rc.local
    fi
    service mysqld start > /dev/null 2>&1
    ps aux | grep mysqld | grep -v grep > /dev/null
    if [ $? -eq 0 ]; then
        echo 'Launch MySQL service success'
        return 0
    else
        echo 'Launch MySQL service failed'
        exit 1
    fi
}


function change_root_password() {
    init_password=$(grep 'root@localhost' ${base_dir}/data/mysql.err | awk '{ print $NF }' | sed -ne '1p')
    mysql --user=root --password="${init_password}" --execute="SET SQL_LOG_BIN = OFF; ALTER USER 'root'@'localhost' IDENTIFIED BY '${root_password}';" --connect-expired-password > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Change user password 'root'@'localhost' success"
        return 0
    else
        echo "Change user password 'root'@'localhost' failed"
        exit 1
    fi
}


function main() {
	localize_os_setting && create_cnf_file && prepare_mysql_install && launch_mysql_service && change_root_password
}


main
