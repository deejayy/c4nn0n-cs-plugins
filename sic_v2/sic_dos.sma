#if defined sic_dos_included
    #endinput
#endif

#define sic_dos_included

#define sic_dos_connect_limit 12
#define sic_dos_timeout       45

new Trie:g_ipflood

public sic_dos_plugin_init()
{
	g_ipflood  = TrieCreate()
	set_task(30.0, "sic_dos_reset_connects", 74204, "", 0, "b", 0)
}

public sic_dos_client_connect(id)
{
	new ip[32], num = 0
	get_user_ip(id, ip, charsmax(ip), 1)
	if (TrieKeyExists(g_ipflood, ip)) {
		TrieGetCell(g_ipflood, ip, num)
	}
	num++
	if (num > sic_dos_connect_limit) {
		log_message("Connect flood detected, DoS attempt from: %s", ip)
		server_cmd("addip %d %s", sic_dos_timeout, ip)
	}
	if (!equal(ip, "127.0.0.1")) {
		TrieSetCell(g_ipflood, ip, num)
	}
}

public sic_dos_reset_connects()
{
	TrieDestroy(g_ipflood)
	g_ipflood  = TrieCreate()
}
