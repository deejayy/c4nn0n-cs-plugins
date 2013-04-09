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
