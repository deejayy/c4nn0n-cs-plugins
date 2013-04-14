// Menu

#if defined sic_menu_included
    #endinput
#endif

#define sic_menu_included

new g_observed[33]
new g_specmenu[33]

public sic_menu_plugin_init()
{
	register_clcmd("sic_specmenu", "sic_menu_specmenu", ADMIN_BAN, " - display spectator menu")
	register_menucmd(register_menuid("Spec Menu"), (2 << 9) - 1, "sic_menu_handle")
	register_event("SpecHealth2", "sic_menu_specchange", "bd")
}

public sic_menu_specmenu(id)
{
	sic_menu_display(id)
}

public sic_menu_display(id)
{
	g_specmenu[id] = 1
	if (access(id, ADMIN_BAN)) {
		new p_menutext[255] = "", keys = (2 << 9) - 1
		new p_name[33]

		get_user_name(g_observed[id], p_name, charsmax(p_name))

		format(p_menutext, charsmax(p_menutext), "%s%s%s", p_menutext, "\rMegfigyelve:\w ", p_name)
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w1.\y Ban 45 percre")
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w2.\y Quit parancs")
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w3.\y Permban (block shoot + mute)")
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w4.\y Megsem punish")
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w5.\y Blockshoot + egerstop")
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n^n^n\w8.\y Destroy")

		show_menu(id, keys, p_menutext, -1, "Spec Menu")
	}
}

public sic_menu_handle(id, key)
{
	new redisplay = 0

	if (access(id, ADMIN_BAN)) {
		new target = g_observed[id]
		switch (key) {
			case 0: {
				sic_userlist_setaccess(target, PF_BANNED, 45, BAN_TYPE_PERMANENT)
			}
			case 1: {
				client_cmd(target, "quit")
			}
			case 2: {
				// TODO: cheater announce, vadaszat
				sic_userlist_setaccess(target, PF_MUTED | PF_BLOCKED, 0, BAN_TYPE_PERMANENT)
				client_cmd(target, "m_yaw 0.022")
			}
			case 4: {
				if (g_shootblocked[target]) {
					sic_blockshoot_player(target, id, 0)
					client_cmd(target, "m_yaw 0.022")
				} else {
					sic_blockshoot_player(target, id, 1)
					client_cmd(target, "m_yaw 0.001")
				}
				redisplay = 1
			}
			case 7: {
				sic_userlist_setaccess(target, PF_MUTED | PF_BLOCKED, 0, BAN_TYPE_PERMANENT)
				sic_userlist_nuke(target, id)
			}
			default: {
				//
			}
		}
		if (redisplay) {
			sic_menu_display(id)
		} else {
			g_specmenu[id] = 0
		}
	}

	return PLUGIN_HANDLED
}

public sic_menu_specchange(id) {
	new p_id = read_data(2)
	g_observed[id] = p_id
	if (g_specmenu[id]) {
		sic_menu_display(id)
	}
}

public sic_menu_client_disconnect(id)
{
	for (new i = 0; i < 32; i++) {
		if (g_observed[i] == id && g_specmenu[i]) {
			if (is_user_connected(i)) {
				client_cmd(i, "slot10")
			}
		}
	}
}
