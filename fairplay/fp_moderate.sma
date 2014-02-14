#if defined fp_moderate_included
    #endinput
#endif

#define fp_moderate_included

#define spam_pattern       "[0-9 ]+\.[0-9 ]+\.[0-9 ]+\.[0-9 ]+|2[6-9 ][0-9 ][0-9 ][0-9 ]|\.com|\.net|\.hu|\.org|\.ro|\.sk|aim|off|wh|bot|kurva|kruva|kocsog|anyad|geci|csira|csics|fasz|kutya|kutza|retk|cig.ny|szar|gyoker|rohad|buzi"
#define spam_pattern_name  "[0-9 ]+\.[0-9 ]+\.[0-9 ]+\.[0-9 ]+|2[6-9 ][0-9 ][0-9 ][0-9 ]|\.com|\.net|\.hu|\.org|\.ro|\.sk|facebook|[a4]dm[i1]n|c[4a]nn[0o]n|sz*erver"
#define ban_pattern        "BaDBoY.*Private.*Frags.*Deaths.*HS|CREATED BY M.F1A AND DARKTEAM|BaDBoY.*united-cheaters|Alien h4x|Unreal-Rage Public v|W4R Hook v. By|test hook v[0-9]|C\.C\.A Priv.*Hook|BulkaH4ck|Russian.Cheaters.com|www.Unreal-Gaming.com"
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
	new p_param[256];
	read_args(p_param, charsmax(p_param));
	remove_quotes(p_param);

	if (mod_regex_match(p_param, ban_pattern, 0)) {
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

	if (!(equal(p_oldname, p_newname) || uf_get_immunity(id))) {
		if (strlen(p_oldname) == 0) {
			p_oldname = server_banner_name;
		}

		if (mod_regex_match(p_newname, spam_pattern_name, 1)) {
			set_user_info(id, "name", p_oldname);
			mod_set_muted(id, 1);
			return FMRES_HANDLED;
		}

		return FMRES_HANDLED;
	}

	return FMRES_IGNORED;
}
