#!/usr/bin/sclang

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

g.waitForBoot {
(
q.createGUI_start = { |q|
	var next_button, back_button;	
	var counter=0;
	var own_ip_answer, own_ip_question, other_ip_question, other_ip_answer;
	var ip_text;
	var ideal_height, ideal_width; 
	var x_pos, y_pos, x_size, y_size, font_size, gap;
	var warning;
	var flag1=true;
	var flag2=true;
	var flag3=true;
	var flag4=true;
	var flag5=true;
	var flag6=true;
	var next_flag;
	var dvm_box,esp_box, rms_box;
	var musician_label, features_question, dvm_label, esp_label, rms_label;

	q.x_ratio = 1; 
	q.y_ratio = 1;
	q.x_total = Window.availableBounds.right;
	q.y_total = Window.availableBounds.bottom;
	q.dvm=true;
	q.esp=true;
	q.rms=true;
	q.num=3;
	q.cond_string="";

	q.y_available = q.y_total-72;
	q.x_available = q.x_total-48;
	ideal_height = 900-72;
	ideal_width=1600;
	q.y_ratio = q.y_available/ideal_height;
	q.x_ratio = q.x_available/ideal_width;
	q.y_total;
	q.min_effective_ratio=[q.x_ratio,q.y_ratio].minItem;
	
	other_ip_answer=Array.newClear(q.num-1);

	//for starters we get our working directory
	q.current_directory = File.getcwd;
	

	//open up port 10 ports starting with 57120, this is where we send everything to
	thisProcess.openUDPPort(57120);
	thisProcess.openUDPPort(57121);
	
	ip_text=Array.newClear(q.num-1);
	musician_label=Array.newClear(q.num-1);

	q.player_num = 0;
	q.ip_addresses = Array.newClear(q.num);
	
	
	
	s=Window("Reactive Environment for Network Music Performance - Setup",Rect(0,0,q.x_available,q.y_total-48)).front;
	s.view.background_(Color.white);
	
	x_pos = 0;
	y_pos = (600*q.y_ratio).asInteger;
	x_size = q.x_available;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (25*q.min_effective_ratio).asInteger;
	warning=StaticText(s, Rect(x_pos, y_pos, x_size, y_size));
	warning.stringColor=Color.red;
	warning.align=\center;
	warning.font=Font("Calibri",font_size);


	x_pos = 0;
	y_pos = (25*q.y_ratio).asInteger;
	x_size = q.x_available;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	own_ip_question=StaticText(s, Rect(x_pos, y_pos, x_size, y_size));
	own_ip_question.font=Font("Calibri",font_size);
	own_ip_question.align=\center;
	own_ip_question.string = "What is your IP address?";
	own_ip_question.stringColor=Color.gray(0.4);


	x_pos = (q.x_available-(400*q.x_ratio).asInteger)/2;
	y_pos = (100*q.y_ratio).asInteger;
	x_size = (400*q.x_ratio).asInteger;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	own_ip_answer=TextField(s, Rect(x_pos, y_pos, x_size, y_size));
	own_ip_answer.font=Font("Calibri",font_size);
	own_ip_answer.stringColor=Color.gray(0.4);
	own_ip_answer.background=Color.new255(248,248,255);
	own_ip_answer.action = {arg field;
		q.ip_addresses[0] = field.value;
		own_ip_answer.string.postln;
	};


	x_pos = 0;
	y_pos = (175*q.y_ratio).asInteger;
	x_size = q.x_available;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	other_ip_question=StaticText(s, Rect(x_pos, y_pos, x_size, y_size));
	other_ip_question.align=\center;
	other_ip_question.font=Font("Calibri",font_size);
	other_ip_question.string = catArgs("What are the other musicians' IP addresses?");
	other_ip_question.stringColor=Color.gray(0.4);

	//we now want to know if IP addresses have been saved in the past
	
	x_pos = (q.x_available-(400*q.x_ratio).asInteger)/2;
	x_size = (400*q.x_ratio).asInteger;
	y_pos = (250*q.y_ratio).asInteger;
	gap = (75*q.y_ratio).asInteger;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;

	q.other_ip = Array.newClear(q.num-1);

	(q.num-1).do({arg i;
		other_ip_answer[i] = TextField(s, Rect(x_pos, y_pos+(i*gap), x_size, y_size));
		other_ip_answer[i].stringColor=Color.gray(0.4);
		other_ip_answer[i].font=Font("Calibri",font_size);
		other_ip_answer[i].background=Color.new255(248,248,255);
		other_ip_answer[i].action = {arg field;
			q.ip_addresses[i+1]=field.value;
		}; 
	});

	
	q.ip_addresses_file_name = catArgs(q.current_directory,"/settings/ip_addresses.txt");

	
	if(File.exists(q.ip_addresses_file_name),{
		//this means a calibration has been performed in the past
		var temp_string = "";
		var temp_params_values = Array.newClear(3);
		var temp_params_string;
		var counter = 0;

		q.ip_addresses_file= File(q.ip_addresses_file_name,"r");

		temp_params_string = q.ip_addresses_file.readAllString;

		temp_params_string.size.do({arg i;
			if(temp_params_string[i].asString!=";",{
				temp_string=catArgs(temp_string.asString,temp_params_string[i].asString);
			},{
				temp_params_values[counter]=temp_string;
				temp_string="";
				counter = counter+1;
			});
		});

		q.ip_addresses[0] = temp_params_values[0];
		own_ip_answer.string = temp_params_values[0];	
		q.ip_addresses[1] = temp_params_values[1];
		other_ip_answer[0].string = temp_params_values[1];
		q.ip_addresses[2] = temp_params_values[2];
		other_ip_answer[1].string = temp_params_values[2];

		q.ip_addresses_file.close;
	});


	x_pos = ((q.x_available-(400*q.x_ratio))/2-(130*q.x_ratio)).asInteger;
	y_pos = (260*q.y_ratio).asInteger;
	gap = (80*q.y_ratio).asInteger;
	x_size = (130*q.x_ratio).asInteger;
	y_size = (20*q.y_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger; 
	(q.num-1).do({arg i;
		musician_label[i] = StaticText(s, Rect(x_pos,y_pos+(i*gap),x_size,y_size));
		musician_label[i].string = catArgs("Musician "+ (i+1)); 	
		musician_label[i].font = Font("Calibri",font_size);
		musician_label[i].stringColor=Color.gray(0.4);
	});

	x_pos = 0;
	y_pos = (400*q.y_ratio).asInteger;
	x_size = q.x_available;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	features_question=StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	features_question.align=\center;
	features_question.font=Font("Calibri",font_size);
	features_question.string = ("Select performance features:");
	features_question.stringColor=Color.gray(0.4);

	x_pos = ((q.x_available-(400*q.x_ratio))/2).asInteger;
	y_pos = (475*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (30*q.y_ratio).asInteger;	
	dvm_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	dvm_box.value = 1;
	dvm_box.action = {arg value;
		if (value == 1,{
			q.dvm = true;
		},{
			q.dvm = false;
		});	
	};
		
	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (475*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	dvm_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	dvm_label.string = "Dynamic Volume Mixing"; 	
	dvm_label.font = Font("Calibri",font_size);
	dvm_label.stringColor=Color.gray(0.4);


	x_pos = ((q.x_available-(400*q.x_ratio))/2).asInteger;
	y_pos = (525*q.y_ratio).asInteger;
	x_size = (30*q.y_ratio).asInteger;
	y_size = (30*q.x_ratio).asInteger;	
	esp_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	esp_box.value = 1;
	esp_box.action = {arg value;
		if (value == 1,{
			q.esp = true;
		},{
			q.esp = false;
		});	
	};

	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (525*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	esp_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	esp_label.string = "Enhanced Stereo Panning"; 	
	esp_label.font = Font("Calibri",font_size);
	esp_label.stringColor=Color.gray(0.4);



	x_pos = ((q.x_available-(400*q.x_ratio))/2).asInteger;
	y_pos = (575*q.y_ratio).asInteger;
	x_size = (30*q.y_ratio).asInteger;
	y_size = (30*q.x_ratio).asInteger;	
	rms_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	rms_box.value = 1;
	rms_box.action = {arg value;
		if (value == 1,{
			q.rms = true;
		},{
			q.rms = false;
		});	
	};

	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (575*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	rms_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	rms_label.string = "Remote Musician Spatialization"; 	
	rms_label.font = Font("Calibri",font_size);
	rms_label.stringColor=Color.gray(0.4);




	x_pos = (q.x_available-(((250+25)*q.x_ratio))).asInteger;
	y_pos = (q.y_available-(((100+25)*q.y_ratio))).asInteger;
	x_size = (250*q.x_ratio).asInteger;
	y_size = (100*q.y_ratio).asInteger;
	font_size= (30*q.min_effective_ratio).asInteger;


	next_button = GUI.button.new(s, Rect(x_pos,y_pos,x_size,y_size));
	next_button.font=Font("Calibri", font_size, bold:true);
	next_button.states = [[ "Next ",Color.black, Color.new255(48,120,0)]];
	next_button.action=({|view|
		next_flag=true;	
		block({|break|	
			flag1=(own_ip_answer.string=="");
			flag2=(own_ip_answer.string==" ");
			flag3=(own_ip_answer.string==nil);
			if((flag1||flag2||flag3),{				
				warning.string="Please enter your IP address.";			
				next_flag=false;
				break.value(0);
			});

						
			(q.num-1).do({arg i;
				flag4=(other_ip_answer[i].string=="");
				flag5=(other_ip_answer[i].string==" ");
				flag6=(other_ip_answer[i].string==nil);
				if((flag4||flag5||flag6),{				
					warning.string="Please enter Musician " + (i+1) + "'s IP address";			
					next_flag=false;
					break.value(0);
				});
			});	


		}); 
		if(next_flag, {
			s.close();
			q.createGUI_main();
		});

		//we also want to save the IP addresses to file.
		q.ip_addresses_file = File(q.ip_addresses_file_name,"w");
		q.ip_addresses_file.write(catArgs(q.ip_addresses[0].asString,";",q.ip_addresses[1].asString,";",q.ip_addresses[2].asString,";"));
		q.ip_addresses_file.close;
	});
	

};


q.createGUI_main = { |q|
	var pos_window;
	var connect_label;
	var on_off=0;
	var colors;
	var color_array;
	var range_label, min_label, max_label;	
	var left_margin=0;
	var ideal_height; 
	var x_pos,y_pos,x_size,y_size,font_size;

	q.volume_image=Array.newClear(4);

	q.connected=false;

	left_margin = (q.x_available/3).asInteger;
	
	
	w= Window("Reactive Environment for Network Music Performance",Rect(0,0,q.x_available,q.y_total-48)).front;
	w.view.background_(Color.white);	

	x_pos =  (125*q.x_ratio).asInteger;
	y_pos = (25*q.y_ratio).asInteger;
	x_size = (300*q.x_ratio).asInteger;
	y_size = (100*q.y_ratio).asInteger;
	font_size = (25*q.min_effective_ratio).asInteger;
	q.calibrate_button = GUI.button.new(w, Rect(x_pos, y_pos, x_size, y_size));
	q.calibrate_button.font=Font("Calibri",font_size, bold:true);
	q.calibrate_button.states=[["Calibration: 0%",Color.black,Color.new255(255,255,150)],["Start Calibration", Color.black, Color.new255(255,255,150)]];
	q.calibrate_button.valueAction=1;	
	
	x_pos = 0;
	y_pos = (125*q.y_ratio).asInteger;
	x_size = left_margin;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	q.calibrate_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	q.calibrate_label.align=\center;
	q.calibrate_label.font = Font("Calibri", font_size, bold:true);		
	q.calibrate_label.string = "Click to calibrate Kinect.";
	
	

	x_pos = (125*q.x_ratio).asInteger;
	y_pos = (200*q.y_ratio).asInteger;
	x_size = (300*q.x_ratio).asInteger;
	y_size = (100*q.y_ratio).asInteger;
	font_size = (25*q.min_effective_ratio).asInteger;
	q.connect_button = GUI.button.new(w, Rect(x_pos, y_pos, x_size, y_size));
	q.connect_button.font=Font("Calibri",font_size, bold:true);
	q.connect_button.states=[[ "Start Performance", Color.black, Color.new255(48,120,0)],[ "Stop Performance", Color.black, Color.new255(162,0,0)]];
	
	x_pos = 0;
	y_pos = (300*q.y_ratio).asInteger;
	x_size = left_margin;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	q.connect_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	q.connect_label.align=\center;
	q.connect_label.font = Font("Calibri", font_size, bold:true);		
	q.connect_label.string = "You are now disconnected.";
	
	x_pos = ((left_margin-(20*q.x_ratio))/2).asInteger;
	y_pos = (375*q.y_ratio).asInteger;
	x_size = (20*q.x_ratio).asInteger;
	y_size = (250*q.min_effective_ratio).asInteger;
	q.volume_slider=Slider(w,Rect(x_pos, y_pos, x_size, y_size));
	q.volume_slider.enabled=false;
	

	4.do({arg i;
		q.volume_image[i] = Image.open(catArgs(q.current_directory,"/figures/volume_",i,".jpg" ));
	}); 

	x_pos = ((left_margin-50)/2).asInteger;
	y_pos = (650*q.y_ratio).asInteger;
	x_size = 50;
	y_size = 50;	
 	q.volume_icon = UserView(w, Rect(x_pos, y_pos, x_size, y_size));
   	q.volume_icon.drawFunc = { 
           Pen.image(q.volume_image[0]); 
   	}; 


	x_pos = 0;
	y_pos = (725*q.y_ratio).asInteger;
	x_size = left_margin;
	y_size = (40*q.y_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	range_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	range_label.font = Font("Calibri", font_size);
	range_label.align=\center;
	range_label.string = "Sensitivity of Dynamic Volume Mixing";

	 
	x_pos = (40*q.x_ratio).asInteger;
	y_pos = (725*q.y_ratio).asInteger;
	x_size = left_margin-(2*(40*q.x_ratio));
	y_size = (80*q.y_ratio).asInteger;
	q.range_slider = Slider(w, Rect(x_pos, y_pos, x_size, y_size));
	q.range_slider.enabled=false;

	x_pos = (17*q.x_ratio).asInteger;
	y_pos = (785*q.y_ratio).asInteger;
	x_size = (100*q.x_ratio).asInteger;
	y_size = (15*q.y_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	min_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	min_label.align=\left;
	min_label.font = Font("Calibri", font_size, bold:true);		
	min_label.string = "30dB";
		
	
	x_pos = left_margin-(40*q.x_ratio).asInteger-((75-17)*q.x_ratio).asInteger;
	y_pos = (785*q.y_ratio).asInteger;
	x_size = (100*q.x_ratio).asInteger;
	y_size = (15*q.y_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	max_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	max_label.align=\center;
	max_label.font = Font("Calibri", font_size, bold:true);		
	max_label.string = "100dB";		




	//now we set all values related to the viewer
	q.viewer_total_width = q.x_available-left_margin-25;
	q.viewer_total_height = q.y_available-50;

	c = UserView(w, Rect(left_margin,25,q.viewer_total_width,q.viewer_total_height));
	c.background_(Color.gray(0.8));

	


	q.calibrate_button.action = ({|view|	
			if(view.value==0, {
				q.calibrate_label.string = "Please move around your space while we collect samples.";
				q.kinect_calibration_part_1();
			});		
	});



	q.connect_button.action=({|view|
		if(view.value==1, {
			"connecting".postln;
			q.connect_label.string = "Waiting for other musicians...";
			q.establish_connection();

		},{
			/*"Stopping system!".postln;
			q.stopjam();*/
			"disconnecting".postln;
			q.drop_connection();
		});
	});



	w.front;
	
	q.connected=false;

	
	w.onClose={
		if(q.connected,{
			q.drop_connection;
		});
	};

	//set up osc_addresses

	q.ip_addresses_sorted = Array.newClear(q.num);
	q.player_order = Array.newClear(q.num);

	q.num.do({arg i;
		q.ip_addresses_sorted[i]=q.ip_addresses[i];
	});
	q.ip_addresses_sorted.sort;	

	
	q.num.do({arg i;
		if(q.ip_addresses_sorted[i]==q.ip_addresses[0],{
			q.player_num=i;
		});
	});

	q.num.do({arg i;
		q.num.do({arg j;
			//the sorted ip addresses determine our player number
			if(q.ip_addresses[j]==q.ip_addresses_sorted[i],{
				q.player_order[i]=j;
			});
		});
	});

	
	q.player_labels=Array.newClear(q.num);
	q.num.do({arg i;
		q.player_labels[i]=StaticText(w);
		q.player_labels[i].font=Font("Calibri",(20*q.min_effective_ratio).asInteger);
		q.player_labels[i].stringColor=Color.black;
		q.player_labels[i].align=\center;
		if(i==q.player_num,{
			q.player_labels[i].string = "";
		},{
			q.player_labels[i].string = q.player_order[i].asString;
		});
	});	

	q.osc_addresses_57120=Array.newClear(q.num);
	q.osc_addresses_57121=Array.newClear(q.num);
	
	q.num.do({arg i;
		q.osc_addresses_57120[i]=NetAddr(q.ip_addresses_sorted[i],57120);
		q.osc_addresses_57121[i]=NetAddr(q.ip_addresses_sorted[i],57121);	
	});


	"now we set up the room parameters".postln;
	q.kinect_parameters_part_1();
	
};

q.establish_connection = { |q|
	
	var connection_flags = Array.newClear(q.num);
	var in_channel=0;
	var connection_sent=Array.newClear(q.num);
	var connection_received=Array.newClear(q.num);			
	var test;
	var counter;

	q.calibrate_button.enabled=false;
	q.calibrate_label.stringColor=Color.grey(0.8);

	q.jmess_cmd = catArgs("jmess -D -c ", q.current_directory,"/jmess_files/jmess_for_musician_",q.player_num,".xml");
	

	q.num.do({arg i;
		connection_sent[i]=0;
		connection_received[i]=0;
	});
			
	q.connected = true;	

	q.jacktrip_s_ports = Array.newClear(q.num);
	q.jacktrip_c_ports = Array.newClear(q.num);
	q.jacktrip_s_command = Array.newClear(q.num);
	q.jacktrip_c_command = Array.newClear(q.num);	


	//we want the names to always be "Musician 1" and "Musician 2" but the ports will reflect the musician numbers assigned.
	q.num.do({arg i;
		q.jacktrip_s_ports[i]=10*((q.player_num*q.num)+i);
		q.jacktrip_s_command[i]=catArgs("jacktrip -s -o ", q.jacktrip_s_ports[i]);
		q.jacktrip_c_ports[i]=10*((i*q.num)+q.player_num);
		q.jacktrip_c_command[i]=catArgs("jacktrip -c ", q.ip_addresses_sorted[i], " -o ", q.jacktrip_c_ports[i], " --clientname musician_",i); 
	});	



	//in any case, we want to set up the jacktrip connections	
	q.num.do({arg i;
		if(i!=q.player_num,{
			q.jacktrip_s_command[i].unixCmd;
			q.jacktrip_c_command[i].unixCmd;
		});		
	});

	"we've now set up the terminal connections".postln;	

	w.front;

	//now we send a message to the other musicians to tell them we are online
	q.num.do({arg i;
		if(i!=q.player_num,{
			q.osc_addresses_57120[i].sendMsg("/connection", q.player_num, 1);
			q.osc_addresses_57121[i].sendMsg("/connection", q.player_num, 1);
		});
	});	

	
	//now we see if we have received any messages from the other machines
	
	q.connect_node = OSCresponder(nil, '/connection',{arg time, resp, msg;	
			msg.postln;						
			//this means we have received a message from a particlar player
			connection_received[msg[1]]=msg[2]; //this is a matrix e.g. [0,1,0] means player 1 is connected


			//if another musician tells us they've connected, we send them back a message to them we're connected.
			if(connection_received[msg[1]]==1,{
				if(connection_sent[msg[1]]==0,{
					q.osc_addresses_57120[msg[1]].sendMsg("/connection", q.player_num, 1);
					q.osc_addresses_57121[msg[1]].sendMsg("/connection", q.player_num, 1);
					connection_sent[msg[1]]=1;
				});
			},{
				//if another musician tells us they've disconnected, we clear their flag so we can send back a message to them once they've reconnected.
				connection_sent[msg[1]]=0;
			});		
		
			if(connection_received==[0,0,0],{
				q.connect_label.string="No other musicians are connected.";
			});
			
			if(q.connected,{
				if(q.player_num==0,{
					if(connection_received==[0,1,0],{
						q.connect_label.string="Musician "+q.player_order[1]+" is now connected.";
					});
					if(connection_received==[0,0,1],{
						q.connect_label.string="Musician "+q.player_order[2]+" is now connected.";
					});	
					if(connection_received==[0,1,1],{
						q.connect_label.string="All musicians are now connected.";
					});
				});
					//we know we received messages from player 0, who is "Musician 2"
				if(q.player_num==1,{
					if(connection_received==[1,0,0],{
						q.connect_label.string="Musician "+q.player_order[0]+" is now connected.";
					});
					if(connection_received==[0,0,1],{
						q.connect_label.string="Musician "+q.player_order[2]+" is now connected.";
					});	
					if(connection_received==[1,0,1],{
						q.connect_label.string="All musicians are now connected.";
					});
				});
	
				if(q.player_num==2,{
					if(connection_received==[1,0,0],{
						q.connect_label.string="Musician "+q.player_order[0]+" is now connected.";
					});
					if(connection_received==[0,1,0],{
						q.connect_label.string="Musician "+q.player_order[1]+" is now connected.";
					});	
					if(connection_received==[0,1,1],{
						q.connect_label.string="All musicians are now connected.";
					});
			
				});

				//we also send our calibration values to the other musicians 
				if(q.calibration_performed,{
					q.num.do({arg i;
						if(i!=q.player_num,{
							q.osc_addresses_57120[i].sendMsg("/kinect_params", q.player_num, q.kinect_min_x[q.player_num], q.kinect_max_x[q.player_num], q.kinect_min_y[q.player_num], q.kinect_max_y[q.player_num]);
							q.osc_addresses_57121[i].sendMsg("/kinect_params", q.player_num, q.kinect_min_x[q.player_num], q.kinect_max_x[q.player_num], q.kinect_min_y[q.player_num], q.kinect_max_y[q.player_num]);
						});
					});
				});
	
				q.jmess_cmd.unixCmd;
			});
			
		}).add;	
		


		//we start things up from our end anyway
		"sleep 3".unixCmd{|res1,pid1|		
			q.jmess_cmd.unixCmd{|res2,pid2|	
				w.front;
				q.startjam();
			};
		};

};

q.drop_connection = {|q|
	
	q.connected=false;
	q.connect_label.string="You are now disconnected.";
	q.connect_node.remove;
	"killall jacktrip".unixCmd;

	
	q.num.do({arg i;
		if(i!=q.player_num,{
			q.osc_addresses_57120[i].sendMsg("/connection", q.player_num, 0);
			q.osc_addresses_57121[i].sendMsg("/connection", q.player_num, 0);
		});
	});

	q.stopjam();

};

q.kinect_parameters_part_1 = {|q|
	

	q.kinect_min_x = Array.newClear(q.num);
	q.kinect_min_y = Array.newClear(q.num);
	q.kinect_max_x = Array.newClear(q.num);
	q.kinect_max_y = Array.newClear(q.num);


	q.kinect_params_file_name = catArgs(q.current_directory,"/settings/kinect_parameters_local.txt");


	if(File.exists(q.kinect_params_file_name),{
		//this means a calibration has been performed in the past
		var temp_string = "";
		var temp_params_values = Array.newClear(4);
		var temp_params_string;
		var counter = 0;

		q.calibration_performed = true;
		q.kinect_params_file= File(q.kinect_params_file_name,"r");

		temp_params_string = q.kinect_params_file.readAllString;
		temp_params_string.size.do({arg i;
			if(temp_params_string[i].asString!=";",{
				temp_string=catArgs(temp_string.asString,temp_params_string[i].asString);
			},{
				temp_params_values[counter]=temp_string;
				temp_string="";
				counter = counter+1;
			});
		});

		q.kinect_min_x[q.player_num] = temp_params_values[0].asFloat;		
		q.kinect_min_y[q.player_num] = temp_params_values[1].asFloat;
		q.kinect_max_x[q.player_num] = temp_params_values[2].asFloat;
		q.kinect_max_y[q.player_num] = temp_params_values[3].asFloat;

		q.kinect_params_file.close;
					
	},{
		//if a file doesn't already exist, it means no calibration has ever been performed.
		//we assign default values
		q.calibration_performed = false;
		q.kinect_min_x[q.player_num] = 0.2;
		q.kinect_min_y[q.player_num] = 0.7;
		q.kinect_max_x[q.player_num] = 0.8;
		q.kinect_max_y[q.player_num] = 1.3;
	});

	//in any case, we want to give the other musicians default values for now:
	q.num.do({arg i;
		if(i!=q.player_num,{
			q.kinect_min_x[i] = 0.2;
			q.kinect_min_y[i] = 0.7;
			q.kinect_max_x[i] = 0.8;
			q.kinect_max_y[i] = 1.3;
		});
	});

	//we want to set up a node that listens to any new calibration data from the other musicians
	q.kinect_osc = OSCresponderNode(nil, '/kinect_params', {arg time, resp, msg;
		q.kinect_min_x[msg[1]] = msg[2];
		q.kinect_max_x[msg[1]] = msg[3];
		q.kinect_min_y[msg[1]] = msg[4];
		q.kinect_max_y[msg[1]] = msg[5];
		q.kinect_parameters_part_2();
	}).add;


	//we create a second function that is called whenever we calibrate or receive new parameters
	q.kinect_parameters_part_2();

};

q.kinect_parameters_part_2 = {|q|

	var kinect_corners_translated = Array2D.new(q.num,4);
	
	var all_x=Array.newClear(q.num*4);
	var all_y=Array.newClear(q.num*4);

	var rotated_max_height = Array.newClear(q.num); 
	var rotated_max_width = Array.newClear(q.num);

	var effective_viewer_height, effective_viewer_width;
	var max_height, max_width;
	var kinect_width = Array.newClear(q.num);
	var kinect_height = Array.newClear(q.num);
	var all_distances = Array.newClear(72);
	var counter=0;

	
	q.kinect_corners_rotated=Array2D.new(q.num,4);
	q.kinect_corners_actual = Array2D.new(q.num,4);
	
	q.num.do({arg i;
		4.do({arg j;
			q.kinect_corners_actual[i,j]=[0,0];
			kinect_corners_translated[i,j]=[0,0];
		});
	});

	q.num.do({arg i;
		q.kinect_corners_actual[i,0][0]=q.kinect_max_x[i]; //0.8
		q.kinect_corners_actual[i,1][0]=q.kinect_min_x[i]; //0.2
		q.kinect_corners_actual[i,2][0]=q.kinect_min_x[i]; //0.2
		q.kinect_corners_actual[i,3][0]=q.kinect_max_x[i]; //0.8

		q.kinect_corners_actual[i,0][1]=q.kinect_min_y[i]; //0.7
		q.kinect_corners_actual[i,1][1]=q.kinect_min_y[i]; //0.7
		q.kinect_corners_actual[i,2][1]=q.kinect_max_y[i]; //1.3
		q.kinect_corners_actual[i,3][1]=q.kinect_max_y[i]; //1.3
	});	

	q.num.do({arg i;		
		kinect_width[i]=q.kinect_max_x[i]-q.kinect_min_x[i];
		kinect_height[i]=q.kinect_max_y[i]-q.kinect_min_y[i];
	});
	
	q.translation = Array2D.new(q.num,2);


	q.num.do({arg i;
		q.translation[i,0] = (-1)*(q.kinect_min_x[i]+(kinect_width[i]/2));
		q.translation[i,1] = (-1)*(q.kinect_max_y[i]+((kinect_width[i]/2)*tan(pi/6)));
	});

	q.num.do({arg i;
		4.do({arg j;
			kinect_corners_translated[i,j][0]=q.kinect_corners_actual[i,j][0]+q.translation[i,0];
			kinect_corners_translated[i,j][1]=q.kinect_corners_actual[i,j][1]+q.translation[i,1];
		});
	});


	q.rotation_matrix = Array.newClear(q.num);
	q.num.do({arg i;
		q.rotation_matrix[i]=Array2D.new(2,2);
	});

	
	q.perspective_angle=Array.newClear(q.num);
		
	q.num.do({arg i;
		q.perspective_angle[i]=((q.num-q.player_num+i)%q.num)*(-120)*pi/180;
	});

	q.perspective_angle.postln;

	q.num.do({arg i;
		q.rotation_matrix[i][0,0]=cos(q.perspective_angle[i]);
		q.rotation_matrix[i][0,1]=(-1)*sin(q.perspective_angle[i]);
		q.rotation_matrix[i][1,0]=sin(q.perspective_angle[i]);
		q.rotation_matrix[i][1,1]=cos(q.perspective_angle[i]);
	});

	q.body_yaw_rot_angles = Array.newClear(q.num);

	q.num.do({arg i;
		if(i!=q.player_num,{
			var temp;
			temp=(q.num-q.player_num+i)%q.num;	
			q.body_yaw_rot_angles[i]=((-1).pow(temp))*(60*pi/180);
		},{
		
			q.body_yaw_rot_angles[i]=0;
		});
	});



	q.num.do({arg i;
		4.do({arg j;
			q.kinect_corners_rotated[i,j]=[0,0];
		});
	});
	
	q.num.do({arg i;
		4.do({arg j;
			q.kinect_corners_rotated[i,j][0]=(q.rotation_matrix[i][0,0]*kinect_corners_translated[i,j][0])+(q.rotation_matrix[i][0,1]*kinect_corners_translated[i,j][1]);
			q.kinect_corners_rotated[i,j][1]=(q.rotation_matrix[i][1,0]*kinect_corners_translated[i,j][0])+(q.rotation_matrix[i][1,1]*kinect_corners_translated[i,j][1]);	
		});
	});

	//now we find the room's mininum and maximum dimensions
	q.num.do({arg i;
		4.do({arg j;
			all_x[(i*4)+j]=q.kinect_corners_rotated[i,j][0];
			all_y[(i*4)+j]=q.kinect_corners_rotated[i,j][1];
		});	
	});	
	
	q.max_y;
	q.kinect_corners_rotated;
	q.min_x=all_x.minItem;
	q.min_y=all_y.minItem;
	q.max_x=all_x.maxItem;	
	q.max_y=all_y.maxItem;


	q.head_radius = 30*q.min_effective_ratio;
	q.shoulder_length = 60*q.min_effective_ratio; //note this is only half the length
	q.shoulder_width = 20*q.min_effective_ratio; //note this is only half the width;

	//this is the margin we should be leaving along in the viewer
	q.avatar_margin=q.shoulder_length+q.shoulder_width;
	effective_viewer_width=q.viewer_total_width-(2*q.avatar_margin);
	effective_viewer_height=q.viewer_total_height-(2*q.avatar_margin);

	max_width = (q.max_x-q.min_x).abs;
	max_height = (q.max_y-q.min_y).abs;

	q.num.do({arg i;
		4.do({arg j;
			q.num.do({arg m;
				4.do({arg n;
					if(((i!=m)&&(j!=n)),{					
						all_distances[counter]=(q.kinect_corners_rotated[i,j]-q.kinect_corners_rotated[m,n]).squared.sum.sqrt;
						counter=counter+1;
					});
				});
			});
		});
	});

	q.max_dist = all_distances.maxItem;
	q.min_dist = all_distances.minItem;
	//now we calculate our new ratios
	q.pos_viewer_ratio_x = effective_viewer_width/max_width;
	q.pos_viewer_ratio_y = effective_viewer_height/max_height;

	q.kinect_corners_actual.postln;

};


q.kinect_calibration_part_1 = { |q|
	//this function is activated when we press the "calibrate" button. It only pertains to the local user. Values can then be sent to remote users.	
	
	var kinect_command_with_window;
	var counter = 0;
	var counter_limit = 1000;
	var calibration_status;
	var x_array = Array.newClear(counter_limit);
	var y_array = Array.newClear(counter_limit);

	q.calibration_performed = true;

	//first we disconnect to avoid any confusion; 
	q.disconnect();	
	
	//now we disable to the start/connect button
	q.connect_button.enabled=false;
	q.connect_label.stringColor=Color.grey(0.8);
	q.calibrate_button.enabled=false;
	

	//start the kinect
	kinect_command_with_window=catArgs("cd OSCeleton_for_NMP &&./osceleton_for_NMP -xt -p ", NetAddr.langPort," -w");	
	kinect_command_with_window.unixCmd;

	//set up a node to listen to incoming messaged from the kinect.		
	q.kinect_calibration_data= OSCresponder(nil, '/client',{arg time, resp, msg;	
	//The message format is as follows:
	//[ /client (0), body_part(1), player_id (2), X(3), Z(4), Y(5), pitch(6), yaw(7), roll(8)]
		if(msg[2]==(-1),{
			if(counter<counter_limit,{
				x_array[counter]=msg[3];
				y_array[counter]=msg[5];
				counter=counter+1;
				calibration_status = ((counter/counter_limit)*100).asInteger;
				q.calibrate_button.states=[[catArgs("Calibration: ",calibration_status.asString,"\%"),Color.black,Color.new255(255,255,150)],["Start Calibration", Color.black, Color.new255(255,255,150)]];
				q.calibrate_button.refresh;
				counter.postln;
			},{
				"killall osceleton_for_NMP".unixCmd;
				q.kinect_calibration_data.remove; //this might not work?
				q.kinect_calibration_part_2(x_array,y_array);
			});
		});		
		
			
	}).add;

};

q.kinect_calibration_part_2 = { |q, x_array, y_array|
	
	//in this function we write the results of our calibration to file and send it to the other players.	
	

	q.kinect_min_x[q.player_num] = x_array.minItem;
	q.kinect_max_x[q.player_num] = x_array.maxItem;
	q.kinect_min_y[q.player_num] = y_array.minItem;
	q.kinect_max_y[q.player_num] = y_array.maxItem;


	//we also want to write this new calibration data to our local file
	q.kinect_params_file = File(q.kinect_params_file_name,"w");
	q.kinect_params_file.write(catArgs(q.kinect_min_x[q.player_num].asString,";",q.kinect_min_y[q.player_num].asString,";",q.kinect_max_x[q.player_num].asString,";",q.kinect_max_y[q.player_num].asString,";"));
	q.kinect_params_file.close;


	q.connect_button.enabled=true;
	q.connect_label.stringColor=Color.black;
	q.calibrate_button.enabled=true;
	q.calibrate_label.stringColor=Color.black;
	q.calibrate_button.valueAction = 1;
	q.calibrate_label.string = "Calibration complete!";	

	q.kinect_parameters_part_2();

};

q.startjam = { |q|
	
	var file_names=Array.newClear(4);
	var in_channels=Array.newClear(q.num);
	var out_channels=[1,0]; //note that right is 1, left is 0.

	//we define all variables related to volume changes
	var base = Array.newClear(q.num);
	var loudness_range = 30.dbamp; //each local musician sets a loudness range that only they experience
	var max_volume = Array.newClear(q.num); //each musician has a maximum volume that is a function of their current volume + loudness range
	var volume = Array.newClear(q.num);

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

	//we define all variables related to esp
	var esp_angle = 0;
	var rms_angle = 0;
	var head_roll = Array.newClear(q.num);
	var head_yaw = Array.newClear(q.num);
	var body_yaw = Array.newClear(q.num);
	var volume_left = Array.newClear(q.num);
	var volume_right = Array.newClear(q.num);
	var right_to_left=[0,0];	
	var esp_angle_thresh=5*pi/180;
	var esp_adjusted_angle=0;
	var esp_direction=0;
	var pan_pos=0;

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


	q.started = true;
	q.volume_slider.enabled=true;
	q.range_slider.enabled=true;
	q.current_time=0;	
	q.esp_active=false;


	q.num.do({arg i;
		q.num.do({arg j;
			monitor_position[i,j]=[0,0];
		});
	});		

	//in 434, left monitor leads to 436, right monitor leads to 435
	monitor_position[0,1]=q.kinect_corners_rotated[0,1]; //left monitor
	monitor_position[0,2]=q.kinect_corners_rotated[0,0]; //right monitor
	//in 435, left monitor leads to 434, right monitor leads to 434
	monitor_position[1,0]=q.kinect_corners_rotated[1,3]; //right monitor
	monitor_position[1,2]=q.kinect_corners_rotated[1,0]; //left monitor
	//in 436, left monitor leads to 435, right monitor leads to 434
	monitor_position[2,0]=q.kinect_corners_rotated[2,0]; //right monitor
	monitor_position[2,1]=q.kinect_corners_rotated[2,3]; //left monitor


	if(q.base_local==nil,{
		q.base_local=0;
	});


	//initialize our arrays
	q.num.do({arg i;
		if(i==q.player_num,{
			base[i]=q.base_local;
		},{
			base[i]=0;
		});
		volume[i]=base[i];
		max_volume[i]=volume[i]+loudness_range;
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

		in_channels[i]=i;
		volume_right[i]=0;
		volume_left[i]=0;
		q.num.do({arg j;
			distance_to_monitors[i,j]=0;
		});
	});




	q.num.do({arg i;
		filter_size.do({arg j;
			filter_head_roll[i,j]=0;
			filter_head_yaw[i,j]=0;
			filter_body_yaw[i,j]=0;
			filter_x_pos[i,j]=q.kinect_corners_actual[i,1][0];
			filter_y_pos[i,j]=q.kinect_corners_actual[i,1][1];
		});
	});


	base[q.player_num]=q.base_local;			
	volume[q.player_num]=q.base_local;

	t=Task.new({
		if(q.num==4, {
			SynthDef(\player_mix,{ |amp=#[0,0,0,0], channel_out, angle|	 
				var source=Array.newClear(q.num);
				var source_total;								
				(q.num).do({arg i;
					source[i]=SoundIn.ar(in_channels[i],amp[i]);
				});		
				source_total=source.sum/q.num;				
				Out.ar(channel_out,source_total);
			}).add;	
		},{
			SynthDef(\player_mix,{ |amp=#[0,0,0], channel_out, angle|	 
				var source=Array.newClear(q.num);
				var source_total;								
				(q.num).do({arg i;
					source[i]=SoundIn.ar(in_channels[i],amp[i]);
				});		
				source_total=source.sum/q.num;				
				Out.ar(channel_out,source_total);
			}).add;
		});

		l.sync;
	
		//we initialize our local player synth
		q.player_out_right = Synth(\player_mix, [\amp, volume,\channel_out, out_channels[0],\angle, 0]);
		q.player_out_left = Synth(\player_mix, [\amp, volume,\channel_out, out_channels[1],\angle, 0]);	
		"we've initialized our synth now".postln;

		//we want to inquire about other musicians' volumes when we start the jam
		//we only need to do this once at the start of a jam
		q.num.do({arg i;
			if(i!=q.player_num,{
				q.osc_addresses_57120[i].sendMsg("/vol_inq",q.player_num);
				q.osc_addresses_57121[i].sendMsg("/vol_inq",q.player_num);
			});
		});
	
	});

	t.play;	

	//now we get the volume
	q.volume_slider.action_({|v,x,y,m| 
		base[q.player_num]=(v.value*50);
		q.base_local=base[q.player_num];
		base.postln;
		volume[q.player_num]=base[q.player_num];
		max_volume[q.player_num] = base[q.player_num] + loudness_range;
		q.player_out_right.set(\amp, base);
		q.player_out_left.set(\amp, base);
		//we should also send this new volume to the other musicians
		q.num.do({arg i;
			if(i!=q.player_num,{
				q.osc_addresses_57120[i].sendMsg("/vol_base", q.player_num, base[q.player_num]);
				q.osc_addresses_57121[i].sendMsg("/vol_base", q.player_num, base[q.player_num]);
			});
		});

	
		if(q.volume_slider.value==0,{
			q.volume_icon.drawFunc = { 
           			Pen.image(q.volume_image[0]); 
   			};
		});
		if((q.volume_slider.value<=0.33)&&(q.volume_slider.value>0),{
			q.volume_icon.drawFunc = { 
           			Pen.image(q.volume_image[1]); 
   			};
		}); 	
		if((q.volume_slider.value>0.33)&&(q.volume_slider.value<=0.66),{
			q.volume_icon.drawFunc = { 
           			Pen.image(q.volume_image[2]); 
   			};
		});
		if(q.volume_slider.value>0.66,{
			q.volume_icon.drawFunc = { 
           			Pen.image(q.volume_image[3]); 
   			};
		});
	}).value=(q.base_local/50);




	q.base_local.postln;

	//we also want to receive the volume from the other musicians
	q.volume_osc = OSCresponderNode(nil, '/vol_base', {arg time, resp, msg;
		//our messages are formatted as [/vol, player_id, volume]
		msg.postln;		
		q.num.do({arg i;
			if(msg[1]==i,{
				base[i]=msg[2];
				max_volume[i]=base[i]+loudness_range;
			});
		});	
		base.postln;
		q.player_out_right.set(\amp, base);
		q.player_out_left.set(\amp, base);
	}).add;	

	//we have received an inquiry. we send back our own volume.
	q.volume_inquiry = OSCresponderNode(nil, '/vol_inq', {arg time, resp, msg; 
		q.osc_addresses_57120[msg[1]].sendMsg("/vol_base", q.player_num, base[q.player_num]);
		q.osc_addresses_57121[msg[1]].sendMsg("/vol_base", q.player_num, base[q.player_num]);
	}).add;	
	
			
	//now we define actions for the slider
	q.range_slider.action_({
		loudness_range=((q.range_slider.value*70)+30).dbamp;
		q.num.do({arg i;
			max_volume[i]=base[i]+loudness_range;
		});
					
	});
	
	//In a co-ordinate system where z points "in/out", y points "up/down", x points "left/right"
	//We are interested in x and z values.
	//The message format is as follows:
	//[ /client (0), body_part(1), player_id (2), X(3), Z(4), Y(5), pitch(6), yaw(7), roll(8)]
	//Note that we receive the messages for all three players
	q.info_osc = OSCresponderNode(nil, '/client', {arg time, resp, msg;			
		var player_received;

		if (msg[2]==(-1),{
			//this means it is coming from the local computer	
			player_received=q.player_num;
		},{
			player_received=msg[2];
		});		

			
		if(msg[1].asString=="head",{
			filter_head_yaw[player_received, counter%filter_size]=msg[7]*pi/180;
			filter_head_roll[player_received, counter%filter_size]=msg[8]*pi/180;		
		});

		if(msg[1].asString=="torso",{

			if(msg[3]<=q.kinect_min_x[player_received],{
				temp_x=q.kinect_min_x[player_received];
			},{
				if(msg[3]>=q.kinect_max_x[player_received],{
					temp_x=q.kinect_max_x[player_received];
				},{
					temp_x=msg[3];
				});
			});
			
			filter_x_pos[player_received, counter%filter_size]=temp_x;
			
			
			
			if(msg[5]<=q.kinect_min_y[player_received],{
				temp_y=q.kinect_min_y[player_received];
			},{
				if(msg[5]>=q.kinect_max_y[player_received],{
					temp_y=q.kinect_max_y[player_received];
				},{
					temp_y=msg[5];	
				});
			});
	

			filter_y_pos[player_received, counter%filter_size]=temp_y;

			filter_body_yaw[player_received, counter%filter_size]=msg[7]*pi/180;
					
			head_roll[player_received]=((filter_head_roll.rowAt(player_received).sum)/filter_size);
			head_yaw[player_received]=((filter_head_yaw.rowAt(player_received).sum)/filter_size);
			body_yaw[player_received]=((filter_body_yaw.rowAt(player_received).sum)/filter_size);
	
			//rms_angle=((-1)*(head_yaw[player_received]-body_yaw[player_received]));
			rms_angle=(-1)*(head_yaw[player_received]);
			esp_angle=(-1)*(head_roll[player_received]);

			player_positions[player_received,0]=((filter_x_pos.rowAt(player_received).sum)/filter_size);
			player_positions[player_received,1]=((filter_y_pos.rowAt(player_received).sum)/filter_size);

			counter=counter+1;
			
			player_positions_adjusted_kinect_location[player_received,0]=player_positions[player_received,0];
			player_positions_adjusted_kinect_location[player_received,1]=(q.kinect_min_y[player_received]+q.kinect_max_y[player_received])-player_positions[player_received,1];

			
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
				//now we resend this message to both remote participants if we've received our own info			
				q.num.do({arg i;
					if(i!=q.player_num,{
						q.osc_addresses_57120[i].sendMsg("/client",q.player_num+1,msg[2],msg[3],msg[4],msg[5],msg[6],msg[7]);
						q.osc_addresses_57121[i].sendMsg("/client",q.player_num+1,msg[2],msg[3],msg[4],msg[5],msg[6],msg[7]);			
					});
				});


				//now we need to calculate the distances to each monitor
				if(q.dvm,{					
					q.num.do({arg i;
						q.num.do({arg j;
							if(i!=j,{
								distance_to_monitors[i,j]=(player_positions_rotated.rowAt(i)-monitor_position[i,j]).squared.sum.sqrt;
							});
						});
					});

					q.num.do({arg i;
						if(i!=q.player_num,{
							distance[i]=distance_to_monitors[i,q.player_num]+distance_to_monitors[q.player_num,i];	
							volume[i]=distance[i].linlin(q.min_dist,q.max_dist,max_volume[i].ampdb,base[i].ampdb, \minmax).dbamp;
						});
					});					
				
				});
			

				if(q.rms,{
					right_to_left[0]=(-1)*cos(rms_angle);
					right_to_left[1]=sin(rms_angle);
					q.num.do({arg i;
						var unit_vector=[0,0];
						var dot_product;
						if(i==q.player_num,{
							volume_right[i]=volume[i];
							volume_left[i]=volume[i];
						},{
							unit_vector[0]=(player_positions_viewer[q.player_num,0]-player_positions_viewer[i,0])/(player_positions_viewer.rowAt(q.player_num)-player_positions_viewer.rowAt(i)).squared.sum.sqrt;
							unit_vector[1]=(player_positions_viewer[q.player_num,1]-player_positions_viewer[i,1])/(player_positions_viewer.rowAt(q.player_num)-player_positions_viewer.rowAt(i)).squared.sum.sqrt;
							dot_product = (unit_vector[0]*right_to_left[0])+(unit_vector[1]*right_to_left[1]);
							volume_right[i]=(volume[i]/2)*((1+dot_product).pow(2));
							volume_left[i]=(volume[i]/2)*((1-dot_product).pow(2));
						});
					});

				},{
					q.num.do({arg i;
						volume_right[i]=volume[i];
						volume_left[i]=volume[i];
					});
				});
			
				if(q.esp,{
					if(esp_angle.abs>esp_angle_thresh,{
						q.esp_active=true;
						if(esp_angle<0,{
							esp_adjusted_angle=(-1)*(esp_angle+esp_angle_thresh);
						},{
							esp_adjusted_angle=(-1)*(esp_angle-esp_angle_thresh);
						});
							
					},{
						q.esp_active=false;
						esp_adjusted_angle=0;
					});

					if(q.esp_active,{
						q.num.do({arg i;
							var temp;
							if(i!=q.player_num,{
								temp = player_positions_viewer[i,0]-player_positions_viewer[q.player_num,0];
								if(i==1,{
									temp.postln;
								});
								if(esp_adjusted_angle>0,{
								//head is tilted to the right	
									if(temp<0,{
										//that musician is on the left. Tune down their volume in both ears.
										volume_left[i] = esp_adjusted_angle.linlin(0,pi/4,volume_left[i],0);
										volume_right[i] = esp_adjusted_angle.linlin(0,pi/4,volume_right[i],0);
									},{
										//that musician is to the right. Turn up the volume on the right side.
										volume_left[i] = esp_adjusted_angle.linlin(0,pi/4,volume_left[i],0);
										volume_right[i] = esp_adjusted_angle.linlin(0,pi/4,volume_right[i],(2*volume_right[i]));
									});
								},{
								//head is tilted to the left
									if(temp<0,{
										//that musician is to the left. Turn up the volume on the left side
										"turning up left player's volume".postln;
										volume_left[i] = esp_adjusted_angle.linlin(-pi/4,0,2*volume_left[i],volume_left[i]);
										volume_right[i] = esp_adjusted_angle.linlin(-pi/4,0,0,volume_right[i]);
									},{
										//that musician is to the right. Turn down their volume in both ears.
										volume_left[i] = esp_adjusted_angle.linlin(-pi/4,0,0,volume_left[i]);
										volume_right[i] = esp_adjusted_angle.linlin(-pi/4,0,0,volume_right[i]);
									});
								});
							});
						});
	
					},{
						pan_pos=0;
					});
				},{
					pan_pos=0;		
				});

				[volume_left[1], volume_right[1]].postln;
				q.player_out_right.set(\amp, volume_right);
				q.player_out_left.set(\amp, volume_left);			
			
			});

			q.updateGUI(player_positions_viewer, volume, base, max_volume, loudness_range,head_roll, body_yaw);

		});
								
	}).add;
				
};


q.updateGUI = { |q, player_positions_viewer, volume, base, max_volume, loudness_range, head_roll, body_yaw|


	var color_array;
	var vertex_0 = Array2D.new(q.num,2);
	var vertex_1 = Array2D.new(q.num,2);
	var vertex_2 = Array2D.new(q.num,2);
	var vertex_3 = Array2D.new(q.num,2);
	var lshoulder_centre = Array2D.new(q.num,2);
	var rshoulder_centre = Array2D.new(q.num,2);
	var arc_num=Array.newClear(q.num);
	var arc_max=10;
	var pos_slider, vol_slider;
	var angles = Array.newClear(q.num);
	var head_position =Array2D.new(q.num,2);
	var body_yaw_reflected=Array.newClear(q.num);
	var body_yaw_adjusted=Array.newClear(q.num);
	var body_yaw_rotated=Array.newClear(q.num);
	var head_roll_adjusted=Array.newClear(q.num);
	var head_offset, label_offset_x, label_offset_y;
	var label_positions=Array2D.new(q.num,2);	
	
	
	//this is how much we need to move the labels by to make them appear in the viewer
	label_offset_x=q.x_available-q.viewer_total_width-25-(q.head_radius/2);
	label_offset_y=q.head_radius/2;	

	color_array= [[0.8,0,0],[0,0.8,0],[0,0,0.8]];

	q.num.do({arg i;
		body_yaw_reflected[i]=0;
		body_yaw_rotated[i]=0;
	});


	q.num.do({arg i;
		

		body_yaw_adjusted[i]=body_yaw[i];
		head_roll_adjusted[i]=head_roll[i]*(-1);

		
		head_offset=head_roll_adjusted[i].linlin(-pi/4,pi/4, (-1)*q.shoulder_length, q.shoulder_length, \minmax).floor;


		if(q.esp,{	
			head_position[i,0]=player_positions_viewer[i,0]+head_offset;
		},{
			head_position[i,0]=player_positions_viewer[i,0];
		});

		head_position[i,1]=player_positions_viewer[i,1];	
		
		if(q.dvm,{
			if(i==q.player_num,{
				arc_num[i] = 0;
			},{
				arc_num[i] = volume[i].ampdb.linlin(base[i].ampdb,max_volume[i].ampdb, 1, arc_max, \minmax).floor;
			});
		},{
			arc_num[i] = 0;
		});
		

		vertex_0[i,0]=player_positions_viewer[i,0]-q.shoulder_length;
		vertex_0[i,1]=player_positions_viewer[i,1]-q.shoulder_width;

		vertex_1[i,0]=player_positions_viewer[i,0]+q.shoulder_length;
		vertex_1[i,1]=player_positions_viewer[i,1]-q.shoulder_width;

		vertex_2[i,0]=player_positions_viewer[i,0]-q.shoulder_length;
		vertex_2[i,1]=player_positions_viewer[i,1]+q.shoulder_width;	

		vertex_3[i,0]=player_positions_viewer[i,0]+q.shoulder_length;	
		vertex_3[i,1]=player_positions_viewer[i,1]+q.shoulder_width;

		lshoulder_centre[i,0]=player_positions_viewer[i,0]-q.shoulder_length;
		lshoulder_centre[i,1]=player_positions_viewer[i,1];

		rshoulder_centre[i,0]=player_positions_viewer[i,0]+q.shoulder_length;
		rshoulder_centre[i,1]=player_positions_viewer[i,1];

		if(i==q.player_num,{
			body_yaw_reflected[i]=(body_yaw_adjusted[i]+pi);
		});

		q.num.do({arg i;
			body_yaw_rotated[i]=body_yaw_reflected[i]+q.body_yaw_rot_angles[i];
		});


		c.drawFunc = { 	
			//Pen.translate(shoulder_width,shoulder_width);
			Pen.width=5;		
			q.num.do({arg i;
				Pen.rotate(body_yaw_rotated[i], player_positions_viewer[i,0], player_positions_viewer[i,1]);
			

				
				Pen.line(vertex_2[i,0]@vertex_2[i,1], vertex_3[i,0]@vertex_3[i,1]);
				Pen.addArc(lshoulder_centre[i,0]@lshoulder_centre[i,1], q.shoulder_width, 0.5*pi , pi);
				Pen.addArc(rshoulder_centre[i,0]@rshoulder_centre[i,1], q.shoulder_width, 1.5*pi, pi);
				Pen.fillColor=Color.fromArray(color_array[i]);
				Pen.fill;


				Pen.addArc(head_position[i,0]@head_position[i,1], q.head_radius, 0.0, 2pi);
				Pen.fillColor=Color.new255(255,228,196);
				Pen.fill;

				Pen.width=3;
				Pen.color=Color.black;

				arc_num[i].do({arg j;
					Pen.addArc(head_position[i,0]@head_position[i,1], q.head_radius+(10*(j+1)),pi/3, pi/3 );
					Pen.perform(\stroke);
				});
				
				Pen.rotate((-1)*body_yaw_rotated[i], player_positions_viewer[i,0], player_positions_viewer[i,1]);	
				
					
			});

		};
		label_positions[i,0]=player_positions_viewer[i,0]+(head_offset*cos(body_yaw_rotated[i]))+label_offset_x;
		label_positions[i,1]=player_positions_viewer[i,1]+(head_offset*sin(body_yaw_rotated[i]))+label_offset_y;
		q.player_labels[i].bounds=Rect(label_positions[i,0], label_positions[i,1],q.head_radius,q.head_radius);	
					
			
	});

};



q.stopjam = { |q|

	q.volume_slider.enabled = false;

	q.calibrate_button.enabled=true;
	q.calibrate_label.stringColor=Color.black;	
	
	q.range_slider.value=0;
	q.range_slider.enabled = false;

	q.started = false;


	q.player_out_right.free;
	q.player_out_left.free;
	Server.all.do(_.freeAll);
	
	"jmess -D".unixCmd;
	"killall osceleton_for_NMP".unixCmd;

	//now we remove all osc nodes
	q.info_osc.remove;
	q.volume_osc.remove;

};

q.createGUI_start;
);
}.play;


