#!/bin/bash
DATE=`date +%Y-%m-%d`
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0)
SCREEN_W=$(tput cols)
SCREEN_H=$(tput lines)
col=$SCREEN_W

check_os_vendor()
{
	if [ -f /etc/redhat-release ] ; then
		TMP=`cat /etc/redhat-release |grep "release 7" > /dev/null && echo "1"`
        	if [ "$TMP" = "1" ] ; then
            		os_name="rhel7"
			printf '%s%s%s\n' "$GREEN" "Operation System is $os_name" "$NORMAL" 
		fi
	else
		printf '%s%s%s\n' "$RED" "Can not install this OS" "$NORMAL"
		exit 0
	fi
}
check_previous()
{
	if [ -f /etc/askme.conf ] ; then
		printf '%s%s%s\n' "$YELLOW" "Found previous config file in /etc/askme.conf" "$NORMAL"
        	read -r -p "Overwrite ? [yes/no] " conf_overwrite
		case "$conf_overwrite" in 
			[yY][eE][sS]|[yY])
				cp -f .askme.conf /etc/
				;;
			*)
				mv /etc/askme.conf /etc/askme"$DATE".backup
				printf '%s%s%s\n' "$GREEN" "config has been backup." "$NORMAL"
				;;
		esac
	fi
}
create_log()
{
	if [ -d /var/log/askme ] ; then
		cd /var/log
		tar -czvf askme_"$DATE".tar.gz askme
		rm -rf /var/log/askme
		mkdir /var/log/askme
		mv askme_"$DATE".tar.gz /var/log/askme
		printf "%s%s%s\n" "$YELLOW" "Backup old log successfull." "$NORMAL"
	else
		mkdir /var/log/askme
		printf '%s%s%s\n' "$GREEN" "Created folder for log." "$NORMAL"
	fi
}
preconfig()
{
	yum install -y mysql-devel net-tools epel-release sed
	yum install -y tar 
	yum install -y cpuid
}
install()
{
	openssl enc -aes-256-cbc -d -in askme.tar.gz |tar -xz
	if [ -f ./askme-radius ] ; then

		if [ ! -d /opt/askme ] ; then
			mkdir /opt/askme
		fi
		
		chmod +x ./askme-radius	
		chmod -x $0
	else
		printf '%s%s%s\n' "$RED" "Install Software Fail." "$NORMAL"
	fi
}

makeautorun()
{
	auto_run=$(cat /etc/rc.local |grep askme-radius)
	if [ -z "$auto_run" ] ; then
		echo "/etc/init.d/askme-radius &" >> /etc/rc.local  
		chmod +x /etc/rc.local
	fi
}

check_os_vendor
if [ $os_name == "rhel7" ] ; then
	check_previous
	preconfig
	install
	create_log
	makeautorun
fi

