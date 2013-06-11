// Reset Score

#if defined sic_nsrank_included
    #endinput
#endif

#define sic_nsrank_included

#include <fun>
#include <cstrike>

public sic_nsrank_plugin_init()
{
	register_clcmd("say /rank", "sic_nsrank_cmd_nsrank")
	register_clcmd("say /info", "sic_nsrank_cmd_nsinfo")
	set_task(180.0, "sic_nsrank_info", 74205, "", 0, "b", 0)
}

public sic_nsrank_cmd_nsrank(id)
{
	new auth[33]
	get_user_authid(id, auth, charsmax(auth))
	if (contain(auth, "_ID_LAN") > 0) {
		show_motd(id, "rank.html")
	}
}

public sic_nsrank_cmd_nsinfo(id)
{
	new auth[33]
	get_user_authid(id, auth, charsmax(auth))
	if (contain(auth, "_ID_LAN") > 0) {
		show_motd(id, "nsinfo.html")
	}
}

public sic_nsrank_info()
{
	new auth[33], players[32], num_players

	get_players(players, num_players, "")
	for (new i = 0; i < num_players; i++) {
		get_user_authid(players[i], auth, charsmax(auth))
		if (contain(auth, "_ID_LAN") > 0) {
			sic_announce(players[i], "Legujabb CS 1.6! Letoltes: http://csdm-hu.sytes.net ! /info")
		}
	}
}
