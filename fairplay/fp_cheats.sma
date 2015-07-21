#if defined fp_cheats_included
    #endinput
#endif

#define fp_cheats_included

new g_knifespeed[33][2]
new Float:g_viewangles[33][2]
new Float:g_nospread[33]

new g_nospread_treshold = 1500;

public plugin_init_cheats()
{
	register_cvar("nsd", "0");

	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "cht_knifespeed", true);
	set_task(1.0, "cht_task_knifespeed", 74202, "", 0, "b", 0);
	set_task(1.0, "cht_task_scorecheck", 74203, "", 0, "b", 0);

	register_forward(FM_CmdStart, "cht_cmdstart");
}

public cht_cmdstart(id, uc_handle)
{
	new auth[33];
	get_user_authid(id, auth, charsmax(auth));

	if (!equal(auth, "BOT")) {
		new Float:p_viewangles[3];
		new p_button = get_uc(uc_handle, UC_Buttons);
		get_uc(uc_handle, UC_ViewAngles, p_viewangles);

		if (g_viewangles[id][0] == p_viewangles[0] && g_viewangles[id][1] == p_viewangles[1]) {
			g_nospread[id] *= 0.9;
		} else {
			if ((p_button & IN_JUMP) + (p_button & IN_LEFT) + (p_button & IN_RIGHT) == 0) {
				g_nospread[id] += 1;
			}
		}

		if (get_cvar_num("nsd")) {
			// server_print("%f, %d, %d, %d, %d, %d", g_nospread[id], p_button & IN_JUMP, p_button & IN_LEFT, p_button & IN_RIGHT, p_button & IN_JUMP + p_button & IN_LEFT + p_button & IN_RIGHT, (p_button & IN_JUMP) + (p_button & IN_LEFT) + (p_button & IN_RIGHT));
			log_message("%f, %f", p_viewangles[0], p_viewangles[1]);
		}

		if (g_nospread[id] > g_nospread_treshold && g_nospread[id] <= g_nospread_treshold + 1) {
			log_message_user(id, "say ^"--- c4-nospread: %f^"", g_nospread[id]);
			g_nospread[id] = 0.0;
			new uid = get_user_userid(id);
			server_cmd("fp_punish #%d ^"Nem cheatelsz tobbet. (5)^"", uid);
		}

		g_viewangles[id][0] = p_viewangles[0];
		g_viewangles[id][1] = p_viewangles[1];
	}
}

public client_connect_cheats(id)
{
	g_viewangles[id][0] = 0.0;
	g_viewangles[id][1] = 0.0;
	g_nospread[id]      = 0.0;
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
