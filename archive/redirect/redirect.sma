#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>

// meta

#define PLUGIN_NAME     "Redirect"
#define PLUGIN_VERSION  "0.57b.2"
#define PLUGIN_AUTHOR   "deejayy"

#define DESTINATION		"193.224.130.190:27015"

#define BANNER          "-RDR- Redirect loaded..."

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	set_task(30.0, "tsk_fakeplayers", 123096, "", 0, "b", 0);

	log_message(BANNER)
}

public tsk_fakeplayers() {
	server_cmd("ff_players %d", random_num(11,19))
}

public client_connect(id) {
//	server_print("client connected: %d", id)
	client_cmd(id, "Connect %s", DESTINATION)
}

public client_putinserver(id) {
//	server_print("client putinserver: %d", id)
	client_cmd(id, "Connect %s", DESTINATION)
}

public client_authorized(id) {
//	server_print("client authorized: %d", id)
	client_cmd(id, "Connect %s", DESTINATION)
}
