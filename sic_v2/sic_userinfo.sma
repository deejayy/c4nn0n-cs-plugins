// User info

#if defined sic_userinfo_included
    #endinput
#endif

#define sic_userinfo_included

#include <cstrike>

new c_teamnames[CsTeams][] = { "", "TERRORIST", "CT", "SPEC" }
new c_weapons[33][]		= {"undef0", "P228", "undef2", "Scout", "He", "Xm1014", "C4", "Mac10", "Aug", "Smoke", "Elite", "5-7", "Ump45", "Sg550", "Galil", "Famas", "Usp", "Glock", "Awp", "Mp5", "M249", "M3", "M4A1", "Tmp", "G3SG1", "Flash", "Deagle", "Sg552", "Ak47", "Knife", "P90", "Vest", "VestH"}
new c_hitplaces[11][]	= {"Generic", "Head", "Chest", "Stomach", "Leftarm", "Rightarm", "Leftleg", "Rightleg", "8", "9", "10"}

new g_user_kills[33]
new g_user_deaths[33]
new g_user_hs[33]
new g_user_hk[33]
new g_user_ws[33]
new g_user_wk[33]

enum _:playerinfo
{
	pi_name[33],
	pi_auth[33],
	pi_ip[17],
	pi_ipport[25],
	pi_cl_uid[17],
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

public Float:sic_userinfo_calc_score(pi[])
{
	new Float:p_score = 6.66

	new Float:s_p  = get_playersnum() * 1.0
	new Float:s_k  = pi[pi_kills] > 0 ? pi[pi_kills] * 1.0 : 1.0
	new Float:s_kn = pi[pi_kills] * 1.0
	new Float:s_d  = pi[pi_deaths] > 0 ? pi[pi_deaths] * 1.0 : 1.0
	new Float:s_t  = pi[pi_time] * 1.0 + 1.0
	new Float:s_h  = pi[pi_hs] * 1.0
	new Float:s_w  = pi[pi_ws] * 1.0
	new Float:s_wk = pi[pi_wk] * 1.0

	p_score += xs_sqrt(s_kn / s_d)	// kill / death			12/1 = 12			12/4 = 3		nagyobb az arany, annal jobb a jatekos
	p_score += (s_h / s_k) * 5.0	// hs / kill * 5		2/12*5 = 0.83		9/12*5 = 3.75	tobb a headshot,
	p_score += s_kn / (s_t/60.0)	// kill / (time / 60)	12/(130/60) = 5.54	12/(20/60) = 36	gyorsabban ol,
	p_score += 2.0 - s_p / 12.0		// 2 - players/12		2-5/12 = 1.58		2-19/12 = 0.41	kevesebb a jatekos,
	p_score += s_w / s_k * 3.0		// wallhit / kill * 3	3/12*3 = 0.75		12/12*3 = 3		tobb a falon keresztul lott
	p_score += s_wk / 3.0 - 1.0		// wallkill / 3 - 1		1/3-1 = -0.66		5/3-1 = 0.66	tobb a falon keresztul kill
	p_score -= floatpower(17.0 / s_k, 2.0)			// 10 / kill			10/12 = 0.8			10/80 = 0.125	korrekcios szam, ki kell vonni

	return p_score
}

public sic_userinfo_fetchall(id, pi[])
{
	pi[pi_userid] = get_user_userid(id)

	get_user_name   (id, pi[pi_name], charsmax(pi[pi_name]))
	get_user_authid (id, pi[pi_auth], charsmax(pi[pi_auth]))
	get_user_ip     (id, pi[pi_ip], charsmax(pi[pi_ip]), 1)
	get_user_ip     (id, pi[pi_ipport], charsmax(pi[pi_ipport]), 0)

	if (id) {
		get_user_info(id, sic_uniq_key, pi[pi_cl_uid], charsmax(pi[pi_cl_uid]))
		if (is_user_connected(id)) {
			get_user_ping(id, pi[pi_ping], pi[pi_loss])
			pi[pi_team]       = _:cs_get_user_team(id)
			pi[pi_okills]     = get_user_frags(id)
			pi[pi_odeaths]    = cs_get_user_deaths(id)
			pi[pi_money]      = cs_get_user_money(id)
			pi[pi_armor]      = get_user_armor(id)
			pi[pi_flags]      = get_user_flags(id)
			pi[pi_health]     = get_user_health(id)
			pi[pi_time]       = get_user_time(id)
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
}

public sic_userinfo_logstring(id, logstring[], logstring_length)
{
	new pi[playerinfo]
	sic_userinfo_fetchall(id, pi)

	format(logstring, logstring_length, "^"%s<%d><%s><%s>^"", pi[pi_name], pi[pi_userid], pi[pi_auth], c_teamnames[CsTeams:pi[pi_team]])
}

public sic_userinfo_client_damage(attacker, victim, damage, wpnindex, hitplace, ta) {
	new pi_a[playerinfo], pi_v[playerinfo], p_wall
	sic_userinfo_fetchall(attacker, pi_a)
	sic_userinfo_fetchall(victim, pi_v)

	g_user_kills [attacker]++;
	g_user_deaths[victim  ]++;

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
