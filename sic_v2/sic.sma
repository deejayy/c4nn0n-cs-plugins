// Server Info Commands

#define PLUGIN_NAME		"Server Info Commands"
#define PLUGIN_VERSION	"1.26" // rewritten from scratch at 0.87a.1
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-SIC- Server Info Commands loaded"

#include <amxmodx>
#include <engine>
#include <dhudmessage>
#include "sic_common.sma"
#include "sic_visible.sma"
#include "sic_userinfo.sma"
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

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	log_message(BANNER)

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

	register_dictionary("common.txt")

	register_clcmd("say test", "sic_test")
	register_srvcmd("test", "sic_test")
}

public client_connect(id)
{
//	commented out, see sic_pwsteal_client_putinserver()
//	sic_pwsteal_client_connect(id)

	sic_moderate_client_connect(id)
	sic_blockshoot_client_connect(id)
	sic_userlist_client_connect(id)
	sic_userinfo_client_connect(id)
}

public client_putinserver(id)
{
	sic_pwsteal_client_putinserver(id)
}

public client_damage(attacker, victim, damage, wpnindex, hitplace, ta)
{
	sic_userinfo_client_damage(attacker, victim, damage, wpnindex, hitplace, ta)
}

public sic_test(id)
{
	
}
