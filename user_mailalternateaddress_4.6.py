from ipaserver.plugins.user import user
from ipalib.parameters import Str
from ipalib import _

user.takes_params += (
    Str('mailalternateaddress*',
        cli_name='email_alias',
        label=_('Email alias'),
    ),
)
