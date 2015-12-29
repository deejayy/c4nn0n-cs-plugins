#if defined fp_cheats_included
    #endinput
#endif

#define fp_cheats_included

new g_knifespeed[33][2]
new g_aimbot[33]
new Float:g_shootvec[33][5]
new Float:g_viewangles[33][2]
new Float:g_nospread[33]

new g_nospread_treshold = 1500;

public plugin_init_cheats()
{
	register_cvar("nsd", "0");

	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "cht_knifespeed", true);
	set_task( 1.0, "cht_task_knifespeed", 74202, "", 0, "b", 0);
	set_task( 1.0, "cht_task_scorecheck", 74203, "", 0, "b", 0);
	set_task(30.0, "cht_task_aimbot",     74206, "", 0, "b", 0);

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

		if (p_button & IN_ATTACK) {
			// server_print("%f, %d, %d, %d, %d, %d", g_nospread[id], p_button & IN_JUMP, p_button & IN_LEFT, p_button & IN_RIGHT, p_button & IN_JUMP + p_button & IN_LEFT + p_button & IN_RIGHT, (p_button & IN_JUMP) + (p_button & IN_LEFT) + (p_button & IN_RIGHT));
			// log_message("%f, %f", p_viewangles[0], p_viewangles[1]);
			new p_wep = get_user_weapon(id);
			if (p_wep != 4 && p_wep != 29) {
				g_shootvec[id][0] = g_shootvec[id][1];
				g_shootvec[id][1] = g_shootvec[id][2];
				g_shootvec[id][2] = g_shootvec[id][3];
				g_shootvec[id][3] = g_shootvec[id][4];
				g_shootvec[id][4] = floatabs(floatabs(g_viewangles[id][1]) - floatabs(p_viewangles[1]));
				new Float:p_shootavg = (g_shootvec[id][0] + g_shootvec[id][1] + g_shootvec[id][2] + g_shootvec[id][3] + g_shootvec[id][4]) / 5;

				if (p_shootavg > 10) {
					g_aimbot[id]++;
					if (p_shootavg > 30) {
						g_aimbot[id] += 10 - (g_aimbot[id] % 10);
					}
					if (g_aimbot[id] > 0 && g_aimbot[id] % 40 == 0) {
						log_message_user(id, "say ^"--- c4-aimbot: %d^"", g_aimbot[id]);
					}
				}

				// com_putsd("logs/nsd.log", "%d^t%f^t%f^t%f^t%f", uid, g_viewangles[id][1], p_viewangles[1], floatabs(floatabs(g_viewangles[id][1]) - floatabs(p_viewangles[1])), p_shootavg);
			}
		}

		if (g_nospread[id] > g_nospread_treshold && g_nospread[id] <= g_nospread_treshold + 1) {
			// log_message_user(id, "say ^"--- c4-nospread: %f^"", g_nospread[id]);
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
	g_aimbot[id]        = 0;
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

public cht_task_aimbot()
{
	new max = get_maxplayers();

	for (new i = 0; i <= max; i++) {
		g_aimbot[i] = maxint(0, g_aimbot[i] - 10);
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
