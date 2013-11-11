#if defined fp_block_included
    #endinput
#endif

#define fp_block_included

new g_blocked[33];

public blk_get_blocked(id)
{
	return g_blocked[id];
}

public blk_set_blocked(id, value)
{
	g_blocked[id] = value;
}

public plugin_init_block()
{
	RegisterHam(Ham_TakeDamage, "player", "blk_takedamage");
}

public client_connect_block(id)
{
	blk_set_blocked(id, 0);
}

public blk_takedamage(victim, inflictor, attacker, Float:dmg, dmgbits)
{
	if (is_user_alive(attacker)) {
		if (blk_get_blocked(attacker)) {
			SetHamParamFloat(4, 0.0);
		}
	}
}
