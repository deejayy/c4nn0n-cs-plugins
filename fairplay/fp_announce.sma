// Announce

#if defined fp_announce_included
    #endinput
#endif

#define fp_announce_included

#define cvar_ann_announce_time         "ann_announce_holdtime"
#define const_ann_announce_position   0.72
#define const_ann_announce_increment  0.04
#define const_ann_announce_fadeout    1.0

new g_announce_reset_task          = 75201
new Float:g_announce_position      = const_ann_announce_position
new Float:g_announce_increment     = const_ann_announce_increment
new Float:g_announce_positions[33] = { const_ann_announce_position, ... }

stock plugin_init_announce(taskinc = 0)
{
	register_cvar(cvar_ann_announce_time, "3.0")
	g_announce_reset_task += taskinc;
	set_task(get_cvar_float(cvar_ann_announce_time) + const_ann_announce_fadeout + 1.0, "ann_announce_resetposition", g_announce_reset_task, "", 0, "b")
}

public ann_announce_color(red, green, blue, id, text[], any:...)
{
	new p_text[255]
	vformat(p_text, charsmax(p_text), text, 6)

	set_dhudmessage(red, green, blue, -1.0, g_announce_positions[id], 0, 0.1, cvar_exists(cvar_ann_announce_time) ? get_cvar_float(cvar_ann_announce_time) : 3.0, 0.1, const_ann_announce_fadeout)
	show_dhudmessage(id, p_text)
	show_dhudmessage(id, p_text)
	show_dhudmessage(id, p_text)
	if (task_exists(g_announce_reset_task)) {
		g_announce_positions[id] += g_announce_increment
	}

	fch_colormessage(id, CC_GREEN, p_text)
}

public ann_announce(id, text[], any:...)
{
	new p_text[255]
	vformat(p_text, charsmax(p_text), text, 3)

	ann_announce_color(255, 100, 0, id, p_text)
}

public ann_announce_red(id, text[], any:...)
{
	new p_text[255]
	vformat(p_text, charsmax(p_text), text, 3)

	ann_announce_color(255, 0, 0, id, p_text)
}

public ann_announce_blue(id, text[], any:...)
{
	new p_text[255]
	vformat(p_text, charsmax(p_text), text, 3)

	ann_announce_color(0, 0, 255, id, p_text)
}

public ann_announce_resetposition()
{
	for (new i = 0; i < sizeof(g_announce_positions); i++) {
		g_announce_positions[i] = g_announce_position
	}
}
