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
	client_cmd(id, "setinfo %s ^"^"", "_ah")
	client_cmd(id, "setinfo %s ^"^"", "ah")
	client_cmd(id, "setinfo %s ^"^"", "autobind")
	client_cmd(id, "setinfo %s ^"^"", "bn_patch")
	client_cmd(id, "setinfo %s ^"^"", "bottomcolor")
	client_cmd(id, "setinfo %s ^"^"", "cheater")
	client_cmd(id, "setinfo %s ^"^"", "cl_dlmax")
	client_cmd(id, "setinfo %s ^"^"", "cl_lb")
	client_cmd(id, "setinfo %s ^"^"", "cl_lc")
	client_cmd(id, "setinfo %s ^"^"", "cl_lw")
	client_cmd(id, "setinfo %s ^"^"", "dm")
	client_cmd(id, "setinfo %s ^"^"", "dzuid")
	client_cmd(id, "setinfo %s ^"^"", "friends")
	client_cmd(id, "setinfo %s ^"^"", "gad")
	client_cmd(id, "setinfo %s ^"^"", "ghosts")
	client_cmd(id, "setinfo %s ^"^"", "_gm")
	client_cmd(id, "setinfo %s ^"^"", "_gmprof")
	client_cmd(id, "setinfo %s ^"^"", "lac_id")
	client_cmd(id, "setinfo %s ^"^"", "_lang")
	client_cmd(id, "setinfo %s ^"^"", "lang")
	client_cmd(id, "setinfo %s ^"^"", "lefthand")
	client_cmd(id, "setinfo %s ^"^"", "mID")
	client_cmd(id, "setinfo %s ^"^"", "model")
	client_cmd(id, "setinfo %s ^"^"", "mp_cnet")
	client_cmd(id, "setinfo %s ^"^"", "mp_net")
	client_cmd(id, "setinfo %s ^"^"", "nameacc")
	client_cmd(id, "setinfo %s ^"^"", "_ndmf")
	client_cmd(id, "setinfo %s ^"^"", "_ndmh")
	client_cmd(id, "setinfo %s ^"^"", "_ndms")
	client_cmd(id, "setinfo %s ^"^"", "nick_pass")
	client_cmd(id, "setinfo %s ^"^"", "quality")
	client_cmd(id, "setinfo %s ^"^"", "rhlg")
	client_cmd(id, "setinfo %s ^"^"", "_rpgm_cfg")
	client_cmd(id, "setinfo %s ^"^"", "scanner")
	client_cmd(id, "setinfo %s ^"^"", "source_models")
	client_cmd(id, "setinfo %s ^"^"", "src")
	client_cmd(id, "setinfo %s ^"^"", "status_monitor")
	client_cmd(id, "setinfo %s ^"^"", "timepass")
	client_cmd(id, "setinfo %s ^"^"", "topcolor")
	client_cmd(id, "setinfo %s ^"^"", "translit")
	client_cmd(id, "setinfo %s ^"^"", "vgui_menu")
	client_cmd(id, "setinfo %s ^"^"", "xredir")
}
