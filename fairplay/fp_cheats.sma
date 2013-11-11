#if defined fp_cheats_included
    #endinput
#endif

#define fp_cheats_included

new g_knifespeed[33][2]

public plugin_init_cheats()
{
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "cht_knifespeed", true)
	set_task(1.0, "cht_task_knifespeed", 74202, "", 0, "b", 0)
}

public client_connect_cheats(id)
{
	g_knifespeed[id][0] = 0
	g_knifespeed[id][1] = 0
}

public cht_knifespeed(p_wep)
{
	new p_id
	p_id = get_pdata_cbase(p_wep, 41, 4)

	g_knifespeed[p_id][0]++
}

public cht_task_knifespeed()
{
	new max = get_maxplayers()

	for (new i = 0; i <= max; i++) {
		if (g_knifespeed[i][0] != g_knifespeed[i][1]) {
			if (g_knifespeed[i][0] - g_knifespeed[i][1] > 9) {
				// TODO: log
				new uid = get_user_userid(i);
				server_cmd("fp_punish #%d ^"Nem cheatelsz tobbet. (2)^"", uid);
			}
		}
		g_knifespeed[i][1] = g_knifespeed[i][0]
	}
}

// TODO: score check