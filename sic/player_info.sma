#define CLIENT_USER_ID		"cl_uid"

new g_headshots[33]
new g_frags[33]
new g_deaths[33]
new g_wallkills[33]
new g_wallhits[33]

new c_teams[4][]		= {"None", "T", "CT", "Spec"}
new c_weapons[33][]		= {"undef0", "P228", "undef2", "Scout", "He", "Xm1014", "C4", "Mac10", "Aug", "Smoke", "Elite", "5-7", "Ump45", "Sg550", "Galil", "Famas", "Usp", "Glock", "Awp", "Mp5", "M249", "M3", "M4A1", "Tmp", "G3SG1", "Flash", "Deagle", "Sg552", "Ak47", "Knife", "P90", "Vest", "VestH"}
new c_hitplaces[11][]	= {"Generic", "Head", "Chest", "Stomach", "Leftarm", "Rightarm", "Leftleg", "Rightleg", "8", "9", "10"}

enum e_si_struct {
	SIC_SI_MAX		= 0,
	SIC_SI_TOTAL	= 1,
	SIC_SI_CT		= 2,
	SIC_SI_T		= 3,
	SIC_SI_SPEC		= 4,
	SIC_SI_UNASS	= 5,
	SIC_SI_BOT		= 6,
}

enum e_pi_struct_int {
	SIC_PI_USER_ID		= 0,
	SIC_PI_FRAGS		= 1,
	SIC_PI_DEATHS		= 2,
	SIC_PI_HEALTH		= 3,
	SIC_PI_ARMOR		= 4,
	SIC_PI_MONEY		= 5,
	SIC_PI_WEAPON		= 6,
	SIC_PI_CLIP			= 7,
	SIC_PI_AMMO			= 8,
	SIC_PI_FLAGS		= 9,
	SIC_PI_PING			= 10,
	SIC_PI_LOSS			= 11,
	SIC_PI_TIME			= 12,
	SIC_PI_HEADSHOT		= 13,
	SIC_PI_TEAM			= 14,
	SIC_PI_WALLKILLS	= 15,
	SIC_PI_WALLHITS		= 16,
	SIC_PI_OFRAGS		= 17,
	SIC_PI_ODEATHS		= 18,
	SIC_PI_SCORE		= 19,
}

enum e_pi_struct_str {
	SIC_PI_NAME			= 0,
	SIC_PI_AUTH_ID		= 1,
	SIC_PI_IP			= 2,
	SIC_PI_IPONLY		= 3,
	SIC_PIE_CL_UID		= 4,
}

public player_info_int(id, num_players) {
	new p_player_info[e_pi_struct_int]

	get_user_ping	(id, p_player_info[SIC_PI_PING], p_player_info[SIC_PI_LOSS])
	p_player_info[SIC_PI_TEAM]		= _:cs_get_user_team	(id)
	p_player_info[SIC_PI_ARMOR]		= get_user_armor		(id)
	p_player_info[SIC_PI_FLAGS]		= get_user_flags		(id, 0)
	p_player_info[SIC_PI_HEALTH]	= get_user_health		(id)
	p_player_info[SIC_PI_TIME]		= get_user_time			(id, 1)
	p_player_info[SIC_PI_USER_ID]	= get_user_userid		(id)
	p_player_info[SIC_PI_WEAPON]	= get_user_weapon		(id, p_player_info[SIC_PI_CLIP], p_player_info[SIC_PI_AMMO])
	p_player_info[SIC_PI_MONEY]		= cs_get_user_money		(id)
	p_player_info[SIC_PI_DEATHS]	= sic_get_user_deaths	(id)
	p_player_info[SIC_PI_FRAGS]		= sic_get_user_frags	(id)
	p_player_info[SIC_PI_ODEATHS]	= get_user_deaths		(id)
	p_player_info[SIC_PI_OFRAGS]	= get_user_frags		(id)
	p_player_info[SIC_PI_HEADSHOT]	= sic_get_user_headshots(id)
	p_player_info[SIC_PI_WALLKILLS]	= sic_get_user_wallkills(id)
	p_player_info[SIC_PI_WALLHITS]	= sic_get_user_wallhits	(id)

	return p_player_info
}

public player_info_str(id, num_players) {
	new p_player_info[e_pi_struct_str][32]

	get_user_name	(id, p_player_info[SIC_PI_NAME], 31)
	get_user_authid	(id, p_player_info[SIC_PI_AUTH_ID], 31)
	get_user_info	(id, CLIENT_USER_ID, p_player_info[SIC_PIE_CL_UID], 31)
	get_user_ip		(id, p_player_info[SIC_PI_IP], 31, 0)
	get_user_ip		(id, p_player_info[SIC_PI_IPONLY], 31, 1)

	return p_player_info
}

