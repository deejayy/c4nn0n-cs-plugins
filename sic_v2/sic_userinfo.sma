// User info

#if defined sic_userinfo_included
    #endinput
#endif

#define sic_userinfo_included

#include <cstrike>

new c_teamnames[CsTeams][] = { "", "TERRORIST", "CT", "SPEC" }

enum _:playerinfo
{
	pi_name[33],
	pi_auth[33],
	pi_team,
	pi_userid,
	pi_kills
}

public sic_userinfo_fetchall(id, pi[])
{
	pi[pi_userid] = get_user_userid(id)
	get_user_name(id, pi[pi_name], charsmax(pi[pi_name]))
	get_user_authid(id, pi[pi_auth], charsmax(pi[pi_auth]))
	if (is_user_connected(id)) {
		pi[pi_team] = _:cs_get_user_team(id)
	} else {
		pi[pi_team] = _:CS_TEAM_UNASSIGNED
	}
}

public sic_userinfo_logstring(id, logstring[], logstring_length)
{
	new pi[playerinfo]
	sic_userinfo_fetchall(id, pi)

	format(logstring, logstring_length, "^"%s<%d><%s><%s>^"", pi[pi_name], pi[pi_userid], pi[pi_auth], c_teamnames[CsTeams:pi[pi_team]])
}
