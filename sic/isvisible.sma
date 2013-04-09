#if defined isvisible_included
    #endinput
#endif

#define isvisible_included

#include <amxmodx>
#include <fakemeta>
#include <xs>

#define GENERAL_X_Y_SORROUNDING			18.5	// 16.0
#define CONSTANT_Z_CROUCH_UP			31.25	// 32.0
#define CONSTANT_Z_CROUCH_DOWN			17.5	// 16.0
#define CONSTANT_Z_STANDUP_UP			34.0	// 36.0
#define CONSTANT_Z_STANDUP_DOWN			35.25	// 36.0

#define GENERAL_X_Y_SORROUNDING_HALF	9.25	// 8.0
#define GENERAL_X_Y_SORROUNDING_HALF2	12.0	// 8.0
#define CONSTANT_Z_CROUCH_UP_HALF		15.5	// 16.0
#define CONSTANT_Z_CROUCH_DOWN_HALF		8.75	// 8.0
#define CONSTANT_Z_STANDUP_UP_HALF		17.0	// 18.0
#define CONSTANT_Z_STANDUP_DOWN_HALF	17.5	// 18.0

#define ANGLE_COS_HEIGHT_CHECK			0.7071	// cos(45 degrees)

#define add_transparent_ent(%1)			 bs_array_transp[((%1 - 1) / 32)] |=  (1<<((%1 - 1) % 32))
#define del_transparent_ent(%1)			 bs_array_transp[((%1 - 1) / 32)] &= ~(1<<((%1 - 1) % 32))
#define  is_transparent_ent(%1)			(bs_array_transp[((%1 - 1) / 32)] &   (1<<((%1 - 1) % 32)))
#define add_solid_ent(%1)				 bs_array_solid [((%1 - 1) / 32)] |=  (1<<((%1 - 1) % 32))
#define del_solid_ent(%1)				 bs_array_solid [((%1 - 1) / 32)] &= ~(1<<((%1 - 1) % 32))
#define  is_solid_ent(%1)				(bs_array_solid [((%1 - 1) / 32)] &   (1<<((%1 - 1) % 32)))

new const Float:weapon_edge_point[CSW_P90+1] = { 0.00, 35.5, 0.00, 42.0, 0.00, 35.5, 0.00, 37.0, 37.0, 0.00, 35.5, 35.5, 32.0, 41.0, 32.0, 36.0, 41.0, 35.5, 41.0, 32.0, 37.0, 35.5, 42.0, 41.0, 44.0, 0.00, 35.5, 37.0, 32.0, 0.00, 32.0 }
new const Float:vec_multi_lateral[] = { GENERAL_X_Y_SORROUNDING, -GENERAL_X_Y_SORROUNDING, GENERAL_X_Y_SORROUNDING_HALF2, -GENERAL_X_Y_SORROUNDING_HALF }
new const Float:vec_add_height_crouch[] = { CONSTANT_Z_CROUCH_UP, -CONSTANT_Z_CROUCH_DOWN, CONSTANT_Z_CROUCH_UP_HALF, -CONSTANT_Z_CROUCH_DOWN_HALF }
new const Float:vec_add_height_standup[] = { CONSTANT_Z_STANDUP_UP, -CONSTANT_Z_STANDUP_DOWN, CONSTANT_Z_STANDUP_UP_HALF, -CONSTANT_Z_STANDUP_DOWN_HALF }

new bs_array_transp[64]
new bs_array_solid[64]

public isvisible_fw_spawn(ent) {
	if (!pev_valid(ent))
		return FMRES_IGNORED

	static rendermode, Float:renderamt

	rendermode = pev(ent, pev_rendermode)
	pev(ent, pev_renderamt, renderamt)

	if (((rendermode == kRenderTransColor || rendermode == kRenderGlow || rendermode == kRenderTransTexture) && renderamt < 255.0) || (rendermode == kRenderTransAdd)) {
		add_transparent_ent(ent)
		return FMRES_IGNORED
	}

	return FMRES_IGNORED
}


