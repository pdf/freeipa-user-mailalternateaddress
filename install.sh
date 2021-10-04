#!/bin/bash
set -e

if [ ! -d "/usr/share/ipa/ui/js" ]; then
	echo "Unable to detect FreeIPA JS path, manual installation required" 1>&2
	exit 1
fi

PYSRC="user_mailalternateaddress.py"
if [ -d /usr/lib/python[23].*/site-packages/ipaserver/plugins ] ; then
	for dir in /usr/lib/python[23].* ; do
		PYPATH="${dir}/site-packages/ipaserver/plugins"
		break
	done
	PYSRC="user_mailalternateaddress_4.6.py"
elif [ -d /usr/lib/python[23].*/dist-packages/ipaserver/plugins ] ; then
	for dir in /usr/lib/python[23].* ; do
		PYPATH="${dir}/dist-packages/ipaserver/plugins"
		break
	done
	PYSRC="user_mailalternateaddress_4.6.py"
elif [ -d /usr/lib/python[23].*/site-packages/ipalib/plugins ] ; then
	for dir in /usr/lib/python[23].* ; do
		PYPATH="${dir}/site-packages/ipalib/plugins"
		break
	done
elif [ -d /usr/lib/python[23].*/dist-packages/ipalib/plugins ] ; then
	for dir in /usr/lib/python[23].* ; do
		PYPATH="${dir}/dist-packages/ipalib/plugins"
		break
	done
else
	echo "Unable to detect FreeIPA python lib path, manual installation required" 1>&2
	exit 1
fi
JSPATH="/usr/share/ipa/ui/js/plugins/user_mailalternateaddress"

# Install files
sudo mkdir -p "${JSPATH}"
sudo cp -v "$(dirname $0)/user_mailalternateaddress.js" "${JSPATH}/"
sudo cp -v "$(dirname $0)/${PYSRC}" "${PYPATH}/user_mailalternateaddress.py"

# Update default user objectClasses
echo
echo "Please enter your kerberos admin credentials to update FreeIPA configuration"
kinit admin
objectClasses="$(ipa config-show --raw --all |grep ipaUserObjectClasses |awk '{print "--userobjectclasses="$2}' |tr '\n' ' ')"
echo "$objectClasses" | grep -i mailrecipient || ipa config-mod $objectClasses --userobjectclasses=mailrecipient

# Add objectClass to existing users
updateUsers() {
	baseDn="$(ipa config-show --raw --all |grep -e '^[[:space:]]*dn:' |sed -e 's#^[[:space:]]*dn: cn=ipaConfig,cn=etc,##g')"
	ldapsearch -Y GSSAPI -b "cn=users,cn=accounts,${baseDn}" -s one -LLL dn | while read line ; do
		if [ -n "$line" ] ; then
			echo -e "${line}\nchangetype: modify\nadd: objectclass\nobjectclass: mailRecipient\n\n" | ldapmodify -Y GSSAPI
		fi
	done
}

echo
read -n 1 -r -p "Enable aliases for existing users? [y/N] " REPLY
case $REPLY in
	[yY]) updateUsers ;;
esac

sudo systemctl restart ipa

[ -d ~/.cache/ipa ] && rm -rf ~/.cache/ipa
