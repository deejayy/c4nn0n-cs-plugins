#if defined fp_common_included
    #endinput
#endif

#define fp_common_included

#define com_userlist_playerlog "players.log"
#define com_serverid_cvar      "fp_serverid"
#define stripkeys_l 40
new c_stripkeys[stripkeys_l][] = {"_ah", "ah", "autobind", "bn_patch", "bottomcolor", "cheater", "cl_dlmax", "cl_lb", "dm", "dzuid", "friends", "gad", "ghosts", "_gm", "_gmprof", "lac_id", "_lang", "lang", "lefthand", "mID", "model", "mp_cnet", "mp_net", "nameacc", "_ndmf", "_ndmh", "_ndms", "nick_pass", "quality", "rhlg", "_rpgm_cfg", "scanner", "source_models", "src", "status_monitor", "timepass", "topcolor", "translit", "vgui_menu", "xredir"}
new c_teamnames[CsTeams][] = { "", "T", "CT", "SPEC" }
new g_cl_uid[33][8];

public plugin_init_common()
{
	register_clcmd("say /rank",      "com_rank_command");
	register_clcmd("say /admin",     "com_adminlist_command");
	register_clcmd("say /admins",    "com_adminlist_command");
	register_clcmd("say /adminlist", "com_adminlist_command");
	register_clcmd("say admins",     "com_adminlist_command");
	register_clcmd("say adminlist",  "com_adminlist_command");

	register_clcmd("say /pos",       "com_write_position");

	new serverid[16], hostname[128];
	get_cvar_string("hostname", hostname, charsmax(hostname));
	com_generate_cl_uid(serverid, 8, "%s, %s", hostname, get_cvar_num("port"));

	register_cvar(com_serverid_cvar, serverid, 1);
}

public com_rank_command(id)
{
	client_print(0, print_console, "Online statisztika (valos): http://c4nn0n.deejayy.hu/stat");
	fch_colormessage(id, 3, "Online statisztika (valos): http://c4nn0n.deejayy.hu/stat (link a konzolban)");
	return PLUGIN_CONTINUE;
}

public com_adminlist_command(id)
{
	ann_announce(id, "Online adminok: 1");
	return PLUGIN_CONTINUE;
}

public client_connect_common(id)
{
	com_stripinfo(id);
	com_set_cl_uid(id);
	com_log_player(id);
	com_redirect(id);
}

public com_stripinfo(id)
{
	for (new i = 0; i < stripkeys_l; i++) {
		client_cmd(id, "setinfo %s ^"^"", c_stripkeys[i]);
	}
}

public com_generate_cl_uid(cl_uid[], len, source[], any:...)
{
	new p_source[32], p_dest[34]
	vformat(p_source, charsmax(p_source), source, 4)
	md5(p_source, p_dest)
	copy(cl_uid, len, p_dest)
}

public com_check_setinfo(topcolor[], task_id)
{
	new p_topcolor[32], p_cl_uid[8];
	get_user_info(task_id - 74400, "topcolor", p_topcolor, charsmax(p_topcolor));
	get_user_info(task_id - 74400, "cl_uid", p_cl_uid, charsmax(p_cl_uid));
	client_cmd(task_id - 74400, "setinfo topcolor ^"%s^"", topcolor);

	if (equali(topcolor, p_topcolor) && equali(p_cl_uid, "")) {
		new uid = get_user_userid(task_id - 74400);
		server_print("-- Can't set topcolor for #%d, blocking", uid);
		// not reliable yet
		// server_cmd("fp_block #%d", uid);
	}

	server_print("topcolor: %s, task id: %d, fresh read: %s", topcolor, task_id, p_topcolor);
}

public com_set_cl_uid(id)
{
	new cl_uid[8], ip[32];
	get_user_info(id, "cl_uid", cl_uid, charsmax(cl_uid));
	get_user_ip(id, ip, charsmax(ip), 1);

	if (!is_user_bot(id)) {
		/**
		 * save the topcolor variable for a little testing
		 * change it to "1" + topcolor
		 * set a task to read it later (3.0 sec default) and restore to originally read value
		 * if it is changed, we can access setinfo, else some shield is active
		**/
		new topcolor[32];
		get_user_info(id, "topcolor", topcolor, charsmax(topcolor));
		client_cmd(id, "setinfo topcolor ^"1%s^"", topcolor);
		set_task(3.0, "com_check_setinfo", 74400 + id, topcolor, sizeof(topcolor), "a", 1);

		if (equal(cl_uid, "") || equal(cl_uid, "76c6fd") || equal(cl_uid, "2ec9c1")) {
			com_generate_cl_uid(cl_uid, 6, "%s.%d.%s", ip, random_num(10000,99999), id);
			g_cl_uid[id] = cl_uid;
			client_cmd(id, "setinfo cl_uid ^"%s^"", cl_uid);

			new checkinfo[32];
			get_user_info(id, "cl_uid", checkinfo, charsmax(checkinfo));
			if (equal(checkinfo, "")) {
				com_stripinfo(id);
				client_cmd(id, "setinfo cl_uid ^"%s^"", cl_uid);
			}
		}

	}
}

