// User info

#if defined sic_loghandle_included
    #endinput
#endif

#define sic_loghandle_included

public sic_loghandle_plugin_log() {
	new message[255]

	read_logdata(message, sizeof(message)-1)

	if (contain(message, " attacked ") != -1 || contain(message, " killed ") != -1 || contain(message, " entered the game") != -1 || contain(message, " disconnected") != -1) {
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}
