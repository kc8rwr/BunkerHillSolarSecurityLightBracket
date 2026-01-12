use <./libraries/UnfyOpenSCADLib/unfy_shapes.scad>
use <./libraries/UnfyOpenSCADLib/unfy_fasteners.scad>
use <./libraries/UnfyOpenSCADLib/unfy_math.scad>

part = "wall_side";//["wall_side":Wall Side Mount,"object_side":Object Side Mount]

screw_separation = 70;
screw_size = "#8"; // ["m2", "m2.5", "m3", "m4", "m8", "#00", "#000", "#0000", "#4", "#6", "#8", "#10", "#12", "1/4\"", "5/16\"", "3/8\""]
base_corner_d = 7;
edge_r = 3;
fillet = 5;
bracket_base_height = 13;
wallside_d = 32;
thickness = 6;
bolt_size = "m4"; // ["m2", "m2.5", "m3", "m4", "m8", "#00", "#000", "#0000", "#4", "#6", "#8", "#10", "#12", "1/4\"", "5/16\"", "3/8\""]
objectside_d = 22.5;
objectside_stopper_height = 26;
objectside_x = 35;
objectside_y = 38;
objectside_z = 1.5;

$wall = 2;
$over = 0.0001;

$fn = $preview ? 36 : 360;

module wall_side(screw_separation = 70,
					  screw_size = "#8",
					  thickness = 5,
					  base_corner_d = 7,
					  edge_r = 3,
					  fillet = 3,
					  bracket_base_height = 13,
					  wallside_d = 32,
					  thickness = 6,
					  bolt_size = "m4",){

	bracket_base_d = wallside_d + (2*$wall); //one side of bracket has the gap blocked oso leae $wall for that, second $all for open side to keep it centered.

	//fastener vectors
	screw_v = unf_csk_v(screw_size);
	screw_head_d = unf_csk_head_diameter(screw_v);
	bolt_d = unf_hex_v(bolt_size);
	
	//calc dimensions of base
	base_y = bracket_base_d + (2*$wall) + (2*edge_r);
	base_x = screw_separation + screw_head_d + (2*$wall) + (2*edge_r);
	
	//base
	difference(){
		unf_roundedCuboid([base_x, base_y, thickness], edge_r = [edge_r, 0], corners = base_corner_d);
		//screw holes
		for (x = [1, -1]){
			translate([(base_x/2)+(x*(screw_separation/2)), base_y/2, thickness]){
				rotate([180, 0, 0]){
					unf_csk(screw=screw_v, length=thickness+$over, head_ext=$over);
				}
			}
		}
	}
	
	//bracket base
	translate([base_x/2, base_y/2, 0]){
		cylinder(d=wallside_d, h=bracket_base_height+thickness-edge_r+$over);
		translate([0, 0, bracket_base_height+thickness-edge_r]){
			for (z = [0:edge_r/$fn:edge_r]){
				x = sqrt(pow(edge_r, 2) - pow(z, 2));
				translate([0, 0, z]){
					cylinder(d=wallside_d-edge_r+x, h=edge_r/$fn);
				}
			}
		}
		translate([0, 0, thickness]){
			rotate_extrude(){
				translate([wallside_d/2, 0]){
					unf_bezierWedge2d([fillet, fillet]);
				}
				square([wallside_d/2, edge_r]);
			}
		}
	}
	
	//bracket
	difference(){
		intersection(){
			translate([base_x/2, base_y/2, 0]){
				cylinder(d=wallside_d, h=bracket_base_height+thickness+wallside_d);
			}
			union(){
				translate([(base_x/2)-thickness-(thickness/2), (base_y/2)-(wallside_d/2), 0]){
					cube([thickness+(2*thickness), wallside_d, bracket_base_height+thickness+(wallside_d/2)]);
				}		
				translate([(base_x/2)-thickness-(thickness/2), base_y/2, thickness+bracket_base_height+(wallside_d/2)]){
					rotate([0, 90, 0]){
						translate([0, 0, edge_r]){
							rotate([0, 180, 0]){
								for (z = [0:edge_r/$fn:edge_r-(edge_r/$fn)]){
									x = sqrt(pow(edge_r, 2)-pow(z, 2));
									translate([0, 0, z]){
										cylinder(d=wallside_d-edge_r+x, h=(edge_r/$fn)+$over);
									}
								}
							}
						}
						translate([0, 0, thickness+(2*thickness)-edge_r]){
							for (z = [0:edge_r/$fn:edge_r-(edge_r/$fn)]){
								x = sqrt(pow(edge_r, 2)-pow(z, 2));
								translate([0, 0, z]){
									cylinder(d=wallside_d-edge_r+x, h=(edge_r/$fn)+$over);
								}
							}
						}
						translate([0, 0, edge_r-$over]){
							cylinder(d=wallside_d, h=thickness+(2*thickness)-(2*edge_r)+(2*$over));
						}
					}
				}
				bead_len = unf_chord_distance(r=wallside_d/2, d=thickness+(thickness/2));
				translate([(base_x/2)+(thickness/2)+thickness, (base_y/2)-(bead_len/2), thickness+bracket_base_height-fillet]){
					unf_bezierWedge3d(size=[2*fillet, 2*fillet, bead_len], rounded_edges=[fillet-$over, fillet-$over]);
				}
				translate([(base_x/2)-(thickness/2)-fillet, (bead_len/2)+(base_y/2), thickness+bracket_base_height-fillet]){
					rotate([0, 0, 180]){
						unf_bezierWedge3d(size=[2*fillet, 2*fillet, bead_len], rounded_edges=[fillet-$over, fillet-$over]);
					}
				}
			}
		}
		translate([(base_x/2)-(thickness/2), edge_r+(3*$wall), 0]){
			cube([thickness, base_y, thickness+bracket_base_height+wallside_d+$over]);
		}
		translate([(base_x/2)-(thickness/2), 0, thickness+bracket_base_height+(wallside_d/2)]){
			cube([thickness, base_y, thickness+bracket_base_height+wallside_d+$over]);
		}
		translate([(base_x/2)-(thickness/2)-thickness-(2*$over), base_y/2, thickness+bracket_base_height+(wallside_d/2)]){
			rotate([0, 90, 0]){
				unf_hex(screw=bolt_d, length=thickness+(2*thickness)+$over);
			}
		}
		translate([(base_x/2)+(thickness/2)+thickness+(2*$over), base_y/2, thickness+bracket_base_height+(wallside_d/2)]){
			rotate([0, -90, 0]){
				unf_wsh(size=bolt_size);
			}
		}
	}
}


