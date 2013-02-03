#include <amxmodx>

// meta

#define PLUGIN_NAME		"Chat Logger"
#define PLUGIN_VERSION	"0.56"
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-CHL- Chat Logger loaded"

// constants

#define CHAT_LOG_PATH	"addons/amxmodx/logs/chatlog.txt"

// globals

// registered commands

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_clcmd("say", "cmd_say")

	log_message(BANNER)
}

// access to globals

// =========================================================
// =========================================================
// =========================================================

public cmd_say(id) {
	new p_param[255], p_name[32]
	read_args(p_param, sizeof(p_param)-1)
	get_user_name(id, p_name, sizeof(p_name)-1)
	log_to_file(CHAT_LOG_PATH, "%s: %s", p_name, p_param)

	return PLUGIN_CONTINUE
}

