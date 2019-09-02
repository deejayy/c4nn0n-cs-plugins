#include <amxmodx>
// #include <amxmisc>
// #include <regex>
// #include <hamsandwich>
// #include <cstrike>
// #include <xs>
// #include <fun>
// #include <engine>

public plugin_init()
{
	register_plugin("Mapstat", "0.57", "deejayy.hu");

	set_task(20.0, "mps_checkmap",   74207, "", 0, "b", 0);
	set_task( 5.0, "mps_settimeout", 74208, "", 0, "c", 0);
}

public Float:maxf(Float:a, Float:b)
{
	if (a > b) {
		return a;
	}
	return b;
}

public mps_checkmap()
{
	new map[33];
	new num_players = get_playersnum();
	new Float:p_timelimit;

	get_mapname(map, charsmax(map));

	p_timelimit = get_cvar_float("mp_timelimit");

	if (p_timelimit > 5.0 && p_timelimit < 120.0) {
		p_timelimit = maxf(1.0, p_timelimit + ((num_players - 18.0) / 32.0));
		log_message("-MPS- map: %s, num_players: %d, p_timelimit: %.2f", map, num_players, p_timelimit);
		set_cvar_float("mp_timelimit", p_timelimit);
		server_cmd("sic_ms");
	}
}

public mps_settimeout()
{
	set_cvar_float("mp_timelimit", 50.0);
}
