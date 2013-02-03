#include <amxmodx>

// meta

#define PLUGIN_NAME		"Log Player IP and ID"
#define PLUGIN_VERSION	"0.56"
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-LPI- Log Player IP and ID loaded"

// constants

#define PLAYER_LOG_PATH	"addons/amxmodx/logs/players.log"
#define CLIENT_USER_ID	"cl_uid"

//

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	log_message(BANNER)
}

public client_connect(id) {
/*	new p_name[32], p_map[32], p_authid[32], p_randomid[34], p_ip[32], p_md5[32], p_line[255]

	get_user_name(id, p_name, sizeof(p_name)-1)
	get_user_authid(id, p_authid, sizeof(p_authid)-1)
	get_user_ip(id, p_ip, sizeof(p_ip)-1)
	get_mapname(p_map, sizeof(p_map)-1)
	get_user_info(id, CLIENT_USER_ID, p_randomid, sizeof(p_randomid)-1)

	if (!equal(p_authid,"BOT")) {
		if (equal(p_randomid, "")) {
			format(p_md5, sizeof(p_md5)-1, "%d.%s", random_num(10000,99999), p_ip)
			md5(p_md5, p_randomid)
			copy(p_randomid, 6, p_randomid)
			client_cmd(id, "setinfo %s %s", CLIENT_USER_ID, p_randomid)
		}
		format(p_line, sizeof(p_line)-1, "%s - %s - %s - %s - %s", p_map, p_name, p_authid, p_ip, p_randomid)
		log_to_file(PLAYER_LOG_PATH, p_line)
	}*/

	return PLUGIN_HANDLED
}
