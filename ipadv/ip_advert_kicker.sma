#include <amxmodx>
#include <amxmisc>
#include <string>
#include <regex>

// meta

#define PLUGIN_NAME		"Message Advertisement filter"
#define PLUGIN_VERSION	"0.61"
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-MAF- Message Advertisement filter loaded"

// constants

#define SPAM_PATTERN	"[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|2[6-9][0-9][0-9][0-9]|\.com|\.net|\.hu|\.COM|\.NET|\.HU\|\.org|\.ORG"
#define EXCEPT_PATTERN	"193\.224\.130\.151|193\.224\.130\.190"
#define BAN_PATTERN		"BaDBoY.*Private.*Frags.*Deaths.*HS|CREATED BY M.F1A AND DARKTEAM|BaDBoY.*united-cheaters"
#define TARGET_SERVER	"193.224.130.151:27050"
#define SPAM_MESSAGES	12

new spam_replace[SPAM_MESSAGES][64] = {
	"[C4nn0N] public steames: 193.224.130.151:27015",
	"gyertek ide is: C4nn0N klanszero! 193.224.130.151:27015",
	"kedvenc szerverem a C4nn0N: 193.224.130.151:27015",
	"a reklam helye: C4nn0N klanszerver 193.224.130.151:27015",
	"konzolba: connect 193.224.130.151:27015",
	"C4nn0N steames szerver: 193.224.130.151:27015",
	"fejlesztes alatt a C4nn0N klanszerver: 193.224.130.151:27015",
	"jatekos hent !! 193.224.130.151:27015",
	"player felvetel :D 193.224.130.151:27015 (C4nn0N)",
	"menjunk at a masikra: 193.224.130.151:27015 (C4nn0N)",
	"jo ez a szero, ide maskor is jovok",
	"mindjart hivom a haverokat is ide"
}

// globals

new g_spammed[33]
new g_muted[33]
new g_spammer[33]

// registered commands

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_clcmd("say", "cmd_say")
	register_clcmd("say_team", "cmd_say")
	register_concmd("mute", "cmd_mute", ADMIN_KICK, "- letiltja a chatet a felhasznalonak")
	register_concmd("kuss", "cmd_mute", ADMIN_KICK, "- letiltja a chatet a felhasznalonak")

	register_message(get_user_msgid("SayText"), "msg_blocknamechange");

	log_message(BANNER)
}

// access to globals

// on client connect

public client_putinserver(id) {
	g_spammed[id]	= 0
	g_muted[id] = 0
}

public client_disconnect(id) {
	g_spammed[id]	= 0
	g_muted[id] = 0
}

// =========================================================
// =========================================================
// =========================================================

public cmd_say(id) {
	new Regex:p_regex, p_ret, p_error[64], p_param[255], p_orig_param[255], p_name[33]
	read_args(p_param, sizeof(p_param)-1)
	remove_quotes(p_param)

	copy(p_orig_param, sizeof(p_orig_param)-1, p_param)
	replace(p_param, sizeof(p_param)-1, " ", "")

	get_user_name(id, p_name, charsmax(p_name))
	new uid = get_user_userid(id)

	p_regex = regex_match(p_param, SPAM_PATTERN, p_ret, p_error, sizeof(p_error))
	if (p_regex >= REGEX_OK) {
		regex_free(p_regex)
		p_regex = regex_match(p_param, EXCEPT_PATTERN, p_ret, p_error, sizeof(p_error))
		if (p_regex >= REGEX_OK) {
			return PLUGIN_CONTINUE
		} else {
			g_spammed[id] += 1
			// client_cmd(id, "say ^"%s^"", spam_replace[random_num(0, SPAM_MESSAGES)]) // rewrite user's message
			fakechat(id, p_orig_param) // fake chat only for the player
			server_print("%s is spamming: %s", p_name, p_orig_param)
			return PLUGIN_HANDLED
		}
	}

	p_regex = regex_match(p_param, BAN_PATTERN, p_ret, p_error, sizeof(p_error))
	if (p_regex >= REGEX_OK && !g_muted[id]) {
		server_cmd("sic_punish #%d", uid)
	}

	if (g_muted[id] && !equali(p_param,"/",1)) {
		server_print("*MUTED* %s: %s", p_name, p_orig_param)
		fakechat(id, p_orig_param) // fake chat only for the player
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public cmd_mute(id, level, cid) {
	if (cmd_access(id, level, cid, 1)) {
		new arg[32]
		read_argv(1, arg, charsmax(arg))
		new player = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			g_muted[player] = 1 - g_muted[player]
			server_print("%d %smuted %d", id, g_muted[player] ? "" : "un", player)
		}
	}
	return PLUGIN_HANDLED
}

public fakechat(id, text[]) {
	new p_name[32], output[255]
	get_user_name(id, p_name, sizeof(p_name)-1)
	format(output, sizeof(output)-1, "^x03%s^x01 :  %s", p_name, text)

	message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id)
	write_byte(id)
	write_string(output)
	message_end()
	return PLUGIN_HANDLED
}

public client_connect(id) {
	new Regex:p_regex, p_ret, p_error[64], p_name[33]

	get_user_name(id, p_name, charsmax(p_name))
	replace(p_name, sizeof(p_name)-1, " ", "")

	g_spammer[id] = 0
	p_regex = regex_match(p_name, SPAM_PATTERN, p_ret, p_error, sizeof(p_error))
	if (p_regex >= REGEX_OK) {
		server_print("Spammer joined: %s", p_name)
		client_cmd(id, "name ^"%s^"", TARGET_SERVER)
		g_muted[id] = 1
		g_spammer[id] = 1
	}
}

public msg_blocknamechange(iMsgId, iDest, iReceiver) {
	static szMessage[255], pNewname[255]
	get_msg_arg_string(2, szMessage, sizeof( szMessage ) - 1)

	if (equal(szMessage, "#Cstrike_Name_Change")) {
		get_msg_arg_string(4, pNewname, charsmax(pNewname))
		if (containi(pNewname, "egy senkihazi csiter vagyok")) {
			return PLUGIN_HANDLED
		}
	}

	return PLUGIN_CONTINUE
}

public client_infochanged(id) {
	new Regex:p_regex, p_ret, p_error[64], p_name_new[33], p_name_old[32]

	get_user_info(id, "name", p_name_new, charsmax(p_name_new))
	get_user_name(id, p_name_old, charsmax(p_name_old))

	if(!equal(p_name_new, p_name_old) && !equal(p_name_new, TARGET_SERVER)) {
		p_regex = regex_match(p_name_new, SPAM_PATTERN, p_ret, p_error, sizeof(p_error))
		if (p_regex >= REGEX_OK) {
			server_print("Spammer tries to get a new name: %s", p_name_new)
			client_cmd(id, "name ^"%s^"", p_name_old)
			g_muted[id] = 1
			g_spammer[id] = 1
		}
	}
	return PLUGIN_CONTINUE
}
