#if defined fp_commands_included
    #endinput
#endif

#define fp_commands_included

#define BAN_REASON "Ki vagy tiltva innen / You are banned. Tovabbi info: http://csdm-hu.sytes.net/"

new g_hunter[33];

plugin_init_commands()
{
	register_concmd("fp_mute",    "cmd_fp_mute_command",    ADMIN_RCON, "");
	register_concmd("fp_unmute",  "cmd_fp_unmute_command",  ADMIN_RCON, "");
	register_concmd("fp_block",   "cmd_fp_block_command",   ADMIN_RCON, "");
	register_concmd("fp_unblock", "cmd_fp_unblock_command", ADMIN_RCON, "");
	register_concmd("fp_kick",    "cmd_fp_kick_command",    ADMIN_RCON, "");
	register_concmd("fp_immune",  "cmd_fp_immune_command",  ADMIN_RCON, "");

	register_concmd("fp_pmute",   "cmd_fp_mute_permanent_command",   ADMIN_RCON, "");
	register_concmd("fp_pblock",  "cmd_fp_block_permanent_command",  ADMIN_RCON, "");
	register_concmd("fp_pkick",   "cmd_fp_ban_command",              ADMIN_RCON, "");
	register_concmd("fp_ban",     "cmd_fp_ban_command",              ADMIN_RCON, "");
	register_concmd("fp_pimmune", "cmd_fp_immune_permanent_command", ADMIN_RCON, "");

	register_concmd("fp_punish",  "cmd_fp_punish_command",     ADMIN_RCON, "");
	register_concmd("fp_exec",    "cmd_fp_exec_command",       ADMIN_RCON, "");
	register_concmd("fp_cname",   "cmd_fp_changename_command", ADMIN_RCON, "");

	// backward compatibility for sic v1.42 irc gw
	register_concmd("bsh",        "cmd_fp_block_command",   ADMIN_RCON, "");
	register_concmd("unbsh",      "cmd_fp_unblock_command", ADMIN_RCON, "");
	register_concmd("mute",       "cmd_fp_mute_command",    ADMIN_RCON, "");
	register_concmd("unmute",     "cmd_fp_unmute_command",  ADMIN_RCON, "");
	register_concmd("spn",        "cmd_fp_punish_command",     ADMIN_RCON, "");
	register_concmd("cexec",      "cmd_fp_exec_command",       ADMIN_RCON, "");
	register_concmd("cname",      "cmd_fp_changename_command", ADMIN_RCON, "");
	register_concmd("hideme",     "cmd_fp_hideme", ADMIN_BAN, "");
}

public client_connect_commands(id)
{
	g_hunter[id] = 0;
}

public client_disconnect_commands(id)
{
	g_hunter[id] = 0;
}

public cmd_fp_hideme(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		client_print(id, print_chat, "inviso on, silent step on, speed on");
//		set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0);
		set_user_rendering(id, kRenderFxGlowShell, 255, 0, 0, kRenderTransAdd, 0);
		entity_set_int(id, EV_INT_flTimeStepSound, 999);
		set_user_maxspeed(id, 800.0);
// 		set_user_gravity(id, 200.0);
	} else {
		client_print(id, print_chat, "no access");
	}
}

public cmd_fp_mute_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_mute(player, id);
		}
	}
}

public cmd_fp_unmute_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_unmute(player, id);
		}
	}
}

public cmd_fp_block_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_block(player, id);
		}
	}
}

public cmd_fp_unblock_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_unblock(player, id);
		}
	}
}

public cmd_fp_kick_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_kick(player, reason, id);
		}
	}
}

public cmd_fp_mute_permanent_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_mute_permanent(player, reason, id);
		}
	}
}

public cmd_fp_immune_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33];
		read_argv(1, target, charsmax(target));
		new player = cmd_target(id, target);
		if (player) {
			cmd_fp_immune(player, id);
		}
	}
}

public cmd_fp_immune(id, admin_id)
{
	log_message_user2(admin_id, id, "set immunity", "");
	uf_set_immunity(id, 1);
}

public cmd_fp_kick(id, reason[], admin_id)
{
	new uid = get_user_userid(id);
	log_message_user2(admin_id, id, "kicked", "(reason ^"%s^")", reason);
	server_cmd("kick #%d ^"%s^"", uid, reason);
}

