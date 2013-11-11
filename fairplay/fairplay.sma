// Fair Play (was: Server Info Commands)

#define PLUGIN_NAME		"Fair Play"
#define PLUGIN_VERSION	"2.00a" // rewritten from scratch at 1.42, Originally: Server Info Commands
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-FPL- Fair Play loaded (SIC v3)"

#pragma dynamic			8192

#include <amxmodx>
#include <amxmisc>
#include <regex>
#include <hamsandwich>
#include <cstrike>
#include <orpheu>

#include "fp_dhudmessage.sma"
#include "fp_visible.sma"
#include "fp_common.sma"
#include "fp_db.sma"
#include "fp_userflags.sma"
#include "fp_commands.sma"
#include "fp_moderate.sma"
#include "fp_block.sma"
#include "fp_cheats.sma"
#include "fp_dos.sma"
#include "fp_fakechat.sma"
#include "fp_gospec.sma"
#include "fp_resetscore.sma"
#include "fp_announce.sma"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	log_message(BANNER);

	register_srvcmd("testfp",    "testfp");
	register_clcmd("testfp",     "testfp");
	register_clcmd("say testfp", "testfp");

	plugin_init_dos();
	plugin_init_visible();
	plugin_init_common();
	plugin_init_resetscore();
	plugin_init_gospec();
	plugin_init_commands();
	plugin_init_moderate();
	plugin_init_block();
	plugin_init_cheats();
	plugin_init_fakechat();
	plugin_init_announce(5);
}

public plugin_cfg()
{
	db_init();
}

public client_connect(id)
{
	client_connect_moderate(id);
	client_connect_block(id);
	client_connect_cheats(id);
	client_connect_dos(id);
	client_connect_common(id);
}

public client_putinserver(id)
{
	client_putinserver_userflags(id);
}

public client_disconnect(id)
{
	client_disconnect_common(id);
}

public plugin_log()
{
	return plugin_log_common();
}

public plugin_end()
{
	db_close();
}

public testfp()
{
}
