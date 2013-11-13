#if defined fp_menu_included
    #endinput
#endif

#define fp_menu_included

new g_observed[33]
new g_specmenu[33]

public plugin_init_menu()
{
	register_clcmd("mnu_specmenu", "mnu_specmenu", ADMIN_BAN, " - display spectator menu");
	register_event("SpecHealth2", "mnu_specchange", "bd");

	register_menucmd(register_menuid("Spec Menu"), (2 << 9) - 1, "mnu_handle");
}

public mnu_specmenu(id)
{
	mnu_display(id);
}

public mnu_display(id)
{
	g_specmenu[id] = 1
	if (access(id, ADMIN_BAN)) {
		new p_menutext[255] = "", keys = (2 << 9) - 1;
		new p_name[33];

		get_user_name(g_observed[id], p_name, charsmax(p_name));

		format(p_menutext, charsmax(p_menutext), "%s%s%s", p_menutext, "\rMegfigyelve:\w ", p_name);
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w1.\y Ban 45 percre");
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w2.\y Quit parancs");
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w3.\y Permban (block shoot + mute)");
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w4.\y Megsem punish");
		format(p_menutext, charsmax(p_menutext), "%s%s",   p_menutext, "^n\w5.\y Blockshoot + egerstop");

		show_menu(id, keys, p_menutext, -1, "Spec Menu");
	}
}

public mnu_handle(id, key)
{
	new redisplay = 0;

	if (access(id, ADMIN_BAN)) {
		new target = g_observed[id];
		switch (key) {
			case 0: {
				cmd_fp_ban(target, "Pihnej egy kicsit", id);
			}
			case 1: {
				cmd_fp_exec(target, "quit", id);
			}
			case 2: {
				client_cmd(target, "m_yaw 0.022");
				cmd_fp_punish(target, "Nem cheatelsz tobbet. (4)", id);
			}
			case 4: {
				if (blk_get_blocked(target)) {
					cmd_fp_unblock(target, id);
					cmd_fp_exec(target, "m_yaw 0.022", id);
				} else {
					cmd_fp_block(target, id);
					cmd_fp_exec(target, "m_yaw 0.001", id);
				}
				redisplay = 1;
			}
			default: {
				
			}
		}
		if (redisplay) {
			mnu_display(id);
		} else {
			g_specmenu[id] = 0;
		}
	}

	return PLUGIN_HANDLED;
}

public mnu_specchange(id)
{
	new p_id = read_data(2);
	g_observed[id] = p_id;
	if (g_specmenu[id]) {
		mnu_display(id);
	}
}

public client_disconnect_menu(id)
{
	for (new i = 0; i < 32; i++) {
		if (g_observed[i] == id && g_specmenu[i]) {
			if (is_user_connected(i)) {
				cmd_fp_exec(id, "slot10", i);
			}
		}
	}
}
