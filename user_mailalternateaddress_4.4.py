from ipaserver.plugins.user import user
from ipalib import Str, _

user.takes_params += (
    Str('mailalternateaddress*',
        cli_name='email_alias',
        label=_('Email alias'),
    ),
)