// access to globals

public sic_get_user_headshots(id) {
	return g_headshots[id]
}

public sic_get_user_frags(id) {
	return g_frags[id]
}

public sic_get_user_deaths(id) {
	return g_deaths[id]
}

public sic_get_user_wallkills(id) {
	return g_wallkills[id]
}

public sic_get_user_wallhits(id) {
	return g_wallhits[id]
}

public sic_set_user_headshots(id, val) {
	g_headshots[id] = val
}

public sic_set_user_frags(id, val) {
	g_frags[id] = val
}

public sic_set_user_deaths(id, val) {
	g_deaths[id] = val
}

public sic_set_user_wallkills(id, val) {
	g_wallkills[id] = val
}

public sic_set_user_wallhits(id, val) {
	g_wallhits[id] = val
}

public sic_pi_client_putinserver(id) {
	sic_set_user_headshots	(id, 0)
	sic_set_user_frags		(id, 0)
	sic_set_user_deaths		(id, 0)
	sic_set_user_wallkills	(id, 0)
	sic_set_user_wallhits	(id, 0)
}

public sic_get_kdratio(kills, deaths, p_kdratio_s[], len) {
	new Float:p_kdratio

	if (deaths > 0) {
		p_kdratio = Float:kills/Float:deaths
	} else {
		p_kdratio = Float:kills
	}

	if (kills > 10 && p_kdratio > 2.0-(kills/1000.0)*3.0) {
		format(p_kdratio_s, len, "%2.2f", p_kdratio)
	} else {
		format(p_kdratio_s, 0, "")
	}
}

public sic_get_kmratio(kills, time, num_players, p_kmratio_s[], len) {
	new Float:p_kmratio = kills/((time+1.0)/60.0)

	if (kills > 10 && p_kmratio > 1.4+(num_players/6.66)) {
		format(p_kmratio_s, len, "%2.2f", p_kmratio)
	} else {
		format(p_kmratio_s, 0, "")
	}
}

public sic_get_hsratio(kills, headshots, p_hsratio_s[], len) {
	new Float:p_hsratio = headshots*1.0/kills*1.0

	if ( kills > 10 && p_hsratio > 0.5) {
		format(p_hsratio_s, len, "%1.2f", p_hsratio)
	} else {
		format(p_hsratio_s, 0, "")
	}
}

public Float:sic_calc_score(p_player_info_int[e_pi_struct_int], num_players) {
	new Float:p_score = 0.0

	new Float:s_p  = num_players * 1.0
	new Float:s_k  = p_player_info_int[SIC_PI_FRAGS] > 0 ? p_player_info_int[SIC_PI_FRAGS] * 1.0 : 1.0
	new Float:s_kn = p_player_info_int[SIC_PI_FRAGS] * 1.0
	new Float:s_d  = p_player_info_int[SIC_PI_DEATHS] > 0 ? p_player_info_int[SIC_PI_DEATHS] * 1.0 : 1.0
	new Float:s_t  = p_player_info_int[SIC_PI_TIME] * 1.0 + 1.0
	new Float:s_h  = p_player_info_int[SIC_PI_HEADSHOT] * 1.0
	new Float:s_w  = p_player_info_int[SIC_PI_WALLHITS] * 1.0
	new Float:s_wk = p_player_info_int[SIC_PI_WALLKILLS] * 1.0

	p_score += xs_sqrt(s_kn / s_d)	// kill / death			12/1 = 12			12/4 = 3		nagyobb az arany, annal jobb a jatekos
	p_score += (s_h / s_k) * 5.0	// hs / kill * 5		2/12*5 = 0.83		9/12*5 = 3.75	tobb a headshot,
	p_score += s_kn / (s_t/60.0)	// kill / (time / 60)	12/(130/60) = 5.54	12/(20/60) = 36	gyorsabban ol,
	p_score += 2.0 - s_p / 12.0		// 2 - players/12		2-5/12 = 1.58		2-19/12 = 0.41	kevesebb a jatekos,
	p_score += s_w / s_k * 3.0		// wallhit / kill * 3	3/12*3 = 0.75		12/12*3 = 3		tobb a falon keresztul lott
	p_score += s_wk / 3.0 - 1.0		// wallkill / 3 - 1		1/3-1 = -0.66		5/3-1 = 0.66	tobb a falon keresztul kill
	p_score -= floatpower(17.0 / s_k, 2.0)			// 10 / kill			10/12 = 0.8			10/80 = 0.125	korrekcios szam, ki kell vonni

	return p_score
}

