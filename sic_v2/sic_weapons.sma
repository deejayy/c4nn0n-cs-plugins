#if defined sic_weapons_included
    #endinput
#endif

#define sic_weapons_included

public sic_weapons_count(wep, team[])
{
	new players[32], num_players, p_weapons[32], num = 0, count = 0

	get_players(players, num_players, "e", team)
	for (new i = 0; i < num_players; i++) {
		num = 0
		get_user_weapons(players[i], p_weapons, num)
		for (new j = 0; j < num; j++) {
			if (p_weapons[j] == wep) {
				count++
			}
		}
	}

	return count
}
