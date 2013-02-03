public fakechat(p_name[], text[]) {
	new output[255], players[32], num_players, i
	format(output, sizeof(output)-1, "^x03%s^x01 : %s", p_name, text)

	get_players(players, num_players, "")
	for (i=0; i<num_players; i++) {
		message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, players[i])
		write_byte(players[i])
		write_string(output)
		message_end()
	}

	return PLUGIN_HANDLED
}

public fakechat_to(id, text[]) {
	new output[255]
	format(output, sizeof(output)-1, "^x03%s", text)

	message_begin(MSG_ONE, get_user_msgid("SayText"), {0,0,0}, id)
	write_byte(id)
	write_string(output)
	message_end()

	return PLUGIN_HANDLED
}