public sic_get_score(p_player_info_int[e_pi_struct_int], num_players, p_score_s[], len) {
	new Float:p_score = sic_calc_score(p_player_info_int, num_players)

	if (p_player_info_int[SIC_PI_FRAGS] > 10) {
		format(p_score_s, len, "%2.2f", p_score)
	} else {
		format(p_score_s, 0, "")
	}
}

public sic_info_print() {
	new players[32], num_players, i
	new p_map[32], p_nextmap[32], p_timeleft[8], Float:p_timelimit, p_plstat[e_si_struct]
	new p_kdratio_s[8], p_kmratio_s[8], p_hsratio_s[8], p_score_s[8], p_name[32]

	server_print("#%5s %5s %20s %-4s %-4s %-5s %-4s %-4s %-5s %4s %4s %-5s %20s %8s %-4s %-4s %-4s %-4s %-7s %-4s %-4s %6s %6s %22s %-8s",
		"UsrId", "Score", "Player name", "Kill", "Dead", "K/D", "Head", "HS/K", "K/Min", "Wall", "WHit", "Team", "STEAM/AUTH ID", CLIENT_USER_ID, "Ping", "Loss", "Hp", "Armr", "Weapon", "Clip", "Ammo", "Money", "Time", "IP address:port", "Flags")

	new p_player_info_int[e_pi_struct_int]
	new p_player_info_str[e_pi_struct_str][32]

	get_players(players, num_players, "")
	p_plstat[SIC_SI_TOTAL] = num_players
	p_plstat[SIC_SI_MAX] = get_maxplayers()
	for (i=0; i<num_players; i++) {
		p_player_info_int = player_info_int(players[i], num_players)
		p_player_info_str = player_info_str(players[i], num_players)
		sic_get_kdratio(p_player_info_int[SIC_PI_FRAGS], p_player_info_int[SIC_PI_DEATHS], p_kdratio_s, sizeof(p_kdratio_s)-1)
		sic_get_kmratio(p_player_info_int[SIC_PI_FRAGS], p_player_info_int[SIC_PI_TIME], num_players, p_kmratio_s, sizeof(p_kmratio_s)-1)
		sic_get_hsratio(p_player_info_int[SIC_PI_FRAGS], p_player_info_int[SIC_PI_HEADSHOT], p_hsratio_s, sizeof(p_hsratio_s)-1)
		sic_get_score(p_player_info_int, num_players, p_score_s, charsmax(p_score_s))

		copy(p_name, 20, p_player_info_str[SIC_PI_NAME])

		switch (p_player_info_int[SIC_PI_TEAM]) {
			case 0: {
				p_plstat[SIC_SI_UNASS]++
			}
			case 1: {
				p_plstat[SIC_SI_T]++
			}
			case 2: {
				p_plstat[SIC_SI_CT]++
			}
			case 3: {
				p_plstat[SIC_SI_SPEC]++
			}
		}

		if (equal("BOT", p_player_info_str[SIC_PI_AUTH_ID])) {
			p_plstat[SIC_SI_BOT]++
		}

		server_print("#%-5d %5s %20s %4d %4d %5s %4d %4s %5s %4d %4d %5s %20s %8s %4d %4d %4d %4d %7s %4d %4d %6d %6d %22s %8d",
			p_player_info_int[SIC_PI_USER_ID],		p_score_s,	p_name,	p_player_info_int[SIC_PI_FRAGS],		p_player_info_int[SIC_PI_DEATHS],		p_kdratio_s,	p_player_info_int[SIC_PI_HEADSHOT],	p_hsratio_s, p_kmratio_s,
			p_player_info_int[SIC_PI_WALLKILLS],	p_player_info_int[SIC_PI_WALLHITS],	c_teams[p_player_info_int[SIC_PI_TEAM]],p_player_info_str[SIC_PI_AUTH_ID],	p_player_info_str[SIC_PIE_CL_UID],		p_player_info_int[SIC_PI_PING],			p_player_info_int[SIC_PI_LOSS],		p_player_info_int[SIC_PI_HEALTH],
			p_player_info_int[SIC_PI_ARMOR],		c_weapons[p_player_info_int[SIC_PI_WEAPON]],	p_player_info_int[SIC_PI_CLIP],	p_player_info_int[SIC_PI_AMMO],		p_player_info_int[SIC_PI_MONEY],	p_player_info_int[SIC_PI_TIME],
			equali(p_player_info_str[SIC_PI_IP],"127.0.0.1") ? "" : p_player_info_str[SIC_PI_IP], p_player_info_int[SIC_PI_FLAGS])
	}

	get_mapname(p_map, sizeof(p_map)-1)
	get_cvar_string("amx_nextmap", p_nextmap, sizeof(p_nextmap)-1)
	get_cvar_string("amx_timeleft", p_timeleft, sizeof(p_timeleft)-1)
	p_timelimit = get_cvar_float("mp_timelimit")

	server_print("")
	server_print("Map: %s / Nextmap: %s / Timeleft: %s / Timelimit : %.2f", p_map, p_nextmap, p_timeleft, p_timelimit);
	server_print("Players (BOT): %d/%d (%d) / CT/T/Spec/None: %d/%d/%d/%d",
		p_plstat[SIC_SI_MAX],	p_plstat[SIC_SI_TOTAL],	p_plstat[SIC_SI_BOT],
		p_plstat[SIC_SI_CT],	p_plstat[SIC_SI_T],		p_plstat[SIC_SI_SPEC],	p_plstat[SIC_SI_UNASS])
}

