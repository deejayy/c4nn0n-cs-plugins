#if defined fp_moderate_included
    #endinput
#endif

#define fp_moderate_included

#define spam_pattern       "[0-9 ]+\.[0-9 ]+\.[0-9 ]+\.[0-9 ]+|2[6-9 ][0-9 ][0-9 ][0-9 ]|\.com|\.net|\.hu|\.org|\.ro|\.sk|\.tk|\.ua|aim|off|wh|bot|kurva|kruva|kocsog|anyad|geci|csira|csics|fas+z|kuty|kutza|retk|cig.ny|szar|gyoker|rohad|buzi|pro.*kill|bas+z|bind.*kill|magyar.*only.*d"
#define spam_pattern_name  "[0-9 ]+\.[0-9 ]+\.[0-9 ]+\.[0-9 ]+|2[6-9 ][0-9 ][0-9 ][0-9 ]|\.com|\.net|\.hu|\.org|\.ro|\.sk|\.tk|\.ua|facebook|[a4]d[mn][i1][nm]|c[4a]+[nm]+[0o]+[mn]|sz*erver|d[e3].*j[a4]+y+"
#define ban_pattern        "BaDBoY.*Private.*Frags.*Deaths.*HS|CREATED BY M.F1A AND DARKTEAM|BaDBoY.*united-cheaters|Alien h4x|Unreal-Rage Public v|W4R Hook v. By|test hook v[0-9]|C\.C\.A Priv.*Hook|BulkaH4ck|Russian.Cheaters.com|Unreal-Gaming.com|Nik Hook v.*|zh4r0naX|370Hook v1.4|C\.C\.A HooK|Switch To Gaming|switchtogaming|173\.213\.|104\.131\.|GIVE ADMIN FEEE|CO\|NN\|ECT Server|ADMINE FR?EE|lphost|RESPAWN 2015|FRE+ ADMIN|\/chat|vk\.com|185\.58\.|by ZeaL|XO4ET ADMINKY|FRE+ VIP|A D M I N"
#define ban_pattern2       "AMMO FOR NEW PLAYERS|SIBIU.RANGFORT.RO|Pirate-Hack\.tk|Unreal-Rage-Public|Adnan TOTAL OWNAGE|RAGE.*REVENGE.*aimbot|First 3 players|Pirokao-Hook|FLVBYRF|VALVE-MS RU"
#define server_banner_name "193.224.130.190:27015"

new g_muted[33];

public mod_get_muted(id)
{
	return g_muted[id];
}

public mod_set_muted(id, value)
{
	g_muted[id] = value;
}

public plugin_init_moderate()
{
	register_clcmd("say",      "mod_say_command");
	register_clcmd("say_team", "mod_say_command");

	register_forward(FM_ClientUserInfoChanged, "mod_userinfochanged")
}

public client_connect_moderate(id)
{
	mod_set_muted(id, 0);
}

public mod_say_command(id)
{
	new p_param[256], p_name[33], ip[33];
	read_args(p_param, charsmax(p_param));
	remove_quotes(p_param);

	get_user_ip(id, ip, charsmax(ip), 1);
	get_user_info(id, "name", p_name, charsmax(p_name));

	if (mod_regex_match(p_param, ban_pattern, 0)) {
		log_message_user(id, "say ^"BAN_PATTERN: %s^"", p_param);
		mod_set_muted(id, 1);
		new uid = get_user_userid(id);
		server_cmd("fp_punish #%d ^"Nem cheatelsz tobbet. (1)^"", uid);
		return PLUGIN_HANDLED;
	}

	if (mod_regex_match(p_param, ban_pattern2, 0)) {
		log_message_user(id, "say ^"BAN_PATTERN: %s^"", p_param);
		mod_set_muted(id, 1);
		new uid = get_user_userid(id);
		server_cmd("fp_punish #%d ^"Nem cheatelsz tobbet. (1)^"", uid);
		return PLUGIN_HANDLED;
	}

	if (mod_get_muted(id) || mod_regex_match(p_param, spam_pattern, 1)) {
		log_message_user(id, "say ^"MUTED: %s^"", p_param);
		fch_echo(id, p_param);
		return PLUGIN_HANDLED;
	}

	if (mod_regex_match(p_name, "\[VALVE - MS RU\]", 0)) {
		log_message("F'kin Steamboost asshole: %s, %s", ip, p_name);
		server_cmd("addip %d %s", 60, ip);
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE
}

public mod_regex_match(p_param[], pattern[], strip)
{
	new p_ret, p_error[128], p_text[128]
	copy(p_text, charsmax(p_text), p_param)
	if (strip == 1) {
		replace(p_text, charsmax(p_text), " ", "")
	}

	new Regex:p_regex = regex_match(p_text, pattern, p_ret, p_error, sizeof(p_error), "i")
	if (p_regex >= REGEX_OK) {
		regex_free(p_regex)
		return 1
	}

	return 0
}

public mod_userinfochanged(id)
{
	new p_oldname[33], p_newname[33];
	pev(id, pev_netname, p_oldname, charsmax(p_oldname));
	get_user_info(id, "name", p_newname, charsmax(p_newname));

	if (!(equal(p_oldname, p_newname) || uf_get_name_immunity(id))) {
//	if (!(equal(p_oldname, p_newname))) {
		if (strlen(p_oldname) == 0) {
			format(p_oldname, charsmax(p_oldname), "%s /%d", server_banner_name, random_num(1000,9999));
			//p_oldname = server_banner_name;
		}

		if (mod_regex_match(p_newname, spam_pattern_name, 1)) {
			server_print("Spammer name: %s", p_newname);
			set_user_info(id, "name", p_oldname);
			mod_set_muted(id, 1);
			return FMRES_HANDLED;
		}

		return FMRES_HANDLED;
	}

	return FMRES_IGNORED;
}
