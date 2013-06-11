// Cheat detecting

#if defined sic_cheats_included
    #endinput
#endif

#define sic_cheats_included

new g_knifespeed[33][2]

public sic_cheats_plugin_init()
{
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "sic_cheats_knifespeed", true)
	set_task(1.0, "sic_cheats_tsk_knifespeed", 74202, "", 0, "b", 0)
	set_task(20.0, "sic_cheats_check_score", 74203, "", 0, "b", 0)
}

public sic_cheats_client_connect(id)
{
	g_knifespeed[id][0] = 0
	g_knifespeed[id][1] = 0
}

public sic_cheats_knifespeed(p_wep)
{
	new p_id
	p_id = get_pdata_cbase(p_wep, 41, 4)

	g_knifespeed[p_id][0]++
}

public sic_cheats_tsk_knifespeed()
{
	new max = get_maxplayers(), lstr[128]

	for (new i = 0; i <= max; i++) {
		if (g_knifespeed[i][0] != g_knifespeed[i][1]) {
			if (g_knifespeed[i][0] - g_knifespeed[i][1] > 9) {
				new pi[playerinfo]
				sic_userinfo_fetchall(i, pi)
				sic_userinfo_logstring_b(pi, lstr, charsmax(lstr))
				if (!(sic_userlist_get_flags(GF_CL_UID, pi[pi_cl_uid]) & PF_BLOCKED)) {
					log_message("%s cheats (type ^"knifespeed^") (freq ^"%d^")", lstr, g_knifespeed[i][0] - g_knifespeed[i][1])
					sic_userlist_setaccess(i, PF_MUTED | PF_BLOCKED, 0, BAN_TYPE_PERMANENT)
				}
			}
		}
		g_knifespeed[i][1] = g_knifespeed[i][0]
	}
}

public sic_cheats_check_score()
{
	new pi[playerinfo], players[32], num_players, lstr[128]

	get_players(players, num_players, "")
	for (new i = 0; i < num_players; i++) {
		sic_userinfo_fetchall(players[i], pi)
		if (pi[pi_kills] > 15 && pi[pi_score] > 13.9 && pi[pi_time] > 60) {
			if (!(sic_userlist_get_flags(GF_CL_UID, pi[pi_cl_uid]) & PF_BLOCKED)) {
				sic_userinfo_logstring_b(pi, lstr, charsmax(lstr))
				log_message("%s cheats (type ^"multiple^") (score ^"%.2f^")", lstr, pi[pi_score])
				sic_userlist_setaccess(players[i], PF_MUTED | PF_BLOCKED, 0, BAN_TYPE_PERMANENT)
			}
		}
	}
}
