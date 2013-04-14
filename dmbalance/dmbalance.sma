#include <amxmodx>
#include <cstrike>
#include <fakechat>

// meta

#define PLUGIN_NAME     "DeatchMatch Balancer"
#define PLUGIN_VERSION  "0.56"
#define PLUGIN_AUTHOR   "deejayy"

#define BANNER          "-DMB- DeatchMatch Balancer module loaded"

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

	register_event("DeathMsg", "evt_DeathMsg", "a")

	log_message(BANNER)
}

public evt_DeathMsg() {
	new wpn[32], players[32], num_players, i, CsTeams:team, stat[CsTeams]
//	new killer		= read_data(1)
	new victim		= read_data(2)
//	new headshot	= read_data(3)
	read_data(4, wpn, sizeof(wpn)-1)

	team = cs_get_user_team(victim)
	get_players(players, num_players, "")
	for (i=0; i<num_players; i++) {
		stat[cs_get_user_team(players[i])]++
	}

	if (stat[CS_TEAM_CT] - stat[CS_TEAM_T] >= 2) {
		if (team == CS_TEAM_CT) {
			cs_set_user_team(victim, CS_TEAM_T)
			fakechat_to(victim, "Mostantol TERRORISTA vagy!")
			fakechat_to(victim, "Mostantol TERRORISTA vagy!")
		}
	}

	if (stat[CS_TEAM_T] - stat[CS_TEAM_CT] >= 2) {
		if (team == CS_TEAM_T) {
			cs_set_user_team(victim, CS_TEAM_CT)
			fakechat_to(victim, "Mostantol CT vagy!")
			fakechat_to(victim, "Mostantol CT vagy!")
		}
	}
}
