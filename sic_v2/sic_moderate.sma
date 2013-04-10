// Chat moderation

#if defined sic_moderate_included
    #endinput
#endif

#define sic_moderate_included

#include <amxmisc>
#include <regex>
#include <fakemeta>

#define spam_pattern       "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|2[6-9][0-9][0-9][0-9]|\.com|\.net|\.hu|\.COM|\.NET|\.HU\|\.org|\.ORG"
#define ban_pattern        "BaDBoY.*Private.*Frags.*Deaths.*HS|CREATED BY M.F1A AND DARKTEAM|BaDBoY.*united-cheaters"
#define server_banner_name "193.224.130.190:27015"

new g_muted[33]
new g_chatbanned[33]

public sic_moderate_plugin_init()
{
	register_clcmd ("say",      "sic_moderate_handle_say")
	register_clcmd ("say_team", "sic_moderate_handle_say")
	register_concmd("mute",     "sic_modereate_cmd_mute",   ADMIN_KICK, "- letiltja a chatet a felhasznalonak")
	register_concmd("unmute",   "sic_modereate_cmd_unmute", ADMIN_KICK, "- visszaallitja a chatet a felhasznalonak")

	register_forward(FM_ClientUserInfoChanged, "sic_moderate_fm_cinfoc")
}

public sic_moderate_client_connect(id)
{
	g_muted[id] = 0
	g_chatbanned[id] = 0
}

public sic_moderate_client_putinserver(id)
{
	
}

public sic_modereate_cmd_mute(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33]
		read_argv(1, target, charsmax(target))
		new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			sic_moderate_mute(player, id, 1)
		}
	}
}

public sic_modereate_cmd_unmute(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33]
		read_argv(1, target, charsmax(target))
		new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			sic_moderate_mute(player, id, 0)
		}
	}
}

public sic_moderate_mute(player, id, mute)
{
	g_muted[player] = mute

	#if defined sic_userinfo_included
		new lstr_a[128], lstr_p[128]
		sic_userinfo_logstring(id, lstr_a, charsmax(lstr_a))
		sic_userinfo_logstring(player, lstr_p, charsmax(lstr_p))
		log_message("%s %smuted %s", lstr_a, mute == 0 ? "un" : "", lstr_p)
	#else
		new p_name[33], a_name[33]
		get_user_name(id, a_name, charsmax(a_name))
		get_user_name(player, p_name, charsmax(p_name))
		server_print("mute %s: %s %smuted %s", target, a_name, mute == 0 ? "un" : "", p_name)
	#endif
}

public sic_moderate_match(p_param[], pattern[], strip)
{
	new p_ret, p_error[128], p_text[128]
	copy(p_text, charsmax(p_text), p_param)
	if (strip == 1) {
		replace(p_text, charsmax(p_text), " ", "")
	}

	new Regex:p_regex = regex_match(p_text, pattern, p_ret, p_error, sizeof(p_error))
	if (p_regex >= REGEX_OK) {
		regex_free(p_regex)
		return 1
	}

	return 0
}

public sic_moderate_handle_say(id)
{
	new p_chat[128], p_param[128], lstr_p[128]
	read_args(p_param, charsmax(p_param))
	remove_quotes(p_param)

	sic_userinfo_logstring(id, lstr_p, charsmax(lstr_p))

	if (sic_moderate_match(p_param, ban_pattern, 0)) {
		if (g_chatbanned[id] != 1) {
			sic_userlist_setaccess(id, PF_MUTED | PF_BLOCKED, 0, BAN_TYPE_PERMANENT)
			g_chatbanned[id] = 1
		}

		format(p_chat, charsmax(p_chat), "CHEAT: %s", p_param)
		log_message("%s say ^"%s^"", lstr_p, p_chat)

		return PLUGIN_HANDLED
	}

	if ((g_muted[id] && !equali(p_param, "/", 1)) || sic_moderate_match(p_param, spam_pattern, 1)) {
		format(p_chat, charsmax(p_chat), "MUTED: %s", p_param)
		log_message("%s say ^"%s^"", lstr_p, p_chat)

		#if defined sic_fakechat_included
			sic_fakechat_echo(id, p_param)
		#endif

		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public sic_moderate_fm_cinfoc(id)
{
	new p_oldname[33], p_newname[33]
	pev(id, pev_netname, p_oldname, charsmax(p_oldname))
	get_user_info(id, "name", p_newname, charsmax(p_newname))

	if (!equal(p_oldname, p_newname)) {
		if (strlen(p_oldname) == 0) {
			p_oldname = server_banner_name
		}

		if (sic_moderate_match(p_newname, spam_pattern, 1)) {
			set_user_info(id, "name", p_oldname)
			sic_moderate_mute(id, 0, 1)
			return FMRES_HANDLED
		}

		if (containi(p_newname, "CHEATER") > 0) {
			return FMRES_IGNORED
		}

		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}
