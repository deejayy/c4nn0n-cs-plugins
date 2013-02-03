public sic_setfov(id, p_target[32], p_fov_value[32]) {
	new p_id, p_fov

	p_id = cmd_target(id, p_target, 8)
	p_fov = str_to_num(p_fov_value)
	if (p_id > 0 && p_fov > 45 && p_fov < 235) {
		message_begin(MSG_ONE, get_user_msgid("SetFOV"), {0, 0, 0}, p_id)
		write_byte(p_fov)
		message_end()
	}
}

public sic_fakechat_do(p_name[], p_text[]) {
	if (!equal(p_text,"")) {
		fakechat(p_name, p_text)
		server_print("%s : %s", p_name, p_text)
	} else {
		server_print("Empty text!")
	}
}

public strip_setinfo(id) {
	client_cmd(id, "setinfo %s ^"^"", "bottomcolor")
	client_cmd(id, "setinfo %s ^"^"", "cl_dlmax")
	client_cmd(id, "setinfo %s ^"^"", "cl_lc")
	client_cmd(id, "setinfo %s ^"^"", "cl_lw")
	client_cmd(id, "setinfo %s ^"^"", "model")
	client_cmd(id, "setinfo %s ^"^"", "topcolor")
	client_cmd(id, "setinfo %s ^"^"", "_ah")
	client_cmd(id, "setinfo %s ^"^"", "_gmprof")
	client_cmd(id, "setinfo %s ^"^"", "lang")
}
