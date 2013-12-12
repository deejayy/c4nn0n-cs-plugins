#if defined fp_userflags_included
    #endinput
#endif

#define fp_userflags_included

enum (<<= 1)
{
	UF_MUTED = 1,
	UF_BLOCKED,
	UF_BANNED,
	UF_IMMUNITY,
	UF_ADMIN,
}

new g_immune[33];

client_putinserver_userflags(id)
{
	g_immune[id] = 0;

	new pName[33], pAuth[33], pClUid[8], pIp[33], pUid;
	new sName[65], sClUid[65];

	get_user_name  (id, pName, charsmax(pName));
	get_user_authid(id, pAuth, charsmax(pAuth));
	get_user_ip    (id, pIp,   charsmax(pIp), 1);
	get_user_info  (id, "cl_uid", pClUid, charsmax(pClUid));
	pUid = get_user_userid(id);

	db_quote_string(sName, charsmax(sName), pName);
	db_quote_string(sClUid, charsmax(sClUid), pClUid);

	new data[1], dataSize = 1;
	data[0] = pUid;

	db_query("uf_userflag_handler", data, dataSize, "select * from sic_active_user_flags where ufl_name = '%s' or ufl_auth = '%s' or ufl_ip = '%s' or ufl_cluid = '%s'", sName, pAuth, pIp, sClUid);
}

uf_set_immunity(id, value)
{
	g_immune[id] = value;
}

uf_get_immunity(id)
{
	return g_immune[id];
}

public uf_userflag_handler(failState, Handle:query, error[], errCode, data[], dataSize)
{
	db_handle_errors(failState, query, error, errCode, data, dataSize);
	new Trie:r = db_get_record(query);

	new pUid = data[0];

	new reason[256], flag = 0;

	TrieGetString(r, "ufl_reason", reason, charsmax(reason));

	flag = uf_get_flag_from_trie(r, flag, "ufl_name_flags");
	flag = uf_get_flag_from_trie(r, flag, "ufl_auth_flags");
	flag = uf_get_flag_from_trie(r, flag, "ufl_ip_flags");
	flag = uf_get_flag_from_trie(r, flag, "ufl_cluid_flags");

	if (flag) {
		if (flag & UF_MUTED) {
			server_cmd("fp_mute #%d", pUid);
		}
		if (flag & UF_BLOCKED) {
			server_cmd("fp_block #%d", pUid);
		}
		if (flag & UF_IMMUNITY) {
			server_cmd("fp_immune #%d", pUid);
		}
		if (flag & UF_BANNED) {
			server_cmd("fp_kick #%d ^"%s^"", pUid, reason);
		}
	}

	TrieDestroy(r);
}

/**
 * Returns the summarized flag from a Trie's field
 *
 * @param r     Trie   input array
 * @param flag  int    original flags
 * @param field string check this field for new flags
 *
 * @return int
 */
uf_get_flag_from_trie(Trie:r, flag, field[])
{
	new buffer[256];

	TrieGetString(r, field, buffer, charsmax(buffer));
	if (buffer[0]) {
		flag = flag | str_to_num(buffer);
	}

	return flag;
}

/**
 * Write flags to database
 *
 * @param id      int    client id
 * @param flags   array  strict array format: {name_flags, auth_flags, cluid_flags, ip_flags}
 * @param minutes array  strict array format: {name_minutes, auth_minutes, cluid_minutes, ip_minutes}
 * @param reason  string flag setting reason (eg. ban reason, vip, trolling, etc.)
 *
 * @return null
 */
uf_write_userflag(id, flags[], minutes[], reason[], admin_id)
{
	const fieldCount = 4
	new dbFields[fieldCount][33] = {"ufl_name", "ufl_auth", "ufl_cluid", "ufl_ip"};
	new dbValues[fieldCount][65]; // escaping can double string's length
	new sReason[256], i;

	new pName[33], pClUid[8], sAdminName[64];

	get_user_authid(id, dbValues[1], 32);
	get_user_ip    (id, dbValues[3], 32, 1);

	get_user_name  (id, pName, charsmax(pName));
	get_user_info  (id, "cl_uid", pClUid, charsmax(pClUid));

	db_quote_string(dbValues[0], 64, pName);
	db_quote_string(dbValues[2], 64, pClUid);

	if (admin_id) {
		get_user_name(admin_id, pName, charsmax(pName));
		db_quote_string(sAdminName, charsmax(sAdminName), pName);
	}

	db_quote_string(sReason, charsmax(sReason), reason);

	new fieldList[256], fieldValues[256]

	if (!uf_bannable(dbValues[1])) {
		flags[1] = 0;
	}

	if (equal(dbValues[3], "127.0.0.1")) {
		flags[3] = 0;
	}

	for (i = 0; i < fieldCount; i++) {
		if (flags[i] && dbValues[i][0]) {
			format(fieldList, charsmax(fieldList), "%s%s%s, %s_flags, %s_minutes", fieldList, fieldList[0] ? ", " : "", dbFields[i], dbFields[i], dbFields[i])
			format(fieldValues, charsmax(fieldValues), "%s%s'%s', %d, %d", fieldValues, fieldValues[0] ? ", " : "", dbValues[i], flags[i], minutes[i]);
		}
	}

	db_silent_query("insert into sic_user_flags (ufl_created, ufl_reason, ufl_admin, %s) values (now(), '%s', '%s', %s)", fieldList, sReason, sAdminName, fieldValues);
}

uf_bannable(authid[])
{
	if (equal(authid, "BOT") ||
		equal(authid, "") ||
		equal(authid, "4294967295") ||
		equal(authid, "STEAM_ID_LAN") ||
		equal(authid, "VALVE_ID_LAN") ||
		equal(authid, "STEAM_ID_PENDING") ||
		equal(authid, "VALVE_ID_PENDING")) {
		return 0
	}

	return 1
}
