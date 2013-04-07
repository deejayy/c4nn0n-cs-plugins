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

	message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id)
	write_byte(id)
	write_string(p_message)
	message_end()
}
