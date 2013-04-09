#if defined sic_blockshoot_included
    #endinput
#endif

#define sic_blockshoot_included

#include <fakemeta>

new g_shootblocked[33]

public sic_blockshoot_plugin_init()
{
	register_concmd("bsh",   "sic_blockshoot_set",   ADMIN_RCON, "- blokkolja egy jatekos loveseit")
	register_concmd("unbsh", "sic_blockshoot_unset", ADMIN_RCON, "- engedelyezi egy jatekos loveseit")

	register_forward(FM_CmdStart, "sic_blockshoot_forward")
}

public sic_blockshoot_client_connect(id)
{
	g_shootblocked[id] = 0
}

public sic_blockshoot_forward(id, uc_handle, seed)
{
	if (is_user_alive(id)) {
		static btn
		btn = get_uc(uc_handle, UC_Buttons)
		if (g_shootblocked[id]) {
			if (btn & IN_ATTACK) {
				btn &= ~IN_ATTACK
				set_uc(uc_handle, UC_Buttons, btn)
			}
			if (btn & IN_ATTACK2) {
				btn &= ~IN_ATTACK2
				set_uc(uc_handle, UC_Buttons, btn)
			}
		}
	}

	return FMRES_IGNORED
}

public sic_blockshoot_set(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33]
		read_argv(1, target, charsmax(target))
		new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			sic_blockshoot_player(player, id, 1)
		}
	}
}

public sic_blockshoot_unset(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33]
		read_argv(1, target, charsmax(target))
		new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			sic_blockshoot_player(player, id, 0)
		}
	}
}

public sic_blockshoot_player(player, id, type)
{
	g_shootblocked[player] = type
	#if defined sic_userinfo_included
		new lstr_a[128], lstr_p[128]
		sic_userinfo_logstring(id, lstr_a, charsmax(lstr_a))
		sic_userinfo_logstring(player, lstr_p, charsmax(lstr_p))
		log_message("%s %sshootblocked %s", lstr_a, type == 0 ? "un" : "", lstr_p)
	#else
		new p_name[33], a_name[33]
		get_user_name(id, a_name, charsmax(a_name))
		get_user_name(player, p_name, charsmax(p_name))
		server_print("shootblock %s: %s %sshootblocked %s", target, a_name, type == 0 ? "un" : "", p_name)
	#endif
}
