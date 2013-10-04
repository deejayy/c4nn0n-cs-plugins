#if defined sic_common_included
    #endinput
#endif

#define sic_common_included

#define sic_uniq_key   "cl_uid"
#define sic_ban_reason "Ki vagy tiltva innen / You are banned. Tovabbi info: http://c4nn0n.deejayy.hu/"

public sic_common_plugin_init()
{
	register_clcmd("say /pos",     "sic_common_write_position")
}

public ts()
{
	new timestamp[32]
	get_time("%s", timestamp, charsmax(timestamp))
	return str_to_num(timestamp)
}

public sic_puts(file[], text[], any:...)
{
	new p_text[1024]
	vformat(p_text, charsmax(p_text)-1, text, 3)

	write_file(file, p_text)
}

public sic_putsd(file[], text[], any:...)
{
	new p_text[1024], p_ts[33]
	vformat(p_text, charsmax(p_text)-1, text, 3)
	get_time("%Y-%m-%d %H:%M:%S", p_ts, charsmax(p_ts))

	sic_puts(file, "%s^t%s", p_ts, p_text)
}

public sic_bannable(authid[])
{
	if (equal(authid, "BOT") ||
		equal(authid, "") ||
		equal(authid, "4294967295") ||
		equal(authid, "STEAM_ID_LAN") ||
		equal(authid, "VALVE_ID_LAN") ||
		equal(authid, "STEAM_ID_PENDING") ||
		equal(authid, "VALVE_ID_PENDING")) {
		return 0
	} else {
		return 1
	}

	return 0
}

public sic_generate_cl_uid(cl_uid[], len, source[], any:...)
{
	new p_source[32], p_dest[34]
	vformat(p_source, charsmax(p_source), source, 4)
	md5(p_source, p_dest)
	copy(cl_uid, len, p_dest)
}

public sic_common_write_position(id)
{
	static Float:origin[3];

	pev(id, pev_origin, origin);
	server_print("%.2f, %.2f, %.2f", origin[0], origin[1], origin[2]);
}
