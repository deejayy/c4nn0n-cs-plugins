#if defined fp_fakechat_included
    #endinput
#endif

#define fp_fakechat_included

enum _:fch_colors
{
	CC_RESET = 1,
	CC_NOTUSED,
	CC_TEAM,
	CC_GREEN
}

public plugin_init_fakechat()
{
	register_srvcmd("pmsg", "fch_privmsg")
	register_srvcmd("gmsg", "fch_globalmsg")
	register_srvcmd("vs",   "fch_globalmsg")
}

public fch_colormessage(id, color, text[], any:...)
{
	new p_message[255]
	vformat(p_message[1], charsmax(p_message)-1, text, 4)

	p_message[0] = color

	fch_directmessage(id, p_message)
}

public fch_directmessage(id, text[], any:...)
{
	new p_message[255]
	vformat(p_message, charsmax(p_message), text, 3)

	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("SayText"), _, id)
	write_byte(id ? id : 1)
	write_string(p_message)
	message_end()
}

public fch_getstatus(id, p_stat[17])
{
	new CsTeams:p_team

	if (!is_user_alive(id)) {
		p_stat = "*DEAD* "
	}

	if (is_user_connected(id)) {
		p_team = cs_get_user_team(id)
		if (p_team == CS_TEAM_SPECTATOR) {
			p_stat = "*SPEC* "
		}
	}
}

public fch_echo(id, p_param[])
{
	new p_name[33], p_stat[17]
	get_user_name(id, p_name, charsmax(p_name))

	fch_getstatus(id, p_stat);

	fch_directmessage(id, "^x01%s^x03%s^x01 :  %s", p_stat, p_name, p_param)
}

public fch_privmsg(id)
{
	new sender[33], target[33], text[255]
	read_argv(1, sender, charsmax(sender))
	read_argv(2, target, charsmax(target))
	read_argv(3, text, charsmax(text))
	if (!equali(sender, "") && !equali(target, "") && !equali(text, "")) {
		new player = cmd_target(id, target)
		if (player) {
			fch_directmessage(player, "^x01*ADMIN* ^x03%s^x01 :  %s", sender, text)
		}
	}
}

public fch_globalmsg(id)
{
	new sender[33], text[255]
	read_argv(1, sender, charsmax(sender))
	read_argv(2, text, charsmax(text))
	if (!equali(sender, "") && !equali(text, "")) {
		fch_directmessage(0, "^x01*ADMIN* ^x03%s^x01 :  %s", sender, text)
	}
}
