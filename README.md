Author : Bilery Zoo(bilery.zoo@gmail.com)
Date   : 2021-04-24


           　　 　 　　　　 　 |＼＿/|
           　　 　 　　　　 　 | ・x・ |
           　　 ＼＿＿＿＿＿／　　　 |
           　　 　 |　　　 　　　　　|
           　　　　＼　　　　　 　ノ
           　（（（　(/￣￣￣￣(/ヽ)


About engineering:

    This project(scripts) is to easily deploy a castrated MySQL InnoDB Cluster.
	The castration is mainly represented at
	
		① without MySQL Shell
		② perform a "one PRIMARY - one SECONDARY" group replication without fault-tolerance
	
	See also
		https://dev.mysql.com/doc/refman/8.0/en/mysql-innodb-cluster-introduction.html
		https://dev.mysql.com/doc/refman/8.0/en/group-replication-fault-tolerance.html
	
	The cluster is to deploy at IBM Cloud VM(CentOS8 Linux) set menu 'BL2.2x8'(2 CPUs & 8G MEMs).
	Packages to be installed are
	
		mysql-8.0.24-linux-glibc2.12-x86_64
		mysql-router-8.0.24-linux-glibc2.12-x86_64


Script usage:

	0. mysql_v8.0generic_glibc_deploy.sh
	
		deploy mysql service
		
	1. mysqlrouter_v8.0generic_glibc_deploy.sh
	
		deploy mysqlrouter
		
	2. async_replication_set.sh
	
		set asynchronous M-S replication(deprecated)

    3. group_replication_set.sh

		set synchronous group replication(recommended)


Your attention:

	Each of scripts should optionally do the parameters resetting at mascot area before executing
