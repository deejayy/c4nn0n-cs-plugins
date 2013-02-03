#include <amxmodx>
#include <sockets>
#include <cstrike>
#include <player_info>
#include <isvisible>


#define PLUGIN_NAME		"Event Forwarder"
#define PLUGIN_VERSION	"0.61a.1"
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-EVF- Event Forwarder loaded"

#define SERVER_IP		"193.224.130.151"
#define SERVER_PORT		"27050"

#define REMOTE_IP		"193.224.130.190"
#define REMOTE_URL		"/evfwd.php"
#define REMOTE_HOST		"c4nn0n.deejayy.hu"

#pragma dynamic			65536
#define BIGSTRING		8192

#define TASK_HB			1
#define TASK_HB_FREQ	7.0
#define TASK_STAT		2
#define TASK_STAT_FREQ	10.0

/* ======= globals ======= */

new g_logstamp[32]
new g_registered = 1
new g_errors = 0

new g_thdl // trace handler

/* ======= fixed events ======= */

public plugin_precache() {
    register_forward(FM_Spawn, "fw_spawn", 1)
}

public plugin_init() {
	new p_ip[64], p_port[8]
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	get_cvar_string("ip", p_ip, sizeof(p_ip)-1)
	get_cvar_string("port", p_port, sizeof(p_port)-1)
	if (equal(p_ip, SERVER_IP) && equal(p_port, SERVER_PORT)) {
		register_clcmd("say", "cmd_say")
		set_task(TASK_HB_FREQ, "heartbeat", TASK_HB, "", 0, "b")
		set_task(TASK_STAT_FREQ, "userstat", TASK_STAT, "", 0, "b")
		register_event("DeathMsg", "evt_DeathMsg", "a")
		log_message("-EVF- License OK")
	} else {
		http_send("ev=unreg")
		g_registered = 0
		log_message("-EVF- Unregistered server: %s:%s (license to: %s:%s)", p_ip, p_port, SERVER_IP, SERVER_PORT)
	}

	g_thdl = create_tr2()

	log_message(BANNER)
	http_send("ev=start")
}

public plugin_end() {
	free_tr2(g_thdl)
	http_send("ev=end")
}

public client_putinserver(id) {
	sic_pi_client_putinserver(id)
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, ta) {
	if (!is_player_visible(attacker, victim, g_thdl)) {
		sic_set_user_wallhits(attacker, sic_get_user_wallhits(attacker) + 1)
	}
}

/* ======= attached events ======= */

public cmd_say(id) {
	new p_param[255], p_name[32]
	read_args(p_param, sizeof(p_param)-1)
	get_user_name(id, p_name, sizeof(p_name)-1)

	http_send("ev=say&nick=%s&msg=%s", p_name, p_param)

	if (equali(p_param, "") || equali(p_param, "^"^"")) {
		server_print("%s: URES SAY!", p_name)
	}

	return PLUGIN_CONTINUE
}

public heartbeat() {
	http_send("ev=hb")
}

