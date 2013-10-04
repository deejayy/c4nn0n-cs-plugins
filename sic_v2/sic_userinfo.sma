// User info

#if defined sic_userinfo_included
    #endinput
#endif

#define sic_userinfo_included

#include <cstrike>

#define stripkeys_l 40
new c_stripkeys[stripkeys_l][] = {"_ah", "ah", "autobind", "bn_patch", "bottomcolor", "cheater", "cl_dlmax", "cl_lb", "dm", "dzuid", "friends", "gad", "ghosts", "_gm", "_gmprof", "lac_id", "_lang", "lang", "lefthand", "mID", "model", "mp_cnet", "mp_net", "nameacc", "_ndmf", "_ndmh", "_ndms", "nick_pass", "quality", "rhlg", "_rpgm_cfg", "scanner", "source_models", "src", "status_monitor", "timepass", "topcolor", "translit", "vgui_menu", "xredir"}

new c_teamnames[CsTeams][] = { "", "T", "CT", "SPEC" }
new c_teamnames_short[CsTeams][] = { "", "T", "CT", "SPEC" }
new c_weapons[33][]		= {"undef0", "P228", "undef2", "Scout", "He", "Xm1014", "C4", "Mac10", "Aug", "Smoke", "Elite", "5-7", "Ump45", "Sg550", "Galil", "Famas", "Usp", "Glock", "Awp", "Mp5", "M249", "M3", "M4A1", "Tmp", "G3SG1", "Flash", "Deagle", "Sg552", "Ak47", "Knife", "P90", "Vest", "VestH"}
new c_hitplaces[11][]	= {"Generic", "Head", "Chest", "Stomach", "Leftarm", "Rightarm", "Leftleg", "Rightleg", "8", "9", "10"}

new g_user_kills[33]
new g_user_deaths[33]
new g_user_hs[33]
new g_user_hk[33]
new g_user_ws[33]
new g_user_wk[33]

new g_mapname[33]

new g_lastMessage[255]

enum _:playerinfo
{
	pi_name[33],
	pi_auth[33],
	pi_ip[17],
	pi_ipport[25],
	pi_cl_uid[17],
	pi_sid[32],
	pi_userid,
	pi_kills,
	pi_deaths,
	pi_health,
	pi_armor,
	pi_money,
	pi_weapon,
	pi_clip,
	pi_ammo,
	pi_flags,
	pi_ping,
	pi_loss,
	pi_time,
	pi_team,
	pi_hs,
	pi_hk,
	pi_ws,
	pi_wk,
	pi_okills,
	pi_odeaths,
	Float:pi_score
}

public sic_userinfo_plugin_init()
{
	get_mapname(g_mapname, charsmax(g_mapname))

	register_concmd("sic_info", "sic_userinfo_list", ADMIN_RCON, "- userlista reloaded")
	register_concmd("sic_ls", "sic_userlist_logsync",   ADMIN_RCON, "- irchez logsync")

	OrpheuRegisterHook(OrpheuGetFunction("SV_DropClient"), "SV_DropClient");
}

public Float:sic_userinfo_calc_score(pi[])
{
	// TODO: check for correct calculation
	new Float:p_score

	new Float:s_p  = get_playersnum() * 1.0
	new Float:s_k  = pi[pi_kills] > 0 ? pi[pi_kills] * 1.0 : 1.0
	new Float:s_kn = pi[pi_kills] * 1.0
	new Float:s_d  = pi[pi_deaths] > 0 ? pi[pi_deaths] * 1.0 : 1.0
	new Float:s_t  = pi[pi_time] * 1.0 + 1.0
	new Float:s_h  = pi[pi_hk] * 1.0
	new Float:s_w  = pi[pi_ws] * 1.0
	new Float:s_wk = pi[pi_wk] * 1.0

	p_score += xs_sqrt(s_kn / s_d)	// kill / death			12/1 = 12			12/4 = 3		nagyobb az arany, annal jobb a jatekos
	p_score += (s_h / s_k) * 5.0	// hs / kill * 5		2/12*5 = 0.83		9/12*5 = 3.75	tobb a headshot,
	p_score += s_kn / (s_t/60.0)	// kill / (time / 60)	12/(130/60) = 5.54	12/(20/60) = 36	gyorsabban ol,
	p_score += 2.0 - s_p / 12.0		// 2 - players/12		2-5/12 = 1.58		2-19/12 = 0.41	kevesebb a jatekos,
	p_score += s_w / s_k * 3.0		// wallhit / kill * 3	3/12*3 = 0.75		12/12*3 = 3		tobb a falon keresztul lott
	p_score += s_wk / 3.0 - 1.0		// wallkill / 3 - 1		1/3-1 = -0.66		5/3-1 = 0.66	tobb a falon keresztul kill
	p_score -= floatpower(17.0 / s_k, 2.0)			// 17 / kill			17/12 = 1.4			17/80 = 0.2125	korrekcios szam, ki kell vonni

	return p_score
}

