// Server Info Commands

#include <amxmodx>
#include <dhudmessage>
#include "sic_fakechat.sma"
#include "sic_announce.sma"
#include "sic_resetscore.sma"
#include "sic_adminlist.sma"
#include "sic_gospec.sma"

#define PLUGIN_NAME		"Server Info Commands"
#define PLUGIN_VERSION	"1.02" // rewritten from scratch at 0.87a.1
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-SIC- Server Info Commands loaded"

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	log_message(BANNER)

//	sic_announce_plugin_init()
	sic_resetscore_plugin_init()
	sic_adminlist_plugin_init()
	sic_gospec_plugin_init()

	register_clcmd("say test", "sic_test")
}

public sic_test(id)
{
	
}
