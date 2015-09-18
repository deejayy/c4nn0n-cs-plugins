#define PLUGIN_NAME		"dm_hangar unlock"
#define PLUGIN_VERSION	"0.57"
#define PLUGIN_AUTHOR	"deejayy.hu"

#pragma dynamic			8192

#include <amxmodx>
#include <amxmisc>
#include <engine>

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	log_message("dm_hangar unlocker initiated");
	event_unlocklevel();
}

public plugin_precache()
{
	log_message("dm_hangar unlocker precache");
}

public event_unlocklevel()
{
	new p_mapname[32], p_entid;
	get_mapname(p_mapname, 31);

	if (equali(p_mapname, "dm_hangar_beta1")) {
		log_message("DM Hangar unlocker: applying.");
		while (p_entid = find_ent_by_class(-1, "func_wall_toggle")) {
			server_print("DM Hangar unlocked: %d", p_entid);
			remove_entity(p_entid);
		}
		while (p_entid = find_ent_by_class(-1, "trigger_hurt")) {
			server_print("DM Hangar unlocked: %d", p_entid);
			remove_entity(p_entid);
		}
		log_message("DM Hangar unlocker: done.");
	} else {
		log_message("DM Hangar unlocker: nothing to do");
	}
}
