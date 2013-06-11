// Reset Score

#if defined sic_resetscore_included
    #endinput
#endif

#define sic_resetscore_included

#include <fun>
#include <cstrike>

public sic_resetscore_plugin_init()
{
	register_clcmd("say /r",          "sic_resetscore_cmd_resetscore")
	register_clcmd("say /rs",         "sic_resetscore_cmd_resetscore")
	register_clcmd("say /res",        "sic_resetscore_cmd_resetscore")
	register_clcmd("say /rds",        "sic_resetscore_cmd_resetscore")
	register_clcmd("say /ras",        "sic_resetscore_cmd_resetscore")
	register_clcmd("say /resetscore", "sic_resetscore_cmd_resetscore")
	register_clcmd("say rs",          "sic_resetscore_cmd_resetscore")
	register_clcmd("say res",         "sic_resetscore_cmd_resetscore")
	register_clcmd("say resetscore",  "sic_resetscore_cmd_resetscore")

	register_dictionary("sic_resetscore.txt")
}

public sic_resetscore_cmd_resetscore(id)
{
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);

	#if defined sic_announce_included
		sic_announce(id, "%L", LANG_PLAYER, "YOUR_STATS_ARE_RESET")
	#elseif
		client_print(id, print_chat, "%L", LANG_PLAYER, "YOUR_STATS_ARE_RESET")
	#endif

	return PLUGIN_HANDLED
}
