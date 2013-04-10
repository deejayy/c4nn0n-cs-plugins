#if defined sic_common_included
    #endinput
#endif

#define sic_common_included

#define sic_uniq_key   "cl_uid"
#define sic_ban_reason "Ki vagy tiltva innen / You are banned. Tovabbi info: http://c4nn0n.deejayy.hu/"

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

public sic_bannable(authid[])
{
	if (equal(authid, "BOT") ||
		equal(authid, "4294967295") ||
		equal(authid, "HLTV") ||
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