public cmd_fp_mute(id, admin_id)
{
	log_message_user2(admin_id, id, "muted", "");
	mod_set_muted(id, 1);
}

public cmd_fp_unmute(id, admin_id)
{
	log_message_user2(admin_id, id, "unmuted", "");
	mod_set_muted(id, 0);
}

public cmd_fp_block(id, admin_id)
{
	log_message_user2(admin_id, id, "shootblocked", "");
	blk_set_blocked(id, 1);
}

public cmd_fp_unblock(id, admin_id)
{
	log_message_user2(admin_id, id, "unshootblocked", "");
	blk_set_blocked(id, 0);
}

public cmd_fp_block_permanent_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_block_permanent(player, reason, id);
		}
	}
}

public cmd_fp_ban_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_ban(player, reason, id);
		}
	}
}

public cmd_fp_immune_permanent_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_immune_permanent(player, reason, id);
		}
	}
}

public cmd_fp_punish_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], reason[256];
		read_argv(1, target, charsmax(target));
		read_argv(2, reason, charsmax(reason));
		remove_quotes(reason);
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF);
		if (player) {
			cmd_fp_punish(player, reason, id);
		}
	}
}

public cmd_fp_changename_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], newname[33]
		read_argv(1, target, charsmax(target))
		read_argv(2, newname, charsmax(newname))
		new player = cmd_target(id, target, CMDTARGET_ALLOW_SELF)
		if (player) {
			cmd_fp_changename(player, newname);
		}
	}
}

public cmd_fp_exec_command(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		new target[33], command[33]
		read_argv(1, target, charsmax(target))
		read_argv(2, command, charsmax(command))
		new player = cmd_target(id, target, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
		if (player) {
			cmd_fp_exec(player, command, id)
		}
	}
}

public cmd_fp_changename(id, newname[])
{
	client_cmd(id, "name ^"%s^"", newname);
	set_user_info(id, "name", newname);
}

public cmd_fp_exec(id, command[], admin_id)
{
	log_message_user2(admin_id, id, "client command", "(command ^"%s^")", command);
	client_cmd(id, command);
}

public cmd_fp_mute_permanent(id, reason[], admin_id)
{
	log_message_user2(admin_id, id, "mute permanent", "(reason ^"%s^")", reason);
	uf_write_userflag(id, {1,1,1,1}, {45,0,0,45}, reason[0] ? reason : "Permanent mute (requested)", admin_id);
}

public cmd_fp_block_permanent(id, reason[], admin_id)
{
	log_message_user2(admin_id, id, "block permanent", "(reason ^"%s^")", reason);
	uf_write_userflag(id, {2,2,2,2}, {45,0,0,45}, reason[0] ? reason : "Shootblocked (requested)", admin_id);
}

public cmd_fp_ban(id, reason[], admin_id)
{
	log_message_user2(admin_id, id, "banned", "(reason ^"%s^")", reason);
	uf_write_userflag(id, {4,4,4,4}, {45,45,45,45}, reason[0] ? reason : BAN_REASON, admin_id);
	cmd_fp_kick(id, reason[0] ? reason : BAN_REASON, admin_id);
}

public cmd_fp_immune_permanent(id, reason[], admin_id)
{
	log_message_user2(admin_id, id, "immune permanent", "(reason ^"%s^")", reason);
	uf_write_userflag(id, {0,8,0,0}, {0,0,0,0}, reason[0] ? reason : "VIP", admin_id);
}

public cmd_fp_punish(id, reason[], admin_id)
{
	log_message_user2(admin_id, id, "punished", "(reason ^"%s^")", reason);
	uf_write_userflag(id, {3,3,3,3}, {600,0,0,600}, reason[0] ? reason : "Punished (requested)", admin_id);
	cmd_fp_ban(id, reason, admin_id);
//		fch_colormessage(0, 4, "-! CHEATER BANNOLVA:^x01 <subject name here> (jutalom: ^x04vaktoltenyes orok ban^x01)");
//		client_print(0, print_console, "CHEATER: <subject name here>, <steam_id>");
}