public sic_info_print_single(id) {
	new players[32], num_players
	new p_kdratio_s[8], p_kmratio_s[8], p_hsratio_s[8], p_score_s[8], p_name[32]

	log_message("S#%5s %5s %20s %-4s %-4s %-5s %-4s %-4s %-5s %4s %4s %-5s %20s %8s %-4s %-4s %-4s %-4s %-7s %-4s %-4s %6s %6s %22s %-8s",
		"UsrId", "Score", "Player name", "Kill", "Dead", "K/D", "Head", "HS/K", "K/Min", "Wall", "WHit", "Team", "STEAM/AUTH ID", CLIENT_USER_ID, "Ping", "Loss", "Hp", "Armr", "Weapon", "Clip", "Ammo", "Money", "Time", "IP address:port", "Flags")

	new p_player_info_int[e_pi_struct_int]
	new p_player_info_str[e_pi_struct_str][32]

	get_players(players, num_players, "")
	if (id > 0) {
		p_player_info_int = player_info_int(id, num_players)
		p_player_info_str = player_info_str(id, num_players)
		sic_get_kdratio(p_player_info_int[SIC_PI_FRAGS], p_player_info_int[SIC_PI_DEATHS], p_kdratio_s, sizeof(p_kdratio_s)-1)
		sic_get_kmratio(p_player_info_int[SIC_PI_FRAGS], p_player_info_int[SIC_PI_TIME], num_players, p_kmratio_s, sizeof(p_kmratio_s)-1)
		sic_get_hsratio(p_player_info_int[SIC_PI_FRAGS], p_player_info_int[SIC_PI_HEADSHOT], p_hsratio_s, sizeof(p_hsratio_s)-1)
		sic_get_score(p_player_info_int, num_players, p_score_s, charsmax(p_score_s))

		copy(p_name, 20, p_player_info_str[SIC_PI_NAME])

		log_message("S#%-5d %5s %20s %4d %4d %5s %4d %4s %5s %4d %4d %5s %20s %8s %4d %4d %4d %4d %7s %4d %4d %6d %6d %22s %8d",
			p_player_info_int[SIC_PI_USER_ID],		p_score_s,	p_name,		p_player_info_int[SIC_PI_FRAGS],		p_player_info_int[SIC_PI_DEATHS],		p_kdratio_s,	p_player_info_int[SIC_PI_HEADSHOT],	p_hsratio_s, p_kmratio_s,
			p_player_info_int[SIC_PI_WALLKILLS],	p_player_info_int[SIC_PI_WALLHITS],	c_teams[p_player_info_int[SIC_PI_TEAM]],p_player_info_str[SIC_PI_AUTH_ID],	p_player_info_str[SIC_PIE_CL_UID],		p_player_info_int[SIC_PI_PING],			p_player_info_int[SIC_PI_LOSS],		p_player_info_int[SIC_PI_HEALTH],
			p_player_info_int[SIC_PI_ARMOR],		c_weapons[p_player_info_int[SIC_PI_WEAPON]],	p_player_info_int[SIC_PI_CLIP],	p_player_info_int[SIC_PI_AMMO],		p_player_info_int[SIC_PI_MONEY],	p_player_info_int[SIC_PI_TIME],
			equali(p_player_info_str[SIC_PI_IP],"127.0.0.1") ? "" : p_player_info_str[SIC_PI_IP], p_player_info_int[SIC_PI_FLAGS])
	}

	server_print("")
}