stock bool:is_point_visible(const Float:start[3], const Float:point[3], ignore_ent, thdl) {
    engfunc(EngFunc_TraceLine, start, point, IGNORE_GLASS | IGNORE_MONSTERS, ignore_ent, thdl)
    static Float:fraction
    get_tr2(thdl, TR_flFraction, fraction)
    return (fraction == 1.0)
}

stock bool:is_point_visible_texture(const Float:start[3], const Float:point[3], ignore_ent, thdl) {
    engfunc(EngFunc_TraceLine, start, point, IGNORE_GLASS | IGNORE_MONSTERS, ignore_ent, thdl)
    static ent
    ent = get_tr2(thdl, TR_pHit)
    static Float:fraction
    get_tr2(thdl, TR_flFraction, fraction)
    if (fraction != 1.0 && ent > 0) {
        if (!is_transparent_ent(ent) && !is_solid_ent(ent)) {
            static texture_name[2]
            static Float:vec[3]
            xs_vec_sub(point, start, vec)
            xs_vec_mul_scalar(vec, (5000.0 / xs_vec_len(vec)), vec)
            xs_vec_add(start, vec, vec)
            engfunc(EngFunc_TraceTexture, ent, start, vec, texture_name, charsmax(texture_name))
            if (equal(texture_name, "{")) {
                add_transparent_ent(ent)
                ignore_ent = ent
                engfunc(EngFunc_TraceLine, start, point, IGNORE_GLASS | IGNORE_MONSTERS, ignore_ent, thdl)
                get_tr2(thdl, TR_flFraction, fraction)
                return (fraction == 1.0)
            } else {
                add_solid_ent(ent)
                return (fraction == 1.0)
            }
        } else {
            if (is_solid_ent(ent)) {
                return (fraction == 1.0)
            } else {
                ignore_ent = ent
                engfunc(EngFunc_TraceLine, start, point, IGNORE_GLASS | IGNORE_MONSTERS, ignore_ent, thdl)
                get_tr2(thdl, TR_flFraction, fraction)
                return (fraction == 1.0)
            }
        }
    }
    return (fraction == 1.0)
}

