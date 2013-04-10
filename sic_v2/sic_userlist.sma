// User listing

#if defined sic_userlist_included
    #endinput
#endif

#define sic_userlist_included

// ; timestamp name auth cl_uid ip flags timelimit(mins) optionalcomments
#define sic_userlist_filename "addons/amxmodx/configs/sic_userlist.cfg"

enum (<<= 1)
{
	PF_MUTED = 1,
	PF_BLOCKED,
	PF_BANNED,
}

enum
{
	BAN_TYPE_TEMPORARY,
	BAN_TYPE_PERMANENT
}

new Trie:g_uidlist
new Trie:g_authlist
new Trie:g_namelist
new Trie:g_iplist

public sic_userlist_plugin_init()
{
	register_concmd("rlduid", "sic_userlist_reload",   ADMIN_RCON, "- ujratolti a banlistat")

	sic_userlist_load()
}

public sic_userlist_reload(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		TrieDestroy(g_uidlist)
		TrieDestroy(g_authlist)
		TrieDestroy(g_namelist)
		TrieDestroy(g_iplist)
		sic_userlist_load()
	}
}

public sic_userlist_load()
{
	log_message("Loading user list (file ^"%s^")", sic_userlist_filename)

	g_uidlist  = TrieCreate()
	g_authlist = TrieCreate()
	g_namelist = TrieCreate()
	g_iplist   = TrieCreate()

	new p_line[255], p_count, i_flags, i_time, i_limit
	new p_timestamp[33], p_name[33], p_auth[33], p_cl_uid[17], p_ip[17], p_flags[17], p_limit[8]
	new fh = fopen(sic_userlist_filename, "r")
	while (!feof(fh)) {
		fgets(fh, p_line, charsmax(p_line))
		trim(p_line)
		if (strlen(p_line) > 0 && p_line[0] != ';') {
			if (parse(p_line, p_timestamp, charsmax(p_timestamp), p_name, charsmax(p_name), p_auth, charsmax(p_auth), p_cl_uid, charsmax(p_cl_uid), p_ip, charsmax(p_ip), p_flags, charsmax(p_flags), p_limit, charsmax(p_limit)) >= 6) {
				i_time = parse_time(p_timestamp, "%Y-%m-%d %H:%M:%S")
				i_limit = str_to_num(p_limit)
				i_flags = read_flags(p_flags)

				if (i_limit == 0 || i_time + i_limit*60 > ts()) {
					TrieSetCell(g_uidlist,  p_cl_uid, i_flags)
					TrieSetCell(g_namelist, p_name,   i_flags)
					TrieSetCell(g_iplist,   p_ip,     i_flags)
					if (sic_bannable(p_auth)) {
						TrieSetCell(g_authlist, p_auth,   i_flags)
					}
				}
			} else {
				server_print("Error, paramcount < 5: %d, %s", p_count, p_line)
			}

			p_limit = ""
		}
	}
	fclose(fh)
}

public sic_userlist_client_connect(id)
{
	new pi[playerinfo], i_flags = 0
	sic_userinfo_fetchall(id, pi)

	if (TrieKeyExists(g_uidlist, pi[pi_cl_uid])) {
		TrieGetCell(g_uidlist, pi[pi_cl_uid], i_flags)
	}
	if (TrieKeyExists(g_authlist, pi[pi_auth]) && sic_bannable(pi[pi_auth])) {
		TrieGetCell(g_authlist, pi[pi_auth], i_flags)
	}
	if (TrieKeyExists(g_iplist, pi[pi_ip])) {
		TrieGetCell(g_iplist, pi[pi_ip], i_flags)
	}
	if (TrieKeyExists(g_namelist, pi[pi_name])) {
		TrieGetCell(g_namelist, pi[pi_name], i_flags)
	}

	if (i_flags) {
		sic_userlist_setflags(id, i_flags)
	}
}

stock sic_userlist_setaccess(id, flags, timelimit, permanent=0)
{
	if (id && flags) {
		new pi[playerinfo], p_ts[33], p_flags[17]
		sic_userinfo_fetchall(id, pi)
		get_time("%Y-%m-%d %H:%M:%S", p_ts, charsmax(p_ts))
		get_flags(flags, p_flags, charsmax(p_flags))

		if (sic_bannable(pi[pi_auth])) {
			TrieSetCell(g_authlist, pi[pi_auth],   flags)
		} else {
			copy(pi[pi_auth], charsmax(pi[pi_auth]), "")
		}
		TrieSetCell(g_uidlist,  pi[pi_cl_uid], flags)
		TrieSetCell(g_namelist, pi[pi_name],   flags)
		TrieSetCell(g_iplist,   pi[pi_ip],     flags)
		sic_userlist_setflags(id, flags)

		if (permanent) {
//			"^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%d^"", p_ts, pi[pi_name], pi[pi_auth], pi[pi_cl_uid], pi[pi_ip], p_flags, timelimit
//			HINT: automatic ban by name or ip could be harmful, therefore i fixed the timelimit in 60 minutes, do it permanent by hand-edit <sic_userlist_filename>

			if (!equal(pi[pi_cl_uid], "")) {
				sic_puts(sic_userlist_filename, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%d^"", p_ts,          "", pi[pi_auth], pi[pi_cl_uid],        "", p_flags, timelimit)
			}
			sic_puts(sic_userlist_filename, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%d^"", p_ts, pi[pi_name], pi[pi_auth], pi[pi_cl_uid], pi[pi_ip], p_flags, timelimit > 60 || timelimit == 0 ? 60 : timelimit)
		}
	} else {
		server_print("Invalid ID or flags!")
	}
}

public sic_userlist_setflags(id, flags)
{
	if (flags & PF_MUTED) {
		sic_moderate_mute(id, 0, 1)
	}
	if (flags & PF_BLOCKED) {
		sic_blockshoot_player(id, 0, 1)
	}
	if (flags & PF_BANNED) {
		server_cmd("kick #%d ^"%s^"", get_user_userid(id), sic_ban_reason)
	}
}
