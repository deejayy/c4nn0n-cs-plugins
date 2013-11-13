#if defined fp_cheats_included
    #endinput
#endif

#define fp_cheats_included

new g_knifespeed[33][2]

public plugin_init_cheats()
{
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "cht_knifespeed", true);
	set_task(1.0, "cht_task_knifespeed", 74202, "", 0, "b", 0);
	set_task(1.0, "cht_task_scorecheck", 74203, "", 0, "b", 0);
}

public client_connect_cheats(id)
{
	g_knifespeed[id][0] = 0;
	g_knifespeed[id][1] = 0;
}

public cht_knifespeed(p_wep)
{
	new p_id;
	p_id = get_pdata_cbase(p_wep, 41, 4);

	g_knifespeed[p_id][0]++;
}

public cht_task_knifespeed()
{
	new max = get_maxplayers();

	for (new i = 0; i <= max; i++) {
		if (g_knifespeed[i][0] != g_knifespeed[i][1]) {
			if (g_knifespeed[i][0] - g_knifespeed[i][1] > 9) {
				new uid = get_user_userid(i);
				log_message_user(i, "cheats (type ^"knifespeed^") (freq ^"%d^")", g_knifespeed[i][0] - g_knifespeed[i][1]);
				server_cmd("fp_punish #%d ^"Nem cheatelsz tobbet. (2)^"", uid);
			}
		}
		g_knifespeed[i][1] = g_knifespeed[i][0];
	}
}

public cht_task_scorecheck()
{
	new players[32], num_players, id, uid, Float:score;
	get_players(players, num_players);
	for (new i = 0; i < num_players; i++) {
		id = players[i];
		uid = get_user_userid(id);
		score = st_score(id) - uf_get_immunity(id) * 1.8 - com_has_steam(id) * 1.2;
		if (score > 13.9) {
			log_message_user(id, "cheats (type ^"multiple^") (score ^"%.2f^")", score);
			server_cmd("fp_punish #%d ^"Nem cheatelsz tobbet. (3)^"", uid);
		}
	}
}