public sic_userinfo_fetchall(id, pi[])
{
	new p_ip[17]
	pi[pi_userid] = get_user_userid(id)

	get_user_name   (id, pi[pi_name], charsmax(pi[pi_name]))
	get_user_authid (id, pi[pi_auth], charsmax(pi[pi_auth]))

	if (id) {
		get_user_ip(id, p_ip, charsmax(p_ip), 1)
		if (equal(p_ip, "127.0.0.1")) {
			pi[pi_ip] = ""
			pi[pi_ipport] = ""
		} else {
			copy(pi[pi_ip], charsmax(pi[pi_ip]), p_ip)
			get_user_ip(id, pi[pi_ipport], charsmax(pi[pi_ipport]), 0)
		}
	
		get_user_info(id, sic_uniq_key, pi[pi_cl_uid], charsmax(pi[pi_cl_uid]))
		get_user_info(id, "*sid", pi[pi_sid], charsmax(pi[pi_sid]))
		get_user_ping(id, pi[pi_ping], pi[pi_loss])

		if (is_user_connected(id)) {
			pi[pi_time]       = get_user_time(id)
			// TODO: if these values are get at connect, crashes the server, why?
			if (pi[pi_time] > 5) {
				pi[pi_team]       = _:cs_get_user_team(id)
				pi[pi_okills]     = get_user_frags(id)
				pi[pi_odeaths]    = cs_get_user_deaths(id)
				pi[pi_money]      = cs_get_user_money(id)
			}
			pi[pi_armor]      = get_user_armor(id)
			pi[pi_flags]      = get_user_flags(id)
			pi[pi_health]     = get_user_health(id)
			pi[pi_weapon]     = get_user_weapon(id, pi[pi_clip], pi[pi_ammo])

			pi[pi_kills]      = g_user_kills[id]
			pi[pi_deaths]     = g_user_deaths[id]
			pi[pi_hs]         = g_user_hs[id]
			pi[pi_hk]         = g_user_hk[id]
			pi[pi_ws]         = g_user_ws[id]
			pi[pi_wk]         = g_user_wk[id]

			pi[pi_score]      = _:sic_userinfo_calc_score(pi)
		} else {
			pi[pi_team] = _:CS_TEAM_UNASSIGNED
		}
	}
}

public sic_userinfo_client_connect(id)
{
	g_user_kills[id] = 0
	g_user_deaths[id] = 0
	g_user_hs[id] = 0
	g_user_hk[id] = 0
	g_user_ws[id] = 0
	g_user_wk[id] = 0

	if (!(is_user_bot(id))) {
		message_begin(MSG_ALL, get_user_msgid("TeamInfo"), {0, 0, 0}, id)
		write_byte(id)
		write_string("UNASSIGNED")
		message_end()
	}
}

public sic_userinfo_stripinfo(id)
{
	for (new i = 0; i < stripkeys_l; i++) {
		client_cmd(id, "setinfo %s ^"^"", c_stripkeys[i])
	}
	client_cmd(id, "setinfo cl_lc ^"1^"")
	client_cmd(id, "setinfo cl_lw ^"1^"")
}

public sic_userinfo_logstring(id, logstring[], logstring_length)
{
	new pi[playerinfo]
	sic_userinfo_fetchall(id, pi)
	if (!id) {
		pi[pi_auth] = "BOT"
	}
	sic_userinfo_logstring_b(pi, logstring, logstring_length)
}

