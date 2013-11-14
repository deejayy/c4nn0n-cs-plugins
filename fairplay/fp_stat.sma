#if defined fp_stat_included
    #endinput
#endif

#define fp_stat_included

new c_weapons[33][]		= {"undef0", "P228", "undef2", "Scout", "He", "Xm1014", "C4", "Mac10", "Aug", "Smoke", "Elite", "5-7", "Ump45", "Sg550", "Galil", "Famas", "Usp", "Glock", "Awp", "Mp5", "M249", "M3", "M4A1", "Tmp", "G3SG1", "Flash", "Deagle", "Sg552", "Ak47", "Knife", "P90", "Vest", "VestH"}
new c_hitplaces[11][]	= {"Generic", "Head", "Chest", "Stomach", "Leftarm", "Rightarm", "Leftleg", "Rightleg", "8", "9", "10"}

new Float:g_hit[33];
new Float:g_kill[33];
new Float:g_death[33];
new Float:g_headhit[33];
new Float:g_headkill[33];
new Float:g_wallhit[33];
new Float:g_wallkill[33]

public plugin_init_stat()
{
	register_srvcmd("fp_stat",    "st_printstat");
	register_srvcmd("fp_logsync", "st_logsync");
	register_srvcmd("sic_ls",     "st_logsync");
}

public client_connect_stat(id)
{
	st_clearstat(id);
}

public client_disconnect_stat(id)
{
	new auth[33];
	get_user_authid(id, auth, charsmax(auth));

	if (!equal(auth, "BOT")) {
		new uid, time, Float:score;

		uid = get_user_userid(id);
		time = get_user_time(id);
		score = st_score(id);

		new serverid[16], sServerid[33];
		get_cvar_string(com_serverid_cvar, serverid, charsmax(serverid));
		db_quote_string(sServerid, charsmax(sServerid), serverid);

		db_silent_query("insert into sic_stat (stt_player_plr_id, stt_score, stt_kill, stt_kill_head, stt_kill_wall, stt_hit, stt_hit_head, stt_hit_wall, stt_death, stt_time) values ((select plr_id from sic_players left join sic_servers on plr_server_srv_id = srv_id where plr_uid = %d and srv_serverid = '%s' order by plr_connect desc limit 1), %.2f, %d, %d, %d, %d, %d, %d, %d, %d)",
			uid, sServerid, score, floatround(g_kill[id]), floatround(g_headkill[id]), floatround(g_wallkill[id]), floatround(g_hit[id]), floatround(g_headhit[id]), floatround(g_wallhit[id]), floatround(g_death[id]), time);
	}

	st_clearstat(id);
}

public st_clearstat(id)
{
	g_hit[id] = 0.0;
	g_kill[id] = 0.0;
	g_death[id] = 0.0;
	g_headhit[id] = 0.0;
	g_headkill[id] = 0.0;
	g_wallhit[id] = 0.0;
	g_wallkill[id] = 0.0;
}

public client_damage_stat(attacker, victim, damage, wpnindex, hitplace, ta)
{
	new v_health = get_user_health(victim);
	new visible = 0;

	g_hit[attacker]++;

	if (v_health < 0) {
		g_kill[attacker]++;
		g_death[victim]++;
	}

	if (wpnindex != CSW_HEGRENADE) {
		visible = vis_is_visible(attacker, victim);
		if (hitplace == 1) {
			g_headhit[attacker]++;
			if (v_health <= 0) {
				g_headkill[attacker]++;
			}
		}

		if (!visible) {
			g_wallhit[attacker]++;
			if (v_health <= 0) {
				g_wallkill[attacker]++;
			}
		}
	}

	log_message_user2(attacker, victim, "attacked", "with ^"%s^" (damage ^"%d^") (damage_armor ^"%d^") (health ^"%d^") (armor ^"%d^") (wall ^"%d^") (hitplace ^"%s^")", c_weapons[wpnindex], damage, 0, v_health, 0, visible ? 0 : 1, c_hitplaces[hitplace]);
	if (v_health <= 0) {
		log_message_user2(attacker, victim, "killed", "with ^"%s^" (wall ^"%d^") (hitplace ^"%s^")", c_weapons[wpnindex], visible ? 0 : 1, c_hitplaces[hitplace]);
	}
}

public Float:st_score(id)
{
	new Float:time = get_user_time(id) * 1.0;

	new Float:s_k  = maxf(g_kill[id], 10.0);
	new Float:s_d  = maxf(g_death[id], 3.0);
	new Float:s_t  = maxf(time, 60.0);
	new Float:s_hk = g_headkill[id];
	new Float:s_hs = g_headhit[id];
	new Float:s_wk = g_wallkill[id];
	new Float:s_ws = g_wallhit[id];

	new Float:score2 = 0.0
		+ xs_sqrt(s_k / s_d)
		+ (8.0 * s_hk + 3.0 * s_ws + 15.0 * s_wk) / s_k
		+ 45.0 * s_k / s_t
		+ s_wk / 3.0
		- floatpower(17.0 / s_k, 2.0)
		+ floatpower((500.0 + s_k) / 500.0, 2.0) * (s_hk / 150.0)
		+ floatpower(s_hs / s_k - 1.0, 2.0)
		- maxf(0.0, 6.0 - s_t / 60.0)
		- 1.0;

	return score2;
}

public Float:maxf(Float:a, Float:b)
{
	if (a > b) {
		return a;
	}
	return b;
}

// TODO st_printstat()
public st_printstat(id)
{
	new players[32], num_players = 1, i = 0;
	if (id > 0) {
		players[i] = id;
	} else {
		get_players(players, num_players);
	}
	for (i = 0; i < num_players; i++) {
		server_print("%d: %.2f", players[i], st_score(players[i]));
	}
}

public st_logsync()
{
	new players[32], num_players, id, time, cl_uid[8], ip[33], p_timeleft[9], p_hostname[65], Float:p_timelimit, map[33];

	get_cvar_string("amx_timeleft", p_timeleft, charsmax(p_timeleft));
	get_cvar_string("hostname", p_hostname, charsmax(p_hostname));
	get_mapname(map, charsmax(map));
	p_timelimit = get_cvar_float("mp_timelimit");
	log_message("Mapsync: (title ^"%s^") (ip ^"%s^") (map ^"%s^") (timeleft ^"%s^") (timelimit ^"%.2f^")", p_hostname, "", map, p_timeleft, p_timelimit);

	get_players(players, num_players);
	for (new i = 0; i < num_players; i++) {
		id = players[i];
		time = get_user_time(id);
		get_user_info(id, "cl_uid", cl_uid, charsmax(cl_uid));
		get_user_ip(id, ip, charsmax(ip), 1);
		log_message_user(id, "logsync (cl_uid ^"%s^") (ip ^"%s^") (port ^"%d^") (hit ^"%d^") (hit_head ^"%d^") (hit_wall ^"%d^") (kill ^"%d^") (kill_head ^"%d^") (kill_wall ^"%d^") (shot ^"%d^") (death ^"%d^") (time ^"%d^")",
			cl_uid, ip, 0, floatround(g_hit[id]), floatround(g_headhit[id]), floatround(g_wallhit[id]), floatround(g_kill[id]), floatround(g_headkill[id]), floatround(g_wallkill[id]), 0, floatround(g_death[id]), time);
	}
}
