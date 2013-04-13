// Fake chat

#if defined sic_fakechat_included
    #endinput
#endif

#define sic_fakechat_included

enum _:sic_colors
{
	CC_RESET = 1,
	CC_NOTUSED,
	CC_TEAM,
	CC_GREEN
}

public sic_fakechat_plugin_init()
{
	register_srvcmd("pmsg", "sic_fakechat_privmsg")
	register_srvcmd("gmsg", "sic_fakechat_globalmsg")
	register_srvcmd("vs",   "sic_fakechat_globalmsg")
}

public sic_colormessage(id, color, text[], any:...)
{
	new p_message[255]
	vformat(p_message[1], charsmax(p_message)-1, text, 4)

	p_message[0] = color

	sic_directmessage(id, p_message)
}

public sic_directmessage(id, text[], any:...)
{
	new p_message[255]
	vformat(p_message, charsmax(p_message), text, 3)

	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("SayText"), _, id)
	write_byte(id ? id : 1)
	write_string(p_message)
	message_end()
}

public sic_fakechat_echo(id, p_param[])
{
	new p_name[33], p_stat[17], CsTeams:p_team
	get_user_name(id, p_name, charsmax(p_name))

	if (!is_user_alive(id)) {
		p_stat = "*DEAD* "
	}

	if (is_user_connected(id)) {
		p_team = cs_get_user_team(id)
		if (p_team == CS_TEAM_SPECTATOR) {
			p_stat = "*SPEC* "
		}
	}

	sic_directmessage(id, "^x01%s^x03%s^x01 :  %s", p_stat, p_name, p_param)
}

public sic_fakechat_privmsg(id)
{
	new sender[33], target[33], text[255]
	read_argv(1, sender, charsmax(sender))
	read_argv(2, target, charsmax(target))
	read_argv(3, text, charsmax(text))
	if (!equali(sender, "") && !equali(target, "") && !equali(text, "")) {
		new player = cmd_target(id, target)
		if (player) {
			sic_directmessage(player, "^x01*ADMIN* ^x03%s^x01 :  %s", sender, text)
		}
	}
}

public sic_fakechat_globalmsg(id)
{
	new sender[33], text[255]
	read_argv(1, sender, charsmax(sender))
	read_argv(2, text, charsmax(text))
	if (!equali(sender, "") && !equali(text, "")) {
		sic_directmessage(0, "^x01*ADMIN* ^x03%s^x01 :  %s", sender, text)
	}
}
