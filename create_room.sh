#!/bin/sh
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
NORMAL=$(tput sgr0)
SCREEN_W=$(tput cols)
SCREEN_H=$(tput lines)
col=$SCREEN_W

read_conf()
{
	TMP=$(sed -s '=' $1 |grep $2 > /tmp/askme)
	TMP=$(sed -i "/#/d" /tmp/askme)
	TMP=$(cut -f 2 -d '=' /tmp/askme | sed -e 's/^[[:space:]]*//')
	rm -f /tmp/askme
	OUTPUT=$TMP
}
init_db()
{
	read_conf $1 DB_SERVER
	DB_SERVER=$OUTPUT
	
	read_conf $1 DB_PORT
	DB_PORT=$OUTPUT
	
	read_conf $1 DB_USER
	DB_USER=$OUTPUT
	
	read_conf $1 DB_PASS
	DB_PASS=$OUTPUT
	
	read_conf $1 DB_NAME
	DB_NAME=$OUTPUT
	
	read_conf $1 TB_NAME
	TB_NAME=$OUTPUT
	
	read_conf $1 FL_MIN
	FL_MIN=$OUTPUT
	
	read_conf $1 FL_MAX
	FL_MAX=$OUTPUT
	
	read_conf $1 FL_SEP
	FL_SEP=$OUTPUT
	
	read_conf $1 FL_SWAP
	FL_SWAP=$OUTPUT
	
	read_conf $1 FL_DIGIT
	FL_DIGIT=$OUTPUT
	
	read_conf $1 RM_MIN
	RM_MIN=$OUTPUT
	
	read_conf $1 RM_MAX
	RM_MAX=$OUTPUT
}
if [ -z "$1" ] ; then
	printf '\n%s%s%s\n\n' "$RED" ">>> Please Insert configuration path. <<<" "$NORMAL"
else
	init_db $1
	printf '\n%s%s%s\n\n' "$YELLOW" ">>> type 'save' for create table Example 'create.sh config.conf save' <<<" "$NORMAL"
	SH_DIGIT="%"$FL_DIGIT"g"
	printf '%s%s%s\n' "$GREEN" "Create Table Start..." "$NORMAL"
	for((m_fl=$FL_MIN;m_fl<=$FL_MAX;m_fl++)) do
		if [ $FL_SWAP -eq 1 ] ; then		
			if [ $m_fl -lt $FL_SEP ] ; then
				for m_room in $(seq -f "$SH_DIGIT" $RM_MIN $RM_MAX) 
				do 
					insertdb=$((m_fl*10))$m_room
					#echo $m_room
					m_pass=$((1 + RANDOM % 10000))
					echo "SQL = "$insertdb " m_pass = " $m_pass
					if [ "$2" = "save" ] ; then
						mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e 'INSERT INTO '$TB_NAME' (id,username,attribute,op,value) VALUES (NULL,'$insertdb',"Cleartext-Password",":=",'$m_pass');'
					fi
				done
			else
				for m_room in $(seq -f "$SH_DIGIT" $RM_MIN $RM_MAX)	
				do 
					insertdb=$m_fl$m_room
					#echo $m_room
					m_pass=$((1 + RANDOM % 10000))
					echo "SQL = "$insertdb " m_pass = " $m_pass
					if [ "$2" = "save" ] ; then
						mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e 'INSERT INTO '$TB_NAME' (id,username,attribute,op,value) VALUES (NULL,'$insertdb',"Cleartext-Password",":=",'$m_pass');'
					fi
				done
			fi
		else
			for m_room in $(seq -f "$SH_DIGIT" $RM_MIN $RM_MAX)	
			do 
				insertdb=$m_fl$m_room
				m_pass=$((1 + RANDOM % 10000))
				echo "SQL = "$insertdb " m_pass = " $m_pass
				if [ "$2" = "save" ] ; then
					mysql --user=$DB_USER --password=$DB_PASS $DB_NAME -e 'INSERT INTO '$TB_NAME' (id,username,attribute,op,value) VALUES (NULL,'$insertdb',"Cleartext-Password",":=",'$m_pass');'
				fi
			done
		fi
	done
	if [ "$2" = "save" ] ; then
		chmod -x $0
	else
		printf '\n%s%s%s\n\n' "$YELLOW" ">>> type 'save' for create table Example 'create.sh config.conf save' <<<" "$NORMAL"
	fi
fi
