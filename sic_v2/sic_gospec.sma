// Reset Score

#if defined sic_gospec_included
    #endinput
#endif

#define sic_gospec_included

public sic_gospec_plugin_init()
{
	register_clcmd("say /spec", "sic_gospec_cmd_gospec")
	register_clcmd("say /away", "sic_gospec_cmd_gospec")
	register_clcmd("say /back", "sic_gospec_cmd_goback")

	register_dictionary("sic_gospec.txt")
}

public sic_gospec_cmd_gospec(id)
{
	cs_set_user_team(id, CS_TEAM_SPECTATOR)
	user_kill(id, 1)

	#if defined sic_announce_included
		sic_announce(id, "%L", LANG_PLAYER, "BACK_FROM_SPEC")
	#elseif
		client_print(id, print_chat, "%L", LANG_PLAYER, "BACK_FROM_SPEC")
	#endif

	return PLUGIN_CONTINUE
}

public sic_gospec_cmd_goback(id)
{
	new pnum1, pnum2, players[32]

	if (cs_get_user_team(id) == CS_TEAM_SPECTATOR) {
		get_players(players, pnum1, "e", "TERRORIST")
		get_players(players, pnum2, "e", "CT")
		cs_set_user_team(id, pnum1 < pnum2 ? CS_TEAM_T : CS_TEAM_CT)

		if (is_plugin_loaded("CSDM Mod")) {
			client_cmd(id, "say respawn")
		}
	}

	return PLUGIN_CONTINUE
}
