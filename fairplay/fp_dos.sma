#if defined fp_dos_included
    #endinput
#endif

#define fp_dos_included

#define fp_dos_connect_limit 12
#define fp_dos_timeout       45

new Trie:g_ipflood

public plugin_init_dos()
{
	g_ipflood  = TrieCreate();
	set_task(30.0, "dos_reset_connects", 74204, "", 0, "b", 0);
}

public client_connect_dos(id)
{
	new ip[32], num = 0, auth[33];
	get_user_ip(id, ip, charsmax(ip), 1);
	get_user_authid(id, auth, charsmax(auth));
	if (TrieKeyExists(g_ipflood, ip)) {
		TrieGetCell(g_ipflood, ip, num);
	}
	num++;
	if (num > fp_dos_connect_limit) {
		log_message("Connect flood detected, DoS attempt from: %s", ip);
		server_cmd("addip %d %s", fp_dos_timeout, ip);
	}
	if (equal(auth, "STEAM_0:0:588494118")) {
		log_message("Zeals Rainbow Dash DoS attempt from: %s", ip);
		server_cmd("addip %d %s", fp_dos_timeout, ip);
	}
	if (!equal(ip, "127.0.0.1")) {
		TrieSetCell(g_ipflood, ip, num);
	}
}

public dos_reset_connects()
{
	TrieDestroy(g_ipflood);
	g_ipflood  = TrieCreate();
}
