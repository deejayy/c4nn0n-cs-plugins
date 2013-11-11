public eventless_log(file[], message[], any:...) {
	new p_logstamp[32], p_logline[255], p_message[1024]
	format_time(p_logstamp, sizeof(p_logstamp)-1, "%Y-%m-%d %H:%M:%S^t")
	vformat(p_message, sizeof(p_message)-1, message, 3)

	format(p_logline, sizeof(p_logline)-1, "%s%s", p_logstamp, p_message)
	write_file(file, p_logline, -1)
}

public smart_log(file[], message[], any:...) {
	new p_logline[255], p_message[1024]
	vformat(p_message, sizeof(p_message)-1, message, 3)

	format(p_logline, sizeof(p_logline)-1, "%s", p_message)
	write_file(file, p_logline, -1)
}