public sic_userinfo_logstring_b(pi[], logstring[], logstring_length)
{
	format(logstring, logstring_length, "^"%s<%d><%s><%s>^"", pi[pi_name], pi[pi_userid], pi[pi_auth], c_teamnames[CsTeams:pi[pi_team]])
}

public sic_userinfo_client_damage(attacker, victim, damage, wpnindex, hitplace, ta) {
	new pi_a[playerinfo], pi_v[playerinfo], p_wall
	sic_userinfo_fetchall(attacker, pi_a)
	sic_userinfo_fetchall(victim, pi_v)

	if (pi_v[pi_health] <= 0) {
		g_user_kills [attacker]++;
		g_user_deaths[victim  ]++;
		if (g_user_kills[attacker] == 16) {
			sic_cheats_check_score()
		}
	}

	if (wpnindex != CSW_HEGRENADE) {
		if (!sic_visible_is_visible(attacker, victim)) {
			p_wall = 1
			g_user_ws[attacker]++
			if (pi_v[pi_health] <= 0) {
				g_user_wk[attacker]++
			}
		}
		if (hitplace == 1) {
			g_user_hs[attacker]++
			if (pi_v[pi_health] <= 0) {
				g_user_hk[attacker]++
			}
		}
	}

	new lstr_a[129], lstr_v[129]
	sic_userinfo_logstring(attacker, lstr_a, charsmax(lstr_a))
	sic_userinfo_logstring(victim, lstr_v, charsmax(lstr_v))

	log_message("%s attacked %s with ^"%s^" (damage ^"%d^") (damage_armor ^"%d^") (health ^"%d^") (armor ^"%d^") (wall ^"%d^") (hitplace ^"%s^")", lstr_a, lstr_v, c_weapons[wpnindex], damage, 0, pi_v[pi_health], pi_v[pi_armor], p_wall, c_hitplaces[hitplace])
	if (pi_v[pi_health] <= 0) {
		log_message("%s killed %s with ^"%s^" (wall ^"%d^") (hitplace ^"%s^")", lstr_a, lstr_v, c_weapons[wpnindex], p_wall, c_hitplaces[hitplace])
	}
}

public sic_userinfo_list(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		sic_userinfo_printlist()
		sic_userinfo_printmap()
	}
}

public sic_userinfo_listheader(header[], len)
{
	new tmpl[128]

	format(tmpl, charsmax(tmpl), "#%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s", "%5s", "%5s",   "%32s",        "%-4s", "%-4s", "%-4s", "%-4s", "%-4s", "%-4s", "%-4s", "%20s", "%8s",        "%-4s", "%-4s", "%-4s", "%-4s", "%-7s",   "%-4s", "%22s",    "%-8s")
	format(header, len, tmpl,                                                                    "ID", "Score", "Player name", "Kill", "Dead", "HS",   "HK",   "WS",   "WK",   "Team", "Auth", sic_uniq_key, "Ping", "Loss", "Hp",   "Armr", "Weapon", "Time", "IP:Port", "Flags")
}

public sic_userinfo_listrow(pi[], row[], len)
{
	new tmpl[128], p_scorestr[9]

	if (pi[pi_kills] > 10) {
		format(p_scorestr, charsmax(p_scorestr), "%.2f", pi[pi_score])
	} else {
		p_scorestr = "0.00"
	}
	format(tmpl, charsmax(tmpl), "#%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s", "%-5d",       "%-5s",     "%32s",        "%4d",       "%4d",          "%4d",     "%4d",     "%4d",     "%4d",     "%4s",                                  "%20s",       "%8s",         "%4d",        "%4d",       "%4d",         "%4d",        "%-7s",                  "%4d",        "%22s",    "%d")
//	server_print(tmpl,                                                                           "ID",         "Score",    "Player name", "Kill",      "Dead",         "HS",      "HK",      "WS",      "WK",      "Team",                                 "Auth",       sic_uniq_key,  "Ping",       "Loss",      "Hp",          "Armr",       "Weapon",                "Time",       "IP:Port", "Flags")
	format(row, len, tmpl,                                                                       pi[pi_userid], p_scorestr, pi[pi_name],   pi[pi_kills], pi[pi_deaths], pi[pi_hs], pi[pi_hk], pi[pi_ws], pi[pi_wk], c_teamnames_short[CsTeams:pi[pi_team]], pi[pi_auth], pi[pi_cl_uid],  pi[pi_ping], pi[pi_loss], pi[pi_health], pi[pi_armor], c_weapons[pi[pi_weapon]], pi[pi_time], pi[pi_ip], pi[pi_flags])
}

