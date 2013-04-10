// Admin commands

#if defined sic_admin_included
    #endinput
#endif

#define sic_admin_included

public sic_admin_plugin_init()
{
	register_concmd("spn",   "sic_admin_punish",     ADMIN_RCON, "- punish: mute + shootblock, permanent")
	register_concmd("cname", "sic_admin_changename", ADMIN_BAN,  "- nevvaltas")
}

public sic_admin_punish(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33]
		read_argv(1, target, charsmax(target))
		new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			sic_userlist_setaccess(player, PF_MUTED | PF_BLOCKED, 0, BAN_TYPE_PERMANENT)
		}
	}
}

public sic_admin_changename(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], newname[33]
		read_argv(1, target, charsmax(target))
		read_argv(2, newname, charsmax(newname))
		new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			set_user_info(player, "name", newname)
		}
	}
}