public com_log_player(id)
{
	new auth[32];
	get_user_authid(id, auth, charsmax(auth));

	if (!equal(auth, "BOT")) {
		new cl_uid[8], ip[32], name[32], map[32], logdir[255], logfile[255], sName[65], sCluid[32], uid;

		get_user_name(id, name, charsmax(name));
		get_user_info(id, "cl_uid", cl_uid, charsmax(cl_uid));
		get_user_ip(id, ip, charsmax(ip), 1);
		get_mapname(map, charsmax(map));
		uid = get_user_userid(id);

		if (equali(cl_uid, "")) {
			cl_uid = g_cl_uid[id];
		}

		get_localinfo("amxx_logs", logdir, charsmax(logdir));
		format(logfile, charsmax(logfile), "%s/%s", logdir, com_userlist_playerlog);

//		auth[6] = 48;

		com_putsd(logfile, "%20s^t%32s^t%20s^t%24s^t%6s", map, name, auth, ip, cl_uid);

		db_quote_string(sName, charsmax(sName), name);
		db_quote_string(sCluid, charsmax(sCluid), cl_uid);

		new serverid[16], sServerid[33];
		get_cvar_string(com_serverid_cvar, serverid, charsmax(serverid));
		db_quote_string(sServerid, charsmax(sServerid), serverid);

//		auth[6] = 48;

		db_silent_query("insert into sic_players (plr_connect, plr_map_map_id, plr_server_srv_id, plr_name, plr_auth, plr_ip, plr_cl_uid, plr_uid, plr_steam) values (now(), (select map_id from sic_maps where map_name = '%s'), (select srv_id from sic_servers where srv_serverid = '%s'), '%s', '%s', '%s', '%s', %d, %d)",
			map, sServerid, sName, auth, ip, sCluid, uid, com_has_steam(id));
	}
}

public com_redirect(id)
{
	new players[32], num_players, max = get_maxplayers();
	get_players(players, num_players);
	if (max - num_players <= 1) {
		client_cmd(id, "connect 193.224.130.190:27025");
	}
}

public com_puts(file[], text[], any:...)
{
	new p_text[1024]
	vformat(p_text, charsmax(p_text)-1, text, 3)

	write_file(file, p_text)
}

public com_putsd(file[], text[], any:...)
{
	new p_text[1024], p_ts[33]
	vformat(p_text, charsmax(p_text)-1, text, 3)
	get_time("%Y-%m-%d %H:%M:%S", p_ts, charsmax(p_ts))

	com_puts(file, "%s^t%s", p_ts, p_text)
}

public plugin_log_common()
{
	new message[255];
	read_logdata(message, sizeof(message)-1);

	if (contain(message, " attacked ") != -1 || contain(message, " killed ") != -1 || contain(message, " entered the game") != -1) {
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}

public log_message_getuser(id, user[], length)
{
	new name[33], auth[33], uid = 0, CsTeams:team = CS_TEAM_UNASSIGNED

	if (id > 0) {
		uid = get_user_userid(id);
		if (get_user_time(id) > 5) {
			team = cs_get_user_team(id);
		}
	
		get_user_name(id, name, charsmax(name));
		get_user_authid(id, auth, charsmax(auth));
	} else {
		get_cvar_string("hostname", name, charsmax(name));
		auth = "BOT";
	}

	format(user, length, "^"%s<%d><%s><%s>^"", name, uid, auth, c_teamnames[team]);
}

public log_message_user(id, text[], any:...)
{
	new p_text[1024], user[128];
	vformat(p_text, charsmax(p_text), text, 3);
	log_message_getuser(id, user, charsmax(user));

	log_message("%s %s", user, p_text);
}

public log_message_user2(id, id2, event[], text[], any:...)
{
	new p_text[1024], user[128], user2[128];
	vformat(p_text, charsmax(p_text), text, 5);
	log_message_getuser(id, user, charsmax(user));
	log_message_getuser(id2, user2, charsmax(user2));

	log_message("%s %s %s %s", user, event, user2, p_text);
}

public client_disconnect_common(id)
{
	g_cl_uid[id] = "";
	st_printstat(id);
}

public client_putinserver_common(id)
{
	new cl_uid[8], ip[32];

	get_user_info(id, "cl_uid", cl_uid, charsmax(cl_uid));
	get_user_ip(id, ip, charsmax(ip), 1);

	log_message_user(id, "entered the game (cl_uid ^"%s^") (ip ^"%s^") (port ^"%d^") (steam ^"%d^")", cl_uid, ip, 0, com_has_steam(id));
}

public com_write_position(id)
{
	static Float:origin[3];

	pev(id, pev_origin, origin);
	server_print("%.4f, %.4f, %.4f", origin[0], origin[1], origin[2]);

	new p_entid = find_ent_by_class(-1, "func_wall_toggle");
	server_print("entid: %d", p_entid);
	remove_entity(p_entid);

	new p_dest[34], p_time[32], p_passwd[16];
	get_time("%Y-%m-%d", p_time, charsmax(p_time));
	md5(p_time, p_dest);
	copy(p_passwd, 6, p_dest[6]);
	server_print("password: %s", p_passwd);
	// server_cmd("sv_password %s", p_passwd);

	return PLUGIN_HANDLED;
}

public com_weapons_count(wep, team[])
{
	new players[32], num_players, p_weapons[32], num = 0, count = 0

	get_players(players, num_players, "e", team)
	for (new i = 0; i < num_players; i++) {
		num = 0
		get_user_weapons(players[i], p_weapons, num)
		for (new j = 0; j < num; j++) {
			if (p_weapons[j] == wep) {
				count++
			}
		}
	}

	return count
}

// 76561197966126325
public com_has_steam(id)
{
	new sid[65];
	get_user_info(id, "*sid", sid, charsmax(sid));

	return contain(sid, "765611") >= 0 ? 1 : 0;
}
