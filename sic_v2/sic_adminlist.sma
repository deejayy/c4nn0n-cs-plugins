// Admin list

#if defined sic_adminlist_included
    #endinput
#endif

#define sic_adminlist_included

// cmd_sic_admin_list = 0: dont list, 1: list only number of admins, 2: list admin names
#define cmd_sic_admin_list "sic_adminspotting"

public sic_adminlist_plugin_init()
{
	register_clcmd("say /admin",     "sic_adminlist_cmd_adminlist")
	register_clcmd("say /admins",    "sic_adminlist_cmd_adminlist")
	register_clcmd("say /adminlist", "sic_adminlist_cmd_adminlist")
	register_clcmd("say admins",     "sic_adminlist_cmd_adminlist")
	register_clcmd("say adminlist",  "sic_adminlist_cmd_adminlist")

	register_cvar(cmd_sic_admin_list, "1")

	register_dictionary("sic_adminlist.txt")
}

public sic_adminlist_cmd_adminlist(id)
{
	new p_listtype = get_cvar_num(cmd_sic_admin_list)

	if (p_listtype > 0) {
		if (p_listtype == 1) {
			#if defined sic_announce_included
				sic_announce(id, "%L", LANG_PLAYER, "ADMINS_ONLINE", 1)
			#elseif
				client_print(id, print_chat, "%L", LANG_PLAYER, "ADMINS_ONLINE", 1)
			#endif
		}
		if (p_listtype == 2) {
			// TODO: collect the real list
			#if defined sic_announce_included
				sic_announce(id, "%L", LANG_PLAYER, "ADMINS_ONLINE_LIST", "a, b, c")
			#elseif
				client_print(id, print_chat, "%L", LANG_PLAYER, "ADMINS_ONLINE_LIST", "a, b, c")
			#endif
		}
	}

	return PLUGIN_CONTINUE
}