stock is_player_visible(visor, target, thdl) {
    static Float:origin[3], Float:start[3], Float:end[3], Float:addict[3], Float:plane_vec[3], Float:normal[3], ignore_ent
    ignore_ent = visor
    pev(visor, pev_origin, origin)
    pev(visor, pev_v_angle, normal)
    angle_vector(normal, ANGLEVECTOR_FORWARD, normal)
    pev(target, pev_origin, end)
    xs_vec_sub(end, origin, plane_vec)
    xs_vec_mul_scalar(plane_vec,  (1.0/xs_vec_len(plane_vec)), plane_vec)
    if (xs_vec_dot(plane_vec, normal) < 0) {
        return false
    }
    pev(visor, pev_view_ofs, start)
    xs_vec_add(start, origin, start)
    origin = end
    if (is_point_visible_texture(start, origin, ignore_ent, thdl))
        return true
    pev(target, pev_view_ofs, end)
    xs_vec_add(end, origin, end)
    if (is_point_visible(start, end, ignore_ent, thdl))
        return true
    if (weapon_edge_point[get_user_weapon(target)] != 0.00) {
        pev(target, pev_v_angle, addict)
        angle_vector(addict, ANGLEVECTOR_FORWARD, addict)
        xs_vec_mul_scalar(addict, weapon_edge_point[get_user_weapon(target)], addict)
        xs_vec_add(end, addict, end)
        if (is_point_visible(start, end, ignore_ent, thdl))
            return true
    }
    xs_vec_sub(start, origin, normal)
    xs_vec_mul_scalar(normal, 1.0/(xs_vec_len(normal)), normal)
    vector_to_angle(normal, plane_vec)
    angle_vector(plane_vec, ANGLEVECTOR_RIGHT, plane_vec)
    if (floatabs(normal[2]) <= ANGLE_COS_HEIGHT_CHECK) {
        if (pev(target, pev_flags) & FL_DUCKING) {
            for (new i=0;i<4;i++) {
                if (i<2) {
                    for (new j=0;j<2;j++) {
                        xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                        addict[2] = vec_add_height_crouch[j]
                        xs_vec_add(origin, addict, end)

                        if (is_point_visible(start, end, ignore_ent, thdl))
                            return true
                    }
                } else {
                    for (new j=2;j<4;j++) {
                        xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                        addict[2] = vec_add_height_crouch[j]
                        xs_vec_add(origin, addict, end)
                        if (is_point_visible(start, end, ignore_ent, thdl))
                            return true
                    }
                }
            }
        } else {
            for (new i=0;i<4;i++) {
                if (i<2) {
                    for (new j=0;j<2;j++) {
                        xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                        addict[2] = vec_add_height_standup[j]
                        xs_vec_add(origin, addict, end)

                        if (is_point_visible(start, end, ignore_ent, thdl))
                            return true
                    }
                } else {
                    for (new j=2;j<4;j++) {
                        xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                        addict[2] = vec_add_height_standup[j]
                        xs_vec_add(origin, addict, end)

                        if (is_point_visible(start, end, ignore_ent, thdl))
                            return true
                    }
                }
            }
        }
    } else {
        if (normal[2] > 0.0) {
            normal[2] = 0.0
            xs_vec_mul_scalar(normal, 1/(xs_vec_len(normal)), normal)

            if (pev(target, pev_flags) & FL_DUCKING) {
                for (new i=0;i<4;i++) {
                    if (i<2) {
                        for (new j=0;j<2;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_crouch[j]
                            xs_vec_add(origin, addict, end)
                            xs_vec_mul_scalar(normal, (j == 0) ? (-GENERAL_X_Y_SORROUNDING) : (GENERAL_X_Y_SORROUNDING), addict)
                            xs_vec_add(end, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    } else {
                        for (new j=2;j<4;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_crouch[j]
                            xs_vec_add(origin, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    }
                }
            } else {
                for (new i=0;i<4;i++) {
                    if (i<2) {
                        for (new j=0;j<2;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_standup[j]
                            xs_vec_add(origin, addict, end)
                            xs_vec_mul_scalar(normal, (j == 0) ? (-GENERAL_X_Y_SORROUNDING) : (GENERAL_X_Y_SORROUNDING), addict)
                            xs_vec_add(end, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    } else {
                        for (new j=2;j<4;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_standup[j]
                            xs_vec_add(origin, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    }
                }
            }
        } else {
            normal[2] = 0.0
            xs_vec_mul_scalar(normal, 1/(xs_vec_len(normal)), normal)

            if (pev(target, pev_flags) & FL_DUCKING) {
                for (new i=0;i<4;i++) {
                    if (i<2) {
                        for (new j=0;j<2;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_crouch[j]
                            xs_vec_add(origin, addict, end)
                            xs_vec_mul_scalar(normal, (j == 0) ? GENERAL_X_Y_SORROUNDING : (-GENERAL_X_Y_SORROUNDING), addict)
                            xs_vec_add(end, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    } else {
                        for (new j=2;j<4;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_crouch[j]
                            xs_vec_add(origin, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    }
                }
            } else {
                for (new i=0;i<4;i++) {
                    if (i<2) {
                        for (new j=0;j<2;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_standup[j]
                            xs_vec_add(origin, addict, end)
                            xs_vec_mul_scalar(normal, (j == 0) ? GENERAL_X_Y_SORROUNDING : (-GENERAL_X_Y_SORROUNDING), addict)
                            xs_vec_add(end, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    } else {
                        for (new j=2;j<4;j++) {
                            xs_vec_mul_scalar(plane_vec, vec_multi_lateral[i], addict)
                            addict[2] = vec_add_height_standup[j]
                            xs_vec_add(origin, addict, end)

                            if (is_point_visible(start, end, ignore_ent, thdl))
                                return true
                        }
                    }
                }
            }
        }
    }

    return false
}

