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

q.startjam = { |q|
	
	var file_names=Array.newClear(3);
	var out_channels=[2,0]; //note that structure is [left, right]

	//we define all variables related to volume changes
	var base_volume_instrument = Array.newClear(q.num);
	var base_volume_vocals = Array.newClear(q.num);
	var min_volume_instrument = Array.newClear(q.num); //each musician has a minimum volume that is a function of their current volume - loudness range
	var min_volume_vocals = Array.newClear(q.num);
	var volume_instrument = Array.newClear(q.num);
	var volume_vocals = Array.newClear(q.num);
	var max_volume_slider=75;

	//we define all variables related to reverb changes
	var base_reverb_instrument = Array.newClear(q.num);
	var base_reverb_vocals = Array.newClear(q.num);
	var min_reverb = 0.6;
	var max_reverb_slider = 7; //this is the value on the slider
	var max_reverb_range = 7; //this is how far we can turn up the dynamic reverb range 
	var max_reverb_total = max_reverb_slider+max_reverb_range;
	var max_reverb_instrument = Array.newClear(q.num); 
	var max_reverb_vocals = Array.newClear(q.num);
	var reverb_instrument = Array.newClear(q.num);
	var reverb_vocals = Array.newClear(q.num);

	var min_damping = 0.1;
	var max_damping = 0.9;
	var damping_instrument = Array.newClear(q.num);
	var damping_vocals = Array.newClear(q.num);
	
	//we define all variables related to distances
	var player_positions=Array2D.new(q.num,2);
	var player_positions_adjusted_kinect_location=Array2D.new(q.num,2);
	var player_positions_translated=Array2D.new(q.num,2);
	var player_positions_rotated=Array2D.new(q.num,2);
	var player_positions_translated_for_GUI=Array2D.new(q.num,2);
	var player_positions_rotated_for_GUI=Array2D.new(q.num,2);
	var player_positions_rotated_perspective=Array2D.new(q.num,2);
	var player_positions_translated_viewer=Array2D.new(q.num,2);
	var player_positions_scaled=Array2D.new(q.num,2);
	var player_positions_viewer=Array2D.new(q.num,2);
	var player_received, info_received;
	var distance = Array.newClear(q.num);
	//these are to be used if video is on
	var distance_to_monitors=Array2D.new(q.num, q.num);
	var monitor_position = Array2D.new(q.num,q.num);

	//we define all variables related to angles
	var tp_angle = 0;
	var ms_angle = 0;
	var mc_angle = 0;
	var head_roll = Array.newClear(q.num);
	var head_yaw = Array.newClear(q.num);
	var body_yaw = Array.newClear(q.num);	
	var tp_angle_thresh=5*pi/180;
	var volume_left_instrument = Array.newClear(q.num);
	var volume_right_instrument = Array.newClear(q.num);
	var volume_left_vocals = Array.newClear(q.num);
	var volume_right_vocals = Array.newClear(q.num);


	var filter_size=20;
	var filter_head_roll=Array2D.new(q.num,filter_size);
	var filter_head_yaw=Array2D.new(q.num,filter_size);
	var filter_body_yaw=Array2D.new(q.num,filter_size);
	var filter_x_pos = Array2D.new(q.num,filter_size);
	var filter_y_pos = Array2D.new(q.num,filter_size);
	var temp_x, temp_y;
	var counter=0;	
	var kinect_command_without_window;

	//start the kinect
	kinect_command_without_window=catArgs("cd OSCeleton_for_NMP &&./osceleton_for_NMP -xt -p ", NetAddr.langPort);
	kinect_command_without_window.unixCmd;	



	q.volume_instrument_slider.enabled=true;
	q.volume_vocals_slider.enabled=true;
	q.reverb_instrument_slider.enabled=true;
	q.reverb_vocals_slider.enabled=true;
	q.current_time=0;	
	q.tp_active=false;

	q.volume_threshold_near = 0.5;
	q.volume_threshold_far = 0.666;
	q.reverb_safe_threshold = 0.25;

	if(q.save,{
		//we get the current time
		q.start_time=thisThread.clock.beats*1000;

		//we set up our files for saving
		file_names[0]=catArgs(q.current_directory,"/data/position/Musician_",q.player_num,"_", q.cond_dv,"_", q.cond_dr, "_", q.cond_ti,"_", q.cond_mc, "_", q.cond_ms, "_position_", Date.getDate, ".txt");
		file_names[1]=catArgs(q.current_directory,"/data/orientation/Musician_",q.player_num,"_", q.cond_dv,"_", q.cond_dr, "_", q.cond_ti,"_", q.cond_mc, "_", q.cond_ms, "_orientation_", Date.getDate, ".txt");
		file_names[2]=catArgs(q.current_directory,"/data/settings/Musician_",q.player_num, "_", q.cond_dv,"_", q.cond_dr, "_", q.cond_ti,"_", q.cond_mc,"_", q.cond_ms, "_settings_", Date.getDate, ".txt");	

		q.file_position=File(file_names[0].asString,"w");
		q.file_orientation=File(file_names[1].asString,"w");
		q.file_settings=File(file_names[2].asString,"w");
	});

	q.num.do({arg i;
		q.num.do({arg j;
			monitor_position[i,j]=[0,0];
		});
	});		

	//for player 0, left is player 1, right is player 2
	monitor_position[0,1]=q.kinect_corners_rotated[0,2]; //left monitor
	monitor_position[0,2]=q.kinect_corners_rotated[0,3]; //right monitor
	//for player 1, left is player 2, right is player 0
	monitor_position[1,2]=q.kinect_corners_rotated[1,2]; //left monitor
	monitor_position[1,0]=q.kinect_corners_rotated[1,3]; //right monitor
	//for player 2, left is player 0, right is player 1
	monitor_position[2,0]=q.kinect_corners_rotated[2,2]; //left monitor
	monitor_position[2,1]=q.kinect_corners_rotated[2,3]; //right monitor


	if(q.base_volume_instrument_local==nil,{
		q.base_volume_instrument_local=0.0001;
	});

	if(q.base_volume_vocals_local==nil,{
		q.base_volume_vocals_local=0.0001;
	});

	if(q.base_reverb_instrument_local==nil,{
		q.base_reverb_instrument_local=min_reverb;
	});

	if(q.base_reverb_vocals_local==nil,{
		q.base_reverb_vocals_local=min_reverb;
	});

	if(q.volume_instrument_image_value==nil,{
		q.volume_instrument_image_value=0;
	});
	
	if(q.volume_vocals_image_value==nil,{
		q.volume_vocals_image_value=0;
	});

	if(q.reverb_instrument_image_value==nil,{
		q.reverb_instrument_image_value=0;
	});
	
	if(q.reverb_vocals_image_value==nil,{
		q.reverb_vocals_image_value=0;
	});

	if(q.volume_range==nil,{
		q.volume_range = 0.5;
	});
	if(q.reverb_range==nil,{
		q.reverb_range = max_reverb_range/2; //we want to make the total range between 0 and 3. This way, the maximum reverb experienced is at 5.
	});
	
	q.volume_instrument_icon.drawFunc = { 
           	Pen.image(q.volume_image[q.volume_instrument_image_value, q.reverb_instrument_image_value]); 
   	};
	q.volume_vocals_icon.drawFunc = { 
           	Pen.image(q.volume_image[q.volume_vocals_image_value, q.reverb_vocals_image_value]); 
   	};

	if(q.dv,{
		q.volume_range_slider.enabled=true;
	});
	if(q.dr,{
		q.reverb_range_slider.enabled=true;
	});

	//initialize our arrays
	q.num.do({arg i;
		if(i==q.player_num,{
			base_volume_instrument[i]=q.base_volume_instrument_local;
			base_volume_vocals[i]=q.base_volume_vocals_local;
			base_reverb_instrument[i]=q.base_reverb_instrument_local;
			base_reverb_vocals[i]=q.base_reverb_vocals_local;
		},{
			base_volume_instrument[i]=0.0001;
			base_volume_vocals[i]=0.0001;
			base_reverb_instrument[i]=min_reverb;
			base_reverb_vocals[i]=min_reverb;
		});
		volume_instrument[i]=base_volume_instrument[i];
		volume_vocals[i]=base_volume_vocals[i];
		min_volume_instrument[i]=volume_instrument[i]*q.volume_range;
		min_volume_vocals[i]=volume_vocals[i]*q.volume_range;
		
		reverb_instrument[i]=base_reverb_instrument[i];
		reverb_vocals[i]=base_reverb_vocals[i];
		max_reverb_instrument[i]=reverb_instrument[i]+q.reverb_range;
		max_reverb_vocals[i]=reverb_vocals[i]+q.reverb_range;

		damping_instrument[i]=1-(base_reverb_instrument[i]/(max_reverb_total-min_reverb));
		damping_vocals[i]=1-(base_reverb_vocals[i]/(max_reverb_total-min_reverb));
	
		head_roll[i]=0;
		head_yaw[i]=0;
		body_yaw[i]=0;

		//we want all avatars off the viewer until they start sending messages
		player_positions[i,0]=q.kinect_corners_actual[i,1][0];
		player_positions[i,1]=q.kinect_corners_actual[i,1][1];
		player_positions_adjusted_kinect_location[i,0]=0;
		player_positions_adjusted_kinect_location[i,1]=0;
		player_positions_translated[i,0]=0;
		player_positions_translated[i,1]=0;
		player_positions_translated_for_GUI[i,0]=0;
		player_positions_translated_for_GUI[i,1]=0;
		player_positions_rotated[i,0]=q.kinect_corners_rotated[i,1][0];
		player_positions_rotated[i,1]=q.kinect_corners_rotated[i,1][1];
		player_positions_rotated_for_GUI[i,0]=q.kinect_corners_rotated[i,1][0];
		player_positions_rotated_for_GUI[i,1]=q.kinect_corners_rotated[i,1][1];
		//initialize player_positions_viewer in case we are not receiving messages from other players yet
		player_positions_rotated_perspective[i,0]=(q.rotation_matrix[q.player_num][0,0]*player_positions_rotated_for_GUI[i,0])+(q.rotation_matrix[q.player_num][0,1]*player_positions_rotated_for_GUI[i,1]);
		player_positions_rotated_perspective[i,1]=(q.rotation_matrix[q.player_num][1,0]*player_positions_rotated_for_GUI[i,0])+(q.rotation_matrix[q.player_num][1,1]*player_positions_rotated_for_GUI[i,1]); 
		player_positions_translated_viewer[i,0]=player_positions_rotated_perspective[i,0]-q.min_x;
		player_positions_translated_viewer[i,1]=player_positions_rotated_perspective[i,1]-q.min_y;
		
		player_positions_scaled[i,0] = player_positions_translated_viewer[i,0]*q.pos_viewer_ratio_x;
		player_positions_scaled[i,1] = player_positions_translated_viewer[i,1]*q.pos_viewer_ratio_y; 
		player_positions_viewer[i,0] = player_positions_scaled[i,0]+q.avatar_margin;
		player_positions_viewer[i,1] = q.viewer_total_height-player_positions_scaled[i,1]-q.avatar_margin;


		volume_right_instrument[i]=0;
		volume_left_instrument[i]=0;
		volume_right_vocals[i]=0;
		volume_left_vocals[i]=0;
		q.num.do({arg j;
			if(i!=j,{
				distance_to_monitors[i,j]=(player_positions_rotated_perspective.rowAt(i)-monitor_position[i,j]).squared.sum.sqrt;
			},{
				distance_to_monitors[i,j]=0;
			});
		});

	});


	q.num.do({arg i;
		if(i!=q.player_num,{	
			distance[i]=distance_to_monitors[i,q.player_num]+distance_to_monitors[q.player_num,i];	
		},{
			distance[i]=0;
		});
		filter_size.do({arg j;
			filter_head_roll[i,j]=0;
			filter_head_yaw[i,j]=0;
			filter_body_yaw[i,j]=0;
			filter_x_pos[i,j]=q.kinect_corners_actual[i,1][0];
			filter_y_pos[i,j]=q.kinect_corners_actual[i,1][1];
		});
	});



	t=Task.new({

		catArgs(q.current_directory,"/src/synth_definition.scd").load;
	
		l.sync;
	
		//we initialize our local player synth
		q.player_out_left = Synth(\player_mix, [\amp_instrument, volume_instrument, \amp_vocals, volume_vocals, \channel_out, out_channels[0], \roomsize, 16, \revtime_instrument, reverb_instrument, \revtime_vocals, reverb_vocals, \damp_instrument, damping_instrument, \damp_vocals, damping_vocals]);


		q.player_out_right = Synth(\player_mix, [\amp_instrument, volume_instrument, \amp_vocals, volume_vocals, \channel_out, out_channels[1], \roomsize, 16, \revtime_instrument, reverb_instrument, \revtime_vocals, reverb_vocals, \damp_instrument, damping_instrument, \damp_vocals, damping_vocals]);


		"we've initialized our synth now".postln;

	
	});

	t.play;	

	//we want to inquire about other musicians' volumes when we start the jam
	//we only need to do this once at the start of a jam
	q.num.do({arg i;
		if(i!=q.player_num,{
			q.osc_addresses_57120[i].sendMsg("/inquiry",q.player_num);
			q.osc_addresses_57121[i].sendMsg("/inquiry",q.player_num);
		});
	});


	//we have received an inquiry. we send back our own volume.
	q.inquiry_osc = OSCresponderNode(nil, '/inquiry', {arg time, resp, msg; 
		//we then send all the data to the corresponding osc nodes
		q.osc_addresses_57120[msg[1]].sendMsg("/vol_instrument", q.player_num, base_volume_instrument[q.player_num]);
		q.osc_addresses_57121[msg[1]].sendMsg("/vol_instrument", q.player_num, base_volume_instrument[q.player_num]);

		q.osc_addresses_57120[msg[1]].sendMsg("/vol_vocals", q.player_num, base_volume_vocals[q.player_num]);
		q.osc_addresses_57121[msg[1]].sendMsg("/vol_vocals", q.player_num, base_volume_vocals[q.player_num]);

		q.osc_addresses_57120[msg[1]].sendMsg("/rev_instrument", q.player_num, base_reverb_instrument[q.player_num], damping_instrument[q.player_num]);
		q.osc_addresses_57121[msg[1]].sendMsg("/rev_instrument", q.player_num, base_reverb_instrument[q.player_num], damping_instrument[q.player_num]);

		q.osc_addresses_57120[msg[1]].sendMsg("/rev_vocals", q.player_num, base_reverb_vocals[q.player_num], damping_vocals[q.player_num]);
		q.osc_addresses_57121[msg[1]].sendMsg("/rev_vocals", q.player_num, base_reverb_vocals[q.player_num], damping_vocals[q.player_num]);
	}).add;	

	//now we get the volume for instruments
	q.volume_instrument_slider.action_({|v,x,y,m| 
		base_volume_instrument[q.player_num]=(v.value*max_volume_slider);
		q.base_volume_instrument_local=base_volume_instrument[q.player_num];
		base_volume_instrument.postln;
		volume_instrument[q.player_num]=base_volume_instrument[q.player_num];
		min_volume_instrument[q.player_num] = base_volume_instrument[q.player_num]*q.volume_range;
		q.player_out_right.set(\amp_instrument, base_volume_instrument);
		q.player_out_left.set(\amp_instrument, base_volume_instrument);
		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs(q.current_time.asString, "volume_instrument",  base_volume_instrument[q.player_num].asString,"\n"));
		});
		//we should also send this new volume to the other musicians
		q.num.do({arg i;
			if(i!=q.player_num,{
				q.osc_addresses_57120[i].sendMsg("/vol_instrument", q.player_num, base_volume_instrument[q.player_num]);
				q.osc_addresses_57121[i].sendMsg("/vol_instrument", q.player_num, base_volume_instrument[q.player_num]);
			});
		});


		if(q.volume_instrument_slider.value==0,{
			q.volume_instrument_image_value = 0;
		});
		if((q.volume_instrument_slider.value<=0.33)&&(q.volume_instrument_slider.value>0),{
			q.volume_instrument_image_value = 1;
		}); 	
		if((q.volume_instrument_slider.value>0.33)&&(q.volume_instrument_slider.value<=0.66),{
			q.volume_instrument_image_value = 2;
		});
		if(q.volume_instrument_slider.value>0.66,{
			q.volume_instrument_image_value = 3;
		});

		q.volume_instrument_icon.drawFunc = { 
           		Pen.image(q.volume_image[q.volume_instrument_image_value, q.reverb_instrument_image_value]); 
   		};
	}).value=(q.base_volume_instrument_local/max_volume_slider);



	//now we get the reverb for instruments
	q.reverb_instrument_slider.action_({|v,x,y,m| 
		base_reverb_instrument[q.player_num]=(v.value*(max_reverb_slider-min_reverb))+min_reverb;
		q.base_reverb_instrument_local=base_reverb_instrument[q.player_num];
		reverb_instrument[q.player_num]=base_reverb_instrument[q.player_num];

		damping_instrument[q.player_num]=(((reverb_instrument[q.player_num]-min_reverb)/(max_reverb_total-min_reverb))*(min_damping-max_damping))+max_damping;	

		[reverb_instrument[q.player_num],damping_instrument[q.player_num]].postln;		
	
		q.player_out_right.set(\revtime_instrument, reverb_instrument, \damp_instrument, damping_instrument);
		q.player_out_left.set(\revtime_instrument, reverb_instrument, \damp_instrument, damping_instrument);
		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("reverb_instrument", q.current_time.asString, reverb_instrument[q.player_num].asString, damping_instrument[q.player_num].asString, "\n"));
		});
		//we should also send this new volume to the other musicians
		q.num.do({arg i;
			if(i!=q.player_num,{
				q.osc_addresses_57120[i].sendMsg("/rev_instrument", q.player_num, reverb_instrument[q.player_num], damping_instrument[q.player_num]);
				q.osc_addresses_57121[i].sendMsg("/rev_instrument", q.player_num, reverb_instrument[q.player_num], damping_instrument[q.player_num]);
			});
		});


		if(q.reverb_instrument_slider.value==0,{
			q.reverb_instrument_image_value = 0;
		});
		if((q.reverb_instrument_slider.value<=0.33)&&(q.reverb_instrument_slider.value>0),{
			q.reverb_instrument_image_value = 1;
		}); 	
		if((q.reverb_instrument_slider.value>0.33)&&(q.reverb_instrument_slider.value<=0.66),{
			q.reverb_instrument_image_value = 2;
		});
		if(q.reverb_instrument_slider.value>0.66,{
			q.reverb_instrument_image_value = 3;
		});

		q.volume_instrument_icon.drawFunc = { 
           		Pen.image(q.volume_image[q.volume_instrument_image_value, q.reverb_instrument_image_value]); 
   		};
	}).value=((q.base_reverb_instrument_local-min_reverb)/(max_reverb_slider-min_reverb));


	
	//now we get the volume for vocals
	q.volume_vocals_slider.action_({|v,x,y,m| 
		base_volume_vocals[q.player_num]=(v.value*max_volume_slider);
		q.base_volume_vocals_local=base_volume_vocals[q.player_num];
		base_volume_vocals.postln;
		volume_vocals[q.player_num]=base_volume_vocals[q.player_num];
		min_volume_vocals[q.player_num] = base_volume_vocals[q.player_num]*q.volume_range;
		q.player_out_right.set(\amp_vocals, base_volume_vocals);
		q.player_out_left.set(\amp_vocals, base_volume_vocals);
		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs( q.current_time.asString, "volume_vocals", base_volume_vocals[q.player_num].asString,"\n"));
		});
		//we should also send this new volume to the other musicians
		q.num.do({arg i;
			if(i!=q.player_num,{
				q.osc_addresses_57120[i].sendMsg("/vol_vocals", q.player_num, base_volume_vocals[q.player_num]);
				q.osc_addresses_57121[i].sendMsg("/vol_vocals", q.player_num, base_volume_vocals[q.player_num]);
			});
		});


		if(q.volume_vocals_slider.value==0,{
			q.volume_vocals_image_value = 0;
		});
		if((q.volume_vocals_slider.value<=0.33)&&(q.volume_vocals_slider.value>0),{
			q.volume_vocals_image_value = 1;
		}); 	
		if((q.volume_vocals_slider.value>0.33)&&(q.volume_vocals_slider.value<=0.66),{
			q.volume_vocals_image_value = 2;
		});
		if(q.volume_vocals_slider.value>0.66,{
			q.volume_vocals_image_value = 3;
		});

		q.volume_vocals_icon.drawFunc = { 
           		Pen.image(q.volume_image[q.volume_vocals_image_value, q.reverb_vocals_image_value]); 
   		};
	}).value=(q.base_volume_vocals_local/max_volume_slider);



	//now we get the reverb for vocals
	q.reverb_vocals_slider.action_({|v,x,y,m| 
		base_reverb_vocals[q.player_num]=(v.value*(max_reverb_slider-min_reverb))+min_reverb;
		q.base_reverb_vocals_local=base_reverb_vocals[q.player_num];
		reverb_vocals[q.player_num]=base_reverb_vocals[q.player_num];

		damping_vocals[q.player_num]=(((reverb_vocals[q.player_num]-min_reverb)/(max_reverb_total-min_reverb))*(min_damping-max_damping))+max_damping;	

		[reverb_vocals[q.player_num],damping_vocals[q.player_num]].postln;	

		q.player_out_right.set(\revtime_vocals, reverb_vocals);
		q.player_out_left.set(\revtime_vocals, reverb_vocals);
		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("reverb_vocals", q.current_time.asString, reverb_vocals[q.player_num].asString, damping_vocals[q.player_num].asString, "\n"));
		});
		//we should also send this new volume to the other musicians
		q.num.do({arg i;
			if(i!=q.player_num,{
				q.osc_addresses_57120[i].sendMsg("/rev_vocals", q.player_num, reverb_vocals[q.player_num], damping_vocals[q.player_num]);
				q.osc_addresses_57121[i].sendMsg("/rev_vocals", q.player_num, reverb_vocals[q.player_num], damping_vocals[q.player_num]);
			});
		});


		if(q.reverb_vocals_slider.value==0,{
			q.reverb_vocals_image_value = 0;
		});
		if((q.reverb_vocals_slider.value<=0.33)&&(q.reverb_vocals_slider.value>0),{
			q.reverb_vocals_image_value = 1;
		}); 	
		if((q.reverb_vocals_slider.value>0.33)&&(q.reverb_vocals_slider.value<=0.66),{
			q.reverb_vocals_image_value = 2;
		});
		if(q.reverb_vocals_slider.value>0.66,{
			q.reverb_vocals_image_value = 3;
		});

		q.volume_vocals_icon.drawFunc = { 
           		Pen.image(q.volume_image[q.volume_vocals_image_value, q.reverb_vocals_image_value]); 
   		};
	}).value=((q.base_reverb_vocals_local-min_reverb)/(max_reverb_slider-min_reverb));




	
	//we also want to receive the volume from the other musicians
	q.volume_instrument_osc = OSCresponderNode(nil, '/vol_instrument', {arg time, resp, msg;
		//our messages are formatted as [/vol_base, player_id, volume]
		//msg.postln;		
		q.num.do({arg i;
			if(msg[1]==i,{
				base_volume_instrument[i]=msg[2];
				volume_instrument[i]=base_volume_instrument[i];
				min_volume_instrument[i]=base_volume_instrument[i]*q.volume_range;
			});
		});	
		//base_volume_instrument.postln;
		q.player_out_right.set(\amp_instrument, base_volume_instrument);
		q.player_out_left.set(\amp_instrument, base_volume_instrument);
	}).add;	


	//now we do the same for vocals
	q.volume_vocals_osc = OSCresponderNode(nil, '/vol_vocals', {arg time, resp, msg;
		//our messages are formatted as [/vol_base, player_id, volume]
		//msg.postln;		
		q.num.do({arg i;
			if(msg[1]==i,{
				base_volume_vocals[i]=msg[2];
				volume_vocals[i]=base_volume_vocals[i];
				min_volume_vocals[i]=base_volume_vocals[i]*q.volume_range;
			});
		});	
		//base_volume_vocals.postln;
		q.player_out_right.set(\amp_vocals, base_volume_vocals);
		q.player_out_left.set(\amp_vocals, base_volume_vocals);
	}).add;	
	
	//we also want to receive the reverb from the other musicians
	q.reverb_instrument_osc = OSCresponderNode(nil, '/rev_instrument', {arg time, resp, msg;
		//our messages are formatted as [/rev_base, player_id, reverb, damping]
		//msg.postln;		
		q.num.do({arg i;
			if(msg[1]==i,{
				base_reverb_instrument[i]=msg[2];
				reverb_instrument[i]=base_reverb_instrument[i];
				max_reverb_instrument[i]=base_reverb_instrument[i]+q.reverb_range;

				damping_instrument[i]=msg[3];
			});
		});	
		//base_reverb_instrument.postln;
		q.player_out_right.set(\revtime_instrument, base_reverb_instrument, \damp_instrument, damping_instrument);
		q.player_out_left.set(\revtime_instrument, base_reverb_instrument, \damp_instrument, damping_instrument);
	}).add;	

	//now we do the same for vocals
	q.reverb_vocals_osc = OSCresponderNode(nil, '/rev_vocals', {arg time, resp, msg;
		//our messages are formatted as [/rev_base, player_id, reverb]
		//msg.postln;		
		q.num.do({arg i;
			if(msg[1]==i,{
				base_reverb_vocals[i]=msg[2];
				reverb_vocals[i]=base_reverb_vocals[i];
				max_reverb_vocals[i]=base_reverb_vocals[i]+q.reverb_range;

				damping_vocals[i]=msg[3];
			});
		});	
		//base_reverb_vocals.postln;
		q.player_out_right.set(\revtime_vocals, base_reverb_vocals, \damp_vocals, damping_vocals);
		q.player_out_left.set(\revtime_vocals, base_reverb_vocals, \damp_vocals, damping_vocals);
	}).add;	
	
	//now we define actions for the volume range slider
	q.volume_range_slider.action_({|v,x,y,m| 
		q.volume_range=(1-v.value+0.0001);
		
		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("volume_range", q.current_time.asString, q.volume_range.asString,"\n"));
		});

		q.num.do({arg i;
			min_volume_instrument[i]=base_volume_instrument[i]*q.volume_range;
			min_volume_vocals[i]=base_volume_vocals[i]*q.volume_range;
		});
		min_volume_instrument.postln;
					
	}).value=(1-q.volume_range+0.0001);


	//now we define actions for the reverb range slider
	q.reverb_range_slider.action_({|v,x,y,m| 
		q.reverb_range=v.value*max_reverb_range;
		
		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("reverb_range", q.current_time.asString, q.reverb_range.asString,"\n"));
		});

		q.num.do({arg i;
			max_reverb_instrument[i]=base_reverb_instrument[i]+q.reverb_range;
			max_reverb_vocals[i]=base_reverb_vocals[i]+q.reverb_range;
		});
					
	}).value=(q.reverb_range/max_reverb_range);
	
	//we want to define our features
	catArgs(q.current_directory,"/src/track_isolation.scd").load;
	catArgs(q.current_directory,"/src/mix_control.scd").load;
	catArgs(q.current_directory,"/src/musician_spatialization.scd").load;

	if(b!=nil,{
		if(b.isClosed,{
			q.createGUI_feature_control();
		});
	},{
		q.createGUI_feature_control();
	});
	//In a co-ordinate system where z points "in/out", y points "up/down", x points "left/right"
	//We are interested in x and z values.
	//The message format is as follows:
	//[ /client (0), body_part(1), player_id (2), X(3), Z(4), Y(5), pitch(6), yaw(7), roll(8)]
	//Note that we receive the messages for all three players
	q.info_osc = OSCresponderNode(nil, '/client', {arg time, resp, msg;			
		var player_received;
		//msg.postln;

		if(msg[2]==(-1),{
			player_received=q.player_num;
		},{
			player_received=msg[2];
		});
	
		if(msg[1].asString=="head",{
			if(player_received==q.player_num, {
				filter_head_yaw[player_received, counter%filter_size]=msg[7]*pi/180;
				filter_head_roll[player_received, counter%filter_size]=msg[8]*pi/180;
				
				msg[7]=((filter_head_yaw.rowAt(player_received).sum)/filter_size);	
				msg[8]=((filter_head_roll.rowAt(player_received).sum)/filter_size);
				
				mc_angle=(-1)*(msg[8]);

				//resend the osc messages to other players
				q.num.do({arg i;
					if(i!=q.player_num,{
						q.osc_addresses_57120[i].sendMsg("/client", msg[1], q.player_num, msg[3],msg[4],msg[5],msg[6],msg[7],msg[8]);
						q.osc_addresses_57121[i].sendMsg("/client", msg[1], q.player_num, msg[3],msg[4],msg[5],msg[6],msg[7],msg[8]);			
					});
				});
			});

			head_yaw[player_received]=msg[7];
			head_roll[player_received]=msg[8];
		});

		if(msg[1].asString=="torso",{
			if(player_received==q.player_num,{
				var limited_x, limited_y, scaled_x, scaled_y;
				//we limit the range based on our calibration results
				if(msg[3]<=q.kinect_min_x_actual,{
					limited_x=q.kinect_min_x_actual;
				},{
					if(msg[3]>=q.kinect_max_x_actual,{
						limited_x=q.kinect_max_x_actual;
					},{
						limited_x=msg[3];
					});
				});


				if(msg[5]<=q.kinect_min_y_actual,{
					limited_y=q.kinect_min_y_actual;
				},{
					if(msg[5]>=q.kinect_max_y_actual,{
						limited_y=q.kinect_max_y_actual;
					},{
						limited_y=msg[5];	
					});
				});

				//we scale it from the kinect's actual parameters to the kinect's ideal parameters before sending it back out
				scaled_x = (((limited_x-q.kinect_min_x_actual)*(q.kinect_max_x_ideal-q.kinect_min_x_ideal))/(q.kinect_max_x_actual-q.kinect_min_x_actual))+q.kinect_min_x_ideal;
				scaled_y = (((limited_y-q.kinect_min_y_actual)*(q.kinect_max_y_ideal-q.kinect_min_y_ideal))/(q.kinect_max_y_actual-q.kinect_min_y_actual))+q.kinect_min_y_ideal;
				filter_x_pos[player_received, counter%filter_size]=scaled_x;
				filter_y_pos[player_received, counter%filter_size]=scaled_y;
				filter_body_yaw[player_received, counter%filter_size]=msg[7]*pi/180;
					
				msg[3]=((filter_x_pos.rowAt(player_received).sum)/filter_size);
				msg[5]=((filter_y_pos.rowAt(player_received).sum)/filter_size);
				msg[7]=((filter_head_yaw.rowAt(player_received).sum)/filter_size);

				if(q.ms,{			
					ms_angle=(-1)*(msg[7]);
				},{
					ms_angle=0;
				});
				if(q.tp,{
					tp_angle=(-1)*(msg[7]);
				},{
					tp_angle=0;
				});

				//now we resend this message to both remote participants if we've received our own info						
				q.num.do({arg i;
					if(i!=q.player_num,{
						q.osc_addresses_57120[i].sendMsg("/client", msg[1], q.player_num, msg[3],msg[4],msg[5],msg[6],msg[7],msg[8]);
						q.osc_addresses_57121[i].sendMsg("/client", msg[1], q.player_num, msg[3],msg[4],msg[5],msg[6],msg[7],msg[8]);			
					});
				});

				counter=counter+1;
			});

			body_yaw[player_received]=msg[7];


			player_positions[player_received,0]=msg[3];
			player_positions[player_received,1]=msg[5];
			
			player_positions_adjusted_kinect_location[player_received,0]=player_positions[player_received,0];
			player_positions_adjusted_kinect_location[player_received,1]=(q.kinect_min_y_ideal+q.kinect_max_y_ideal)-player_positions[player_received,1];

			
			player_positions_translated[player_received,0]=player_positions[player_received,0]+q.translation[player_received,0];
			player_positions_translated[player_received,1]=player_positions[player_received,1]+q.translation[player_received,1];

			player_positions_translated_for_GUI[player_received,0]=player_positions_adjusted_kinect_location[player_received,0]+q.translation[player_received,0];
			player_positions_translated_for_GUI[player_received,1]=player_positions_adjusted_kinect_location[player_received,1]+q.translation[player_received,1];


			
			player_positions_rotated[player_received,0]=(q.rotation_matrix[player_received][0,0]*player_positions_translated[player_received,0])+(q.rotation_matrix[player_received][0,1]*player_positions_translated[player_received,1]);
			player_positions_rotated[player_received,1]=(q.rotation_matrix[player_received][1,0]*player_positions_translated[player_received,0])+(q.rotation_matrix[player_received][1,1]*player_positions_translated[player_received,1]);

			
			player_positions_rotated_for_GUI[player_received,0]=(q.rotation_matrix[player_received][0,0]*player_positions_translated_for_GUI[player_received,0])+(q.rotation_matrix[player_received][0,1]*player_positions_translated_for_GUI[player_received,1]);
			player_positions_rotated_for_GUI[player_received,1]=(q.rotation_matrix[player_received][1,0]*player_positions_translated_for_GUI[player_received,0])+(q.rotation_matrix[player_received][1,1]*player_positions_translated_for_GUI[player_received,1]);



			//we need to make the adjustments based on the current player's perspective
			player_positions_rotated_perspective[player_received,0]=(q.rotation_matrix[q.player_num][0,0]*player_positions_rotated_for_GUI[player_received,0])+(q.rotation_matrix[q.player_num][0,1]*player_positions_rotated_for_GUI[player_received,1]);
			player_positions_rotated_perspective[player_received,1]=(q.rotation_matrix[q.player_num][1,0]*player_positions_rotated_for_GUI[player_received,0])+(q.rotation_matrix[q.player_num][1,1]*player_positions_rotated_for_GUI[player_received,1]); 

			

			//positions have already been rotated and are in the appropriate quadrant
			//we still need to translate, then scale them so that they can be seen by our viewer
			player_positions_translated_viewer[player_received,0]=player_positions_rotated_perspective[player_received,0]-q.min_x;
			player_positions_translated_viewer[player_received,1]=player_positions_rotated_perspective[player_received,1]-q.min_y;
		
			player_positions_scaled[player_received,0] = player_positions_translated_viewer[player_received,0]*q.pos_viewer_ratio_x;
			player_positions_scaled[player_received,1] = player_positions_translated_viewer[player_received,1]*q.pos_viewer_ratio_y; 
			player_positions_viewer[player_received,0] = player_positions_scaled[player_received,0]+q.avatar_margin;
			player_positions_viewer[player_received,1] = q.viewer_total_height-player_positions_scaled[player_received,1]-q.avatar_margin;

			if(player_received==q.player_num,{
				if(q.save,{
					q.current_time=thisThread.clock.beats*1000-q.start_time;		
					q.file_position.putString(scatArgs(q.current_time.asString, player_positions[q.player_num,0].asString, player_positions			[q.player_num,1].asString, player_positions_rotated[q.player_num,0].asString, player_positions_rotated[q.player_num,1].asString, "\n"));
					q.file_orientation.putString(scatArgs(q.current_time.asString, head_roll[q.player_num].asString, head_yaw[q.player_num].asString, body_yaw[q.player_num].asString, "\n"));
				});



				//now we need to calculate the distances to each monitor
				if((q.dv||q.dr),{					
					q.num.do({arg i;
						q.num.do({arg j;
							if(i!=j,{
								distance_to_monitors[i,j]=(player_positions_rotated_perspective.rowAt(i)-monitor_position[i,j]).squared.sum.sqrt;
							});
						});
					});

					q.num.do({arg i;
						distance[i]=distance_to_monitors[i,q.player_num]+distance_to_monitors[q.player_num,i];	
					});
				});
				//distance[1].postln;
				q.num.do({arg i;
					if(i!=q.player_num,{
						if(q.dv,{
							var vol_other_instrument;
							var vol_other_vocals;
							vol_other_instrument=distance_to_monitors[i,q.player_num].linlin(0,q.max_dist/2, (0.5*base_volume_instrument[i]).ampdb, 1.ampdb).dbamp;
							vol_other_vocals=distance_to_monitors[i,q.player_num].linlin(0,q.max_dist/2, (0.5*base_volume_vocals[i]).ampdb, min_volume_vocals[i].ampdb).dbamp;
				
							if(distance_to_monitors[q.player_num,i]<(q.volume_threshold_near*q.max_dist/2),{
								volume_instrument[i]=base_volume_instrument[i]+vol_other_instrument;
								volume_vocals[i]=base_volume_vocals[i]+vol_other_vocals;
							});
							if((distance_to_monitors[q.player_num,i]>(q.volume_threshold_near*q.max_dist/2))&&(distance_to_monitors[q.player_num,i]<(q.volume_threshold_far*q.max_dist/2)),{
								volume_instrument[i]=distance[i].linlin(distance_to_monitors[i,q.player_num]+(q.volume_threshold_near*q.max_dist/2), distance_to_monitors[i,q.player_num]+(q.volume_threshold_far*q.max_dist/2),(base_volume_instrument[i]).ampdb, min_volume_instrument[i].ampdb, \minmax).dbamp+vol_other_instrument;
								volume_vocals[i]=distance[i].linlin(distance_to_monitors[i,q.player_num]+(q.volume_threshold_near*q.max_dist/2), distance_to_monitors[i,q.player_num]+(q.volume_threshold_far*q.max_dist/2),(base_volume_vocals[i]).ampdb, min_volume_vocals[i].ampdb, \minmax).dbamp+vol_other_vocals;
							
							});
							if(distance_to_monitors[q.player_num,i]>(q.volume_threshold_far*q.max_dist/2),{
							
								volume_instrument[i]=min_volume_instrument[i]+vol_other_instrument;	
								volume_vocals[i]=min_volume_vocals[i]+vol_other_vocals;
							});
						},{
							volume_instrument[i]=base_volume_instrument[i];		
							volume_vocals[i]=base_volume_vocals[i];
						});	

						
						if(q.dr,{
													
							if(distance_to_monitors[q.player_num,i]>(q.reverb_safe_threshold*(q.max_dist/2)),{
								reverb_instrument[i]=distance_to_monitors[q.player_num,i].linlin(q.reverb_safe_threshold*q.max_dist/2,q.max_dist/2, base_reverb_instrument[i], max_reverb_instrument[i], \minmax);
								reverb_vocals[i]=distance[i].linlin(q.reverb_safe_threshold*q.max_dist/2,q.max_dist/2, base_reverb_vocals[i], max_reverb_vocals[i], \minmax);							
							},{	
								reverb_instrument[i]=base_reverb_instrument[i];
								reverb_vocals[i]=base_reverb_vocals[i];
							});
						},{
							reverb_instrument[i]=base_reverb_instrument[i];
							reverb_vocals[i]=base_reverb_vocals[i];
						});
						
						damping_instrument[i]=(((reverb_instrument[i]-min_reverb)/(max_reverb_total-min_reverb))*(min_damping-max_damping))+max_damping;	
						damping_vocals[i]=(((reverb_vocals[i]-min_reverb)/(max_reverb_total-min_reverb))*(min_damping-max_damping))+max_damping;	
					});

				});		
	
				q.num.do({arg i;
					volume_left_instrument[i]=volume_instrument[i];		
					volume_right_instrument[i]=volume_instrument[i];
					volume_left_vocals[i]=volume_vocals[i];		
					volume_right_vocals[i]=volume_vocals[i];
				});	

				if(q.ms,{
					var temp = Array.newClear(4);
					temp = q.musician_spatialization(ms_angle, volume_instrument, volume_vocals, player_positions_viewer);
					volume_right_instrument = temp[0];
					volume_left_instrument = temp[1];
					volume_right_vocals = temp[2];
					volume_left_vocals = temp[3];
				});
			

				if(q.tp,{
					var temp = Array.newClear(4);					
					temp = q.track_panning(tp_angle, player_positions_viewer, volume_right_instrument, volume_left_instrument, volume_right_vocals, volume_left_vocals);
					volume_right_instrument = temp[0];
					volume_left_instrument = temp[1];
					volume_right_vocals = temp[2];
					volume_left_vocals = temp[3];
				});
				
				if(q.mc,{
					var temp = Array.newClear(4);					
					temp = q.mix_control(mc_angle, player_positions_viewer, volume_right_instrument, volume_left_instrument, volume_right_vocals, volume_left_vocals);
					volume_right_instrument = temp[0];
					volume_left_instrument = temp[1];
					volume_right_vocals = temp[2];
					volume_left_vocals = temp[3];
				});


				//"we now update our synth values".postln;
				q.player_out_right.set(\amp_instrument, volume_right_instrument, \amp_vocals, volume_right_vocals, \revtime_instrument, reverb_instrument, \revtime_vocals, reverb_vocals, \damp_instrument, damping_instrument, \damp_vocals, damping_vocals);
				q.player_out_left.set(\amp_instrument, volume_left_instrument, \amp_vocals, volume_left_vocals, \revtime_instrument, reverb_instrument, \revtime_vocals, reverb_vocals, \damp_instrument, damping_instrument, \damp_vocals, damping_vocals);		
			
			});	
			
			q.updateGUI(player_positions_viewer, distance, distance_to_monitors, head_roll, body_yaw);
			
		});
								
	}).add;
				
};



