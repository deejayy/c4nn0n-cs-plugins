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
}

getFlagFromTrie(Trie:r, flag, field[])
{
	new buffer[256];

	TrieGetString(r, field, buffer, charsmax(buffer));
	if (buffer[0]) {
		flag = flag | str_to_num(buffer);
	}

	return flag;
}

client_connect_userflags(id)
{
	new pName[33], pAuth[33], pClUid[8], pIp[33], pUid;
	new sName[65], sClUid[65];

	get_user_name  (id, pName, charsmax(pName));
	get_user_authid(id, pAuth, charsmax(pAuth));
	get_user_ip    (id, pIp,   charsmax(pIp));
	get_user_info  (id, "cl_uid", pClUid, charsmax(pClUid));
	pUid = get_user_userid(id);

	SQL_QuoteString(Empty_Handle, sName, charsmax(sName), pName);
	SQL_QuoteString(Empty_Handle, sClUid, charsmax(sClUid), pClUid);

	dbQuery("userflagHandler", "select * from sic_active_user_flags where ufl_name = '%s' or ufl_auth = '%s' or ufl_ip = '%s' or ufl_cluid = '%s'", sName, pAuth, pIp, sClUid);

/*
	new Trie:r = dbGetRecord("select * from sic_active_user_flags where ufl_name = '%s' or ufl_auth = '%s' or ufl_ip = '%s' or ufl_cluid = '%s'", sName, pAuth, pIp, sClUid);

	new reason[256], flag = 0;

	TrieGetString(r, "ufl_reason", reason, charsmax(reason));

	flag = getFlagFromTrie(r, flag, "ufl_name_flags");
	flag = getFlagFromTrie(r, flag, "ufl_auth_flags");
	flag = getFlagFromTrie(r, flag, "ufl_ip_flags");
	flag = getFlagFromTrie(r, flag, "ufl_cluid_flags");

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
*/
}

public userflagHandler(failState, Handle:query, error[], errCode, data[], dataSize)
{
	dbHandleErrors(failState, query, error, errCode, data, dataSize);
}

/**
 * Write flags to database
 *
 * Example code:
 *
 * @param id      int    client id
 * @param flags   array  strict array format: {name_flags, auth_flags, cluid_flags, ip_flags}
 * @param minutes array  strict array format: {name_minutes, auth_minutes, cluid_minutes, ip_minutes}
 * @param reason  string flag setting reason (eg. ban reason, vip, trolling, etc.)
 *
 * @return null
 */
writeUserFlags(id, flags[], minutes[], reason[], admin_id)
{
	const fieldCount = 4
	new sReason[256], i;
	new dbFields[fieldCount][33] = {"ufl_name", "ufl_auth", "ufl_cluid", "ufl_ip"};
	new dbValues[fieldCount][65]; // escaping can duplicate string's length

	new pName[33], pClUid[8], sAdminName[64];

	get_user_authid(id, dbValues[1], 32);
	get_user_ip    (id, dbValues[3], 32);

	get_user_name  (id, pName, charsmax(pName));
	get_user_info  (id, "cl_uid", pClUid, charsmax(pClUid));

	SQL_QuoteString(Empty_Handle, dbValues[0], 64, pName);
	SQL_QuoteString(Empty_Handle, dbValues[2], 64, pClUid);

	if (admin_id) {
		get_user_name(admin_id, pName, charsmax(pName));
		SQL_QuoteString(Empty_Handle, sAdminName, charsmax(sAdminName), pName);
	}

	SQL_QuoteString(Empty_Handle, sReason, charsmax(sReason), reason);

	new fieldList[256], fieldValues[256]

	for (i = 0; i < fieldCount; i++) {
		if (flags[i] && dbValues[i][0]) {
			format(fieldList, charsmax(fieldList), "%s%s%s, %s_flags, %s_minutes", fieldList, fieldList[0] ? ", " : "", dbFields[i], dbFields[i], dbFields[i])
			format(fieldValues, charsmax(fieldValues), "%s%s'%s', %d, %d", fieldValues, fieldValues[0] ? ", " : "", dbValues[i], flags[i], minutes[i]);
		}
	}

	dbSilentQuery("insert into sic_user_flags (ufl_created, ufl_reason, ufl_admin, %s) values (now(), '%s', '%s', %s)", fieldList, sReason, sAdminName, fieldValues);
}
