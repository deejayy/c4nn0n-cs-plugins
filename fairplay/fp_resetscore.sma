#if defined rs_resetscore_included
    #endinput
#endif

#define rs_resetscore_included

#include <fun>
#include <cstrike>

public plugin_init_resetscore()
{
	register_clcmd("say /r",          "rs_cmd_resetscore")
	register_clcmd("say /rs",         "rs_cmd_resetscore")
	register_clcmd("say /res",        "rs_cmd_resetscore")
	register_clcmd("say /rds",        "rs_cmd_resetscore")
	register_clcmd("say /ras",        "rs_cmd_resetscore")
	register_clcmd("say /resetscore", "rs_cmd_resetscore")
	register_clcmd("say rs",          "rs_cmd_resetscore")
	register_clcmd("say res",         "rs_cmd_resetscore")
	register_clcmd("say resetscore",  "rs_cmd_resetscore")
}

public rs_cmd_resetscore(id)
{
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);

	ann_announce(id, "Nullaztad a statodat!");

	return PLUGIN_HANDLED;
}
