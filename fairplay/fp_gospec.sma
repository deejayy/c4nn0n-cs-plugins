#if defined spc_gospec_included
    #endinput
#endif

#define spc_gospec_included

public plugin_init_gospec()
{
	register_clcmd("say /spec", "spc_cmd_gospec");
	register_clcmd("say /away", "spc_cmd_gospec");
	register_clcmd("say /back", "spc_cmd_goback");
}

public spc_cmd_gospec(id)
{
	cs_set_user_team(id, CS_TEAM_SPECTATOR);
	user_kill(id, 1);

	ann_announce(id, "Visszaallni a /back paranccsal tudsz!");

	return PLUGIN_CONTINUE;
}

public spc_cmd_goback(id)
{
	new pnum1, pnum2, players[32];

	if (cs_get_user_team(id) == CS_TEAM_SPECTATOR) {
		get_players(players, pnum1, "e", "TERRORIST");
		get_players(players, pnum2, "e", "CT");
		cs_set_user_team(id, pnum1 < pnum2 ? CS_TEAM_T : CS_TEAM_CT);

		if (is_plugin_loaded("CSDM Mod")) {
			client_cmd(id, "say /respawn");
		}
	}

	return PLUGIN_CONTINUE;
}