public userstat() {
	new players[32], num_players, i
	new p_map[32], p_nextmap[32], p_name[32], p_timeleft[8], p_hostname[64], p_plstat[e_si_struct]
	new p_iter[512], p_req[BIGSTRING]

	new p_player_info_int[e_pi_struct_int]
	new p_player_info_str[e_pi_struct_str][32]

	get_players(players, num_players, "")
	p_plstat[SIC_SI_TOTAL] = num_players
	p_plstat[SIC_SI_MAX] = get_maxplayers()
	for (i=0; i<num_players; i++) {
		p_player_info_int = player_info_int(players[i])
		p_player_info_str = player_info_str(players[i])
		copy(p_name, 32, p_player_info_str[SIC_PI_NAME])

		format(p_iter, sizeof(p_iter)-1, "name[%d]=%s&auth[%d]=%s&ip[%d]=%s&cl_uid[%d]=%s&uid[%d]=%d&kill[%d]=%d&death[%d]=%d&hp[%d]=%d&armor[%d]=%d&money[%d]=%d&weap[%d]=%d&clip[%d]=%d&ammo[%d]=%d&flags[%d]=%d&ping[%d]=%d&loss[%d]=%d&time[%d]=%d&team[%d]=%d&ekill[%d]=%d&edeath[%d]=%d&hs[%d]=%d&whit[%d]=%d&wkill[%d]=%d"
			, i, p_player_info_str[SIC_PI_NAME], i, p_player_info_str[SIC_PI_AUTH_ID], i, p_player_info_str[SIC_PI_IP], i, p_player_info_str[SIC_PIE_CL_UID]
			, i, p_player_info_int[SIC_PI_USER_ID], i, p_player_info_int[SIC_PI_OFRAGS], i, p_player_info_int[SIC_PI_ODEATHS], i, p_player_info_int[SIC_PI_HEALTH]
			, i, p_player_info_int[SIC_PI_ARMOR], i, p_player_info_int[SIC_PI_MONEY], i, p_player_info_int[SIC_PI_WEAPON], i, p_player_info_int[SIC_PI_CLIP]
			, i, p_player_info_int[SIC_PI_AMMO], i, p_player_info_int[SIC_PI_FLAGS], i, p_player_info_int[SIC_PI_PING], i, p_player_info_int[SIC_PI_LOSS]
			, i, p_player_info_int[SIC_PI_TIME], i, p_player_info_int[SIC_PI_TEAM], i, p_player_info_int[SIC_PI_FRAGS], i, p_player_info_int[SIC_PI_DEATHS]
			, i, p_player_info_int[SIC_PI_HEADSHOT], i, p_player_info_int[SIC_PI_WALLHITS], i, p_player_info_int[SIC_PI_WALLKILLS]
		)
		format(p_req, sizeof(p_req)-1, "%s&%s", p_req, p_iter)
	}

	get_mapname(p_map, sizeof(p_map)-1)
	get_cvar_string("amx_nextmap", p_nextmap, sizeof(p_nextmap)-1)
	get_cvar_string("amx_timeleft", p_timeleft, sizeof(p_timeleft)-1)
	get_cvar_string("hostname", p_hostname, sizeof(p_hostname)-1)

	format(p_req, sizeof(p_req)-1, "ev=stat&%s&map=%s&next=%s&tleft=%s&max=%d&host=%s", p_req, p_map, p_nextmap, p_timeleft, p_plstat[SIC_SI_MAX], p_hostname)

	http_send(p_req)
}

public fw_spawn(ent) {
	return isvisible_fw_spawn(ent)
}

public evt_DeathMsg() {
	new wpn[32]
	new killer		= read_data(1)
	new victim		= read_data(2)
	new headshot	= read_data(3)
	read_data(4, wpn, sizeof(wpn)-1)

	if (!is_player_visible(killer, victim, g_thdl)) {
		sic_set_user_wallkills(killer, sic_get_user_wallkills(killer) + 1)
	}

	if (headshot) {
		sic_set_user_headshots(killer, sic_get_user_headshots(killer) + 1)
	}

	if (killer && victim) {
		if (killer == victim) {
			sic_set_user_frags(killer, sic_get_user_frags(killer)-1)
		} else {
			sic_set_user_frags(killer, sic_get_user_frags(killer)+1)
		}
		sic_set_user_deaths(victim, sic_get_user_deaths(victim)+1)
	}
}

/* ======= helper functions ======= */

public http_send(message[], any:...) {
	new p_error, httpreq[BIGSTRING], p_message[BIGSTRING], p_message1[BIGSTRING], p_ip[64], p_port[16]
	new p_socket = socket_open(REMOTE_IP, 80, SOCKET_TCP, p_error)
	socket_change(p_socket, 500000)

	if (g_registered > 0 && g_errors < 4) {
		get_cvar_string("ip", p_ip, sizeof(p_ip)-1)
		get_cvar_string("port", p_port, sizeof(p_port)-1)
		format_time(g_logstamp, sizeof(g_logstamp)-1, "%Y-%m-%d %H:%M:%S")
		vformat(p_message1, sizeof(p_message1)-1, message, 2)
		format(p_message, sizeof(p_message)-1, "%s&sip=%s&port=%s&ts=%s", p_message1, p_ip, p_port, g_logstamp)
	
		if (p_error == 0) {
			format(httpreq, sizeof(httpreq)-1, "POST %s HTTP/1.1^nHost: %s^nContent-Type: application/x-www-form-urlencoded^nContent-Length: %d^n^n%s^n", REMOTE_URL, REMOTE_HOST, strlen(p_message), p_message)
			socket_send(p_socket, httpreq, sizeof(httpreq)-1)
			socket_close(p_socket)
		} else {
			g_errors++
			server_print("socket create error: %d, errors: %d", p_error, g_errors)
		}
	}
}

/* ======= command handlers ======= */