module object_side(edge_r = 3,
						 fillet = 3,
						 wallside_d = 32,
						 thickness = 6,
						 bolt_size = "m4",
						 d = 22.5,
						 stopper_height = 26,
						 x = 35,
						 y = 38,
						 z = 1.5){
	base_edge_r = min(edge_r, z);
	pillar_edge_r = min(edge_r, objectside_y);
	pillar_y = (wallside_d / 2) + (d/2);
	pillar_z = stopper_height+z;

	difference(){
		union(){
			unf_roundedCuboid([x, y, z], edge_r = [base_edge_r, 0], corners = base_edge_r);
			
			translate([(x/2)-(thickness/2), (y/2)-(pillar_y/2), 0]){
				unf_roundedCuboid([thickness, pillar_y, pillar_z], edge_r=[pillar_edge_r, 0], corners=pillar_edge_r);
				bez = unfy_bezier([[fillet, 0], [fillet/4, fillet/4], [0, fillet]]);
				for (i = [1:len(bez)-1]){
					v = bez[i];
					pv = bez[i-1];
					if (0 < v.x){
						translate([-v.x, -v.x, pv.y]){
							unf_roundedCuboid([thickness+(2*v.x), pillar_y+v.x, v.y-pv.y], edge_r=0, corners=edge_r);
						}
					}
				}
				
				bracket_r = min(edge_r, thickness/3);
				translate([0, pillar_y-(objectside_d/2), pillar_z]){
					rotate([0, 90, 0]){
						translate([0, 0, bracket_r]){
							rotate([0, 180, 0]){
								for (z = [0:bracket_r/$fn:bracket_r-(bracket_r/$fn)]){
									x = sqrt(pow(bracket_r, 2)-pow(z, 2));
									translate([0, 0, z]){
										cylinder(d=objectside_d-bracket_r+x, h=(bracket_r/$fn)+$over);
									}
								}
							}
						}
						translate([0, 0, thickness-bracket_r]){
							for (z = [0:bracket_r/$fn:bracket_r-(bracket_r/$fn)]){
								x = sqrt(pow(bracket_r, 2)-pow(z, 2));
								translate([0, 0, z]){
									cylinder(d=objectside_d-bracket_r+x, h=(bracket_r/$fn)+$over);
								}
							}
						}
						translate([0, 0, bracket_r-$over]){
							cylinder(d=objectside_d, h=thickness-(2*bracket_r)+(2*$over));
						}
					}
				}
				
			}
		}
		#translate([(x/2)-(thickness/2)-$over, (y/2)+(pillar_y/2)-(objectside_d/2), pillar_z]){
			rotate([0, 90, 0]){
				cylinder(d=unf_fnr_shaft_diameter(bolt_size), h=thickness+(2*$over));
			}
		}
	}
}

if ("wall_side" == part){
	wall_side(screw_separation = screw_separation,
				 screw_size = screw_size,
				 base_corner_d = base_corner_d,
				 edge_r = edge_r,
				 fillet = fillet,
				 bracket_base_height = bracket_base_height,
				 wallside_d = wallside_d,
				 thickness = thickness,
				 bolt_size = bolt_size);
 }

if ("object_side" == part){
	object_side(edge_r = edge_r,
					fillet = fillet,
					wallside_d = wallside_d,
					thickness = thickness,
					bolt_size = bolt_size,
					d = objectside_d,
					stopper_height = objectside_stopper_height,
					x = objectside_x,
					y = objectside_y,
					z = objectside_z);
 }
