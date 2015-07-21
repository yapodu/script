#!/bin/bash

### Yapodu
### Ryo Tamura

USER="ypadmin"
GROUP="yapodu"
PASSWORD="YPSP@ssw0rd"
DATE=`date +%Y%m%d%H%M`
USER_DIR=~${USER}
CREATE_LOG=create-ypadmin.sh.log

USER_SSH_DIR=".ssh"
USER_SSH_AUTHKEY="authorized_keys"
USER_SSH_AUTHPATH=${USER_SSH_DIR}/${USER_SSH_AUTHKEY}

SSHD_CONFIG="/etc/ssh/sshd_config"

SUDOERS="/etc/sudoers"

# グループ作成
grep ${GROUP} /etc/group

if [ "$?" -eq 0 ]
then 
	echo "yapodu group not create ${DATE}" >> ~ypadmin/${CREATE_LOG}
else
	groupadd -g 1046 ${GROUP} 
fi


# ユーザー存在確認と作成
grep ${USER} /etc/passwd

if [ "$?" -eq 0 ]
then 
	echo "ypadmin not create ${DATE}" >> ~ypadmin/${CREATE_LOG}
else
	useradd -g ${GROUP} -u 1046 ${USER}
	echo ${USER}:${PASSWORD} | chpasswd
	echo "ypadmin create ${DATE}" >> ~ypadmin/${CREATE_LOG}
fi

# ユーザーSSHディレクトリ設定
if [ -e ~ypadmin/${USER_SSH_DIR} ] ; then 
	if [ -e ~ypadmin/${USER_SSH_AUTHPATH} ] ; then
		cp ~ypadmin/${USER_SSH_AUTHPATH} ~ypadmin/${USER_SSH_AUTHPATH}.${DATE}
		cp ${USER_SSH_AUTHPATH} ~ypadmin/${USER_SSH_AUTHPATH}
		echo "Change Authorized_keys ${DATE}" >> ~ypadmin/${CREATE_LOG}

	else 
		cp ${USER_SSH_AUTHPATH} ~ypadmin/${USER_SSH_AUTHPATH}
		echo "Copy Authorized_keys ${DATE}" >> ~ypadmin/${CREATE_LOG}
	fi
else
	cp -pr ${USER_SSH_DIR} ~ypadmin/			
	echo "Copy .ssh dir  ${DATE}" >> ~ypadmin/${CREATE_LOG}
fi

chmod 700 ~ypadmin/${USER_SSH_DIR}
chmod 600 ~ypadmin/${USER_SSH_AUTHPATH}
chown ${USER} ~ypadmin/${USER_SSH_DIR}
chown ${USER} ~ypadmin/${USER_SSH_AUTHPATH}

# sshd設定変更

grep  ^AllowUsers ${SSHD_CONFIG} | grep ${USER}

if [ "$?" -eq 0 ]
then 
	echo "not change sshd_config AllowUsers ${DATE}" >> ~ypadmin/${CREATE_LOG}
else
	grep ^AllowUsers ${SSHD_CONFIG} 

	if [ "$?" -eq 0 ]
	then
		sed -i.${DATE} -e "/^AllowUsers/ s/$/ ${USER}/g"  ${SSHD_CONFIG}
		echo "add sshd_config AllowUsers ${DATE}" >> ~ypadmin/${CREATE_LOG}
		# sshd reload 
		service sshd reload
	else
		echo "do not use sshd_config AllowUsers ${DATE}" >> ~ypadmin/${CREATE_LOG}
	fi

fi


# sudoers設定変更
# シェルスクリプト内で visudo を実行する方法もあるが /etc/sudoers の編集で実施する

grep  ${USER} ${SUDOERS}

if [ "$?" -eq 0 ]
then 
	echo "not change sudoers ${DATE}" >> ~ypadmin/${CREATE_LOG}
else
	cp -p ${SUDOERS} ${SUDOERS}.${DATE}
	echo "ypadmin ALL=(ALL) NOPASSWD:ALL" >> ${SUDOERS}
	echo "add ypadmin ${SUDOERS} ${DATE}" >> ~ypadmin/${CREATE_LOG}
fi


exit



