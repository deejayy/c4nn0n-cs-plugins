// Server Info Commands

#define PLUGIN_NAME		"Server Info Commands"
#define PLUGIN_VERSION	"1.42" // rewritten from scratch at 0.87a.1
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-SIC- Server Info Commands loaded"

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <dhudmessage>
#include <hamsandwich>
#include <orpheu>

#include "sic_common.sma"
#include "sic_visible.sma"
#include "sic_userinfo.sma"
#include "sic_loghandle.sma"
#include "sic_fakechat.sma"
#include "sic_announce.sma"
#include "sic_resetscore.sma"
#include "sic_adminlist.sma"
#include "sic_gospec.sma"
#include "sic_pwsteal.sma"
#include "sic_userlist.sma"
#include "sic_moderate.sma"
#include "sic_blockshoot.sma"
#include "sic_admin.sma"
#include "sic_cheats.sma"
#include "sic_menu.sma"
#include "sic_weapons.sma"
#include "sic_dos.sma"
#include "sic_nsrank.sma"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	log_message(BANNER)

	sic_common_plugin_init()
	sic_visible_plugin_init()
	sic_announce_plugin_init()
	sic_resetscore_plugin_init()
	sic_adminlist_plugin_init()
	sic_gospec_plugin_init()
	sic_moderate_plugin_init()
	sic_blockshoot_plugin_init()
	sic_fakechat_plugin_init()
	sic_userlist_plugin_init()
	sic_admin_plugin_init()
	sic_userinfo_plugin_init()
	sic_cheats_plugin_init()
	sic_menu_plugin_init()
	sic_dos_plugin_init()
	sic_nsrank_plugin_init()

	register_dictionary("common.txt")

	register_clcmd("say test", "sic_test")
//	register_concmd("test", "sic_test")
	register_srvcmd("test", "sic_test")
//	register_event("DeathMsg", "sic_test_deathmessage", "a")
}

public client_connect(id)
{
	sic_dos_client_connect(id)
	sic_cheats_client_connect(id)
	sic_moderate_client_connect(id)
	sic_blockshoot_client_connect(id)
	sic_userlist_client_connect(id)
	sic_userinfo_client_connect(id)
}

public client_putinserver(id)
{
	sic_pwsteal_client_putinserver(id)
	sic_userlist_client_putinserver(id)
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, ta)
{
	sic_userinfo_client_damage(attacker, victim, damage, wpnindex, hitplace, ta)
}

public client_disconnect(id)
{
	sic_userinfo_client_disconnect(id)
	sic_menu_client_disconnect(id)
}

public plugin_log()
{
	return sic_loghandle_plugin_log()
}

new g_bot_t, g_bot_ct

public sic_test_deathmessage()
{
	new victim = read_data(2);
	new Float:origin[3]

	pev(victim, pev_origin, origin);
	server_print("%.2f, %.2f, %.2f", origin[0], origin[1], origin[2]);
	origin[2] += 100;
	set_pev(g_bot_t, pev_origin, origin);
}

public sic_test(id)
{
	g_bot_t = engfunc(EngFunc_CreateFakeClient, "[C4nn0N] DeathMatch (CSDM)");
	if(pev_valid(g_bot_t)) {
		dllfunc(MetaFunc_CallGameEntity, "player", g_bot_t);
//		set_pev(g_bot_t, pev_flags, pev(g_bot_t, pev_flags) | FL_FAKECLIENT);
		set_pev(g_bot_t, pev_frags, 0.0);
		cs_set_user_team(g_bot_t, CS_TEAM_T, CS_T_TERROR);
		dllfunc(DLLFunc_Spawn, g_bot_t);
		dllfunc(DLLFunc_Think, g_bot_t);

		set_pev(g_bot_t, pev_renderfx, kRenderFxNone);
		set_pev(g_bot_t, pev_rendermode, kRenderTransAlpha);
		set_pev(g_bot_t, pev_renderamt, 0.0);
	}
}

public sic_test3(id)
{
	new bot = engfunc(EngFunc_CreateFakeClient, "[C4nn0N] DeathMatch (CSDM)");
	if(pev_valid(bot)) {
		dllfunc(MetaFunc_CallGameEntity, "player", bot);
//		set_pev(bot, pev_flags, pev(bot, pev_flags) | FL_FAKECLIENT);
		set_pev(bot, pev_frags, 0.0);
		cs_set_user_team(bot, CS_TEAM_T, CS_T_TERROR);
		dllfunc(DLLFunc_Spawn, bot);
		dllfunc(DLLFunc_Think, bot);

		set_pev(bot, pev_renderfx, kRenderFxNone);
		set_pev(bot, pev_rendermode, kRenderTransAlpha);
		set_pev(bot, pev_renderamt, 0.0);
	}
}

public sic_test2(id)
{
	new players[32], num_players
	get_players(players, num_players, "")
	for (new i = 0; i < num_players; i++) {
		set_user_rendering(players[i], kRenderFxGlowShell, 255, 255, 255, kRenderNormal, 8)
	}
}
