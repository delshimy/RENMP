/***********************************************************************

    Reactive Environment for Network Music Performance
    Copyright (C) <2013>  Dalia El-Shimy

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

***********************************************************************/


q.mix_control = { |q, angle, player_positions_viewer, volume_right_instrument, volume_left_instrument, volume_right_vocals, volume_left_vocals|
	
	var adjusted_angle;
	var tilting_threshold=pi/8;
	var angle_thresh=5*pi/180;


	if(angle.abs>angle_thresh,{
		q.mc_active=true;
		if(angle<0,{
			adjusted_angle=(-1)*(angle+angle_thresh);
		},{
			adjusted_angle=(-1)*(angle-angle_thresh);
		});
							
	},{
		q.mc_active=false;
		adjusted_angle=0;
	});



	if((q.mc_active&&(q.tp_active.not)),{
		q.num.do({arg i;
			var temp;
			if(i!=q.player_num,{
				temp = player_positions_viewer[i,0]-player_positions_viewer[q.player_num,0];
				if(adjusted_angle>0,{
					//head is tilted to the right	
					if(temp<0,{
						//that musician is on the left. Turn down their volume in the right ear, and keep it the same on the left
						volume_right_instrument[i] = adjusted_angle.linlin(0,tilting_threshold,volume_right_instrument[i],0);
						volume_right_vocals[i] = adjusted_angle.linlin(0,tilting_threshold,volume_right_vocals[i],0);

					},{
						//that musician is to the right. Turn up their volume in the right ear, and turn it down in the left
						volume_left_instrument[i] = adjusted_angle.linlin(0,tilting_threshold,volume_left_instrument[i],0);
						volume_right_instrument[i] = adjusted_angle.linlin(0,tilting_threshold,volume_right_instrument[i],(2*volume_right_instrument[i]));
						volume_left_vocals[i] = adjusted_angle.linlin(0,tilting_threshold,volume_left_vocals[i],0);
						volume_right_vocals[i] = adjusted_angle.linlin(0,tilting_threshold,volume_right_vocals[i],(2*volume_right_vocals[i]));
					});
				},{
					//head is tilted to the left
					if(temp<0,{
						//that musician is to the left. Turn up their volume on the left ear, and turn it down in the right
						volume_left_instrument[i] = adjusted_angle.linlin((-1)*tilting_threshold,0,2*volume_left_instrument[i],volume_left_instrument[i]);
						volume_right_instrument[i] = adjusted_angle.linlin((-1)*tilting_threshold,0,0,volume_right_instrument[i]);
						volume_left_vocals[i] = adjusted_angle.linlin((-1)*tilting_threshold,0,2*volume_left_vocals[i],volume_left_vocals[i]);
						volume_right_vocals[i] = adjusted_angle.linlin((-1)*tilting_threshold,0,0,volume_right_vocals[i]);
					},{
						//that musician is to the right. Turn down their volume in the left ear, and keep it the same on the right
						volume_left_instrument[i] = adjusted_angle.linlin((-1)*tilting_threshold,0,0,volume_left_instrument[i]);
						volume_left_vocals[i] = adjusted_angle.linlin((-1)*tilting_threshold,0,0,volume_left_vocals[i]);
					});
				});
			});

		});




		if(adjusted_angle>0,{
			//head is tilted to the right	
			volume_left_instrument[q.player_num] = adjusted_angle.linlin(0,tilting_threshold,volume_left_instrument[q.player_num],0);
			volume_right_instrument[q.player_num] = adjusted_angle.linlin(0,tilting_threshold,volume_right_instrument[q.player_num],(2*volume_right_instrument[q.player_num]));
			volume_left_vocals[q.player_num] = adjusted_angle.linlin(0,tilting_threshold,volume_left_vocals[q.player_num],0);
			volume_right_vocals[q.player_num] = adjusted_angle.linlin(0,tilting_threshold,volume_right_vocals[q.player_num],(2*volume_right_vocals[q.player_num]));
		},{
			//head is tilted to the left		
			volume_left_instrument[q.player_num] = adjusted_angle.linlin((-1)*tilting_threshold,0,2*volume_left_instrument[q.player_num],volume_left_instrument[q.player_num]);
			volume_right_instrument[q.player_num] = adjusted_angle.linlin((-1)*tilting_threshold,0,0,volume_right_instrument[q.player_num]);
			volume_left_vocals[q.player_num] = adjusted_angle.linlin((-1)*tilting_threshold,0,2*volume_left_vocals[q.player_num],volume_left_vocals[q.player_num]);
			volume_right_vocals[q.player_num] = adjusted_angle.linlin((-1)*tilting_threshold,0,0,volume_right_vocals[q.player_num]);
		});
	});

	[volume_right_instrument, volume_left_instrument, volume_right_vocals, volume_left_vocals];	
};
