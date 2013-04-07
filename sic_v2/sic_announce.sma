// Announce

#if defined sic_announce_included
    #endinput
#endif

#define sic_announce_included

#define cvar_sic_announce_time         "sic_announce_holdtime"
#define const_sic_announce_position   0.72
#define const_sic_announce_increment  0.04
#define const_sic_announce_fadeout    1.0

new g_announce_reset_task          = 74201
new Float:g_announce_position      = const_sic_announce_position
new Float:g_announce_increment     = const_sic_announce_increment
new Float:g_announce_positions[33] = { const_sic_announce_position, ... }

public sic_announce_plugin_init()
{
	register_cvar(cvar_sic_announce_time, "3.0")
	set_task(get_cvar_float(cvar_sic_announce_time) + const_sic_announce_fadeout + 1.0, "sic_announce_resetposition", g_announce_reset_task, "", 0, "b")
}

public sic_announce(id, text[], any:...)
{
	new p_text[255]
	vformat(p_text, charsmax(p_text), text, 3)

	#if defined _dhudmessage_included
		set_dhudmessage(255, 100, 0, -1.0, g_announce_positions[id], 0, 0.1, cvar_exists(cvar_sic_announce_time) ? get_cvar_float(cvar_sic_announce_time) : 3.0, 0.1, const_sic_announce_fadeout)
		show_dhudmessage(id, p_text)
		client_print(id, print_chat, p_text)
		if (task_exists(g_announce_reset_task)) {
			g_announce_positions[id] += g_announce_increment
		}
	#else
		#if defined sic_fakechat_included
			sic_colormessage(id, CC_GREEN, p_text)
		#else
			client_print(id, print_chat, p_text)
		#endif
	#endif
}

public sic_announce_resetposition()
{
	for (new i = 0; i < sizeof(g_announce_positions); i++) {
		g_announce_positions[i] = g_announce_position
	}
}
