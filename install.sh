#!/bin/sh
set -e

if [ ! -d "/usr/share/ipa/ui/js" ]; then
	echo "Unable to detect FreeIPA JS path, manual installation required" 1>&2
	exit 1
fi

if [ ! -d /usr/lib/python2.*/site-packages/ipalib/plugins -a ! -d /usr/lib/python2.*/dist-packages/ipalib/plugins ]; then
	echo "Unable to detect FreeIPA python lib path, manual installation required" 1>&2
	exit 1
fi

JSPATH="/usr/share/ipa/ui/js/plugins/user_mailalternateaddress"
if [ -d /usr/lib/python2.*/site-packages/ipalib/plugins ] ; then
	PYPATH="/usr/lib/python2.*/site-packages/ipalib/plugins"
else
	PYPATH="/usr/lib/python2.*/dist-packages/ipalib/plugins"
fi

sudo mkdir -p "${JSPATH}"
sudo cp -v $(dirname $0)/user_mailalternateaddress.js "${JSPATH}/"
sudo cp -v $(dirname $0)/user_mailalternateaddress.py ${PYPATH}/