stock sic_userinfo_printlist(id=0)
{
	new pi[playerinfo], players[32], num_players
	new tmpl[255]

	if (id) {
		sic_userinfo_fetchall(id, pi)
		sic_userinfo_listrow(pi, tmpl, charsmax(tmpl))
		log_message(tmpl)
	} else {
		sic_userinfo_listheader(tmpl, charsmax(tmpl))
		server_print(tmpl)

		get_players(players, num_players, "")
		for (new i = 0; i < num_players; i++) {
			sic_userinfo_fetchall(players[i], pi)
			sic_userinfo_listrow(pi, tmpl, charsmax(tmpl))
			server_print(tmpl)
		}
	}
}

public sic_userinfo_printmap()
{
	new p_map[33], p_nextmap[33], p_timeleft[17], Float:p_timelimit

	get_mapname(p_map, charsmax(p_map))
	get_cvar_string("amx_nextmap", p_nextmap, charsmax(p_nextmap))
	get_cvar_string("amx_timeleft", p_timeleft, charsmax(p_timeleft))
	p_timelimit = get_cvar_float("mp_timelimit")

	server_print("")
	server_print("Map: %s / Nextmap: %s / Timeleft: %s / Timelimit : %.2f", p_map, p_nextmap, p_timeleft, p_timelimit);
}

public sic_userlist_logsync_player(id)
{
	new pi[playerinfo], lstr[128]
	sic_userinfo_fetchall(id, pi)
	sic_userinfo_logstring_b(pi, lstr, charsmax(lstr))

	log_message("%s logsync (cl_uid ^"%s^") (ip ^"%s^") (port ^"%d^") (hit ^"%d^") (hit_head ^"%d^") (hit_wall ^"%d^") (kill ^"%d^") (kill_head ^"%d^") (kill_wall ^"%d^") (shot ^"%d^") (death ^"%d^") (time ^"%d^")", lstr, pi[pi_cl_uid], pi[pi_ip], 0, 0, 0, pi[pi_ws], pi[pi_kills], pi[pi_hk], pi[pi_wk], 0, pi[pi_deaths], pi[pi_time])
}

public sic_userlist_logsync() {
	new players[32], num_players, i, p_timeleft[9], p_hostname[65], Float:p_timelimit

	get_cvar_string("amx_timeleft", p_timeleft, charsmax(p_timeleft))
	get_cvar_string("hostname", p_hostname, charsmax(p_hostname))
	p_timelimit = get_cvar_float("mp_timelimit")
	log_message("Mapsync: (title ^"%s^") (ip ^"%s^") (map ^"%s^") (timeleft ^"%s^") (timelimit ^"%.2f^")", p_hostname, "", g_mapname, p_timeleft, p_timelimit)

	get_players(players, num_players, "")
	for (i=0; i<num_players; i++) {
		sic_userlist_logsync_player(players[i]);
	}
}

public OrpheuHookReturn:SV_DropClient(a, b, const szMessage[])
{
	copy(g_lastMessage, charsmax(g_lastMessage), szMessage);

	if(equal(szMessage, "Reliable channel overflowed")) {
		return OrpheuSupercede;
	}

	return OrpheuIgnored;
}

public sic_userinfo_client_disconnect(id)
{
	new pi[playerinfo], lstr[128];
	sic_userinfo_fetchall(id, pi);
	sic_userinfo_logstring_b(pi, lstr, charsmax(lstr));

	log_message("%s disconnected (reason ^"%s^")", lstr, g_lastMessage);

	sic_userinfo_printlist(id);
}
