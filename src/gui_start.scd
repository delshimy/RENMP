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
	var dv_box, dr_box, tp_box, mc_box, ms_box;
	var musician_label, features_question, dv_label, dr_label, tp_label, mc_label, ms_label;

	q.x_ratio = 1; 
	q.y_ratio = 1;
	q.x_total = 1600;//Window.availableBounds.right;
	q.y_total = 900;//Window.availableBounds.bottom;
	q.dv=false;
	q.cond_dv = "dv_off";
	q.dr=false;
	q.cond_dr = "dr_off";
	q.tp=false;
	q.cond_tp = "tp_off";
	q.mc=false;
	q.cond_mc = "mc_off";
	q.ms=false;
	q.cond_ms = "ms_off";
	q.save=false; //for now we turn saving off
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
	dv_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	dv_box.value = false;
	dv_box.action = {
		if (dv_box.value,{
			q.dv = true;
			q.cond_dv = "dv_on";
		},{
			q.dv = false;
			q.cond_dv = "dv_off"
		});	
	};
		
	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (475*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	dv_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	dv_label.string = "Dynamic Volume"; 	
	dv_label.font = Font("Calibri",font_size);
	dv_label.stringColor=Color.gray(0.4);

	x_pos = ((q.x_available-(400*q.x_ratio))/2).asInteger;
	y_pos = (525*q.y_ratio).asInteger;
	x_size = (30*q.y_ratio).asInteger;
	y_size = (30*q.x_ratio).asInteger;	
	dr_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	dr_box.value = false;
	dr_box.action = {
		if (dr_box.value,{
			q.dr = true;
			q.cond_dr = "dr_on";
		},{
			q.dr = false;
			q.cond_dr = "dr_off";
		});	
	};

	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (525*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	dr_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	dr_label.string = "Dynamic Reverb"; 	
	dr_label.font = Font("Calibri",font_size);
	dr_label.stringColor=Color.gray(0.4);




	x_pos = ((q.x_available-(400*q.x_ratio))/2).asInteger;
	y_pos = (575*q.y_ratio).asInteger;
	x_size = (30*q.y_ratio).asInteger;
	y_size = (30*q.x_ratio).asInteger;	
	tp_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	tp_box.value = false;
	tp_box.action = {
		if (tp_box.value,{
			q.tp = true;
			q.cond_tp = "tp_on";
			q.ms=false;
			q.cond_ms= "ms_off";
			ms_box.value=false;
			
		},{
			q.tp = false;
			q.cond_tp = "tp_off";
		});	
	};

	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (575*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	tp_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	tp_label.string = "Track Panning"; 	
	tp_label.font = Font("Calibri",font_size);
	tp_label.stringColor=Color.gray(0.4);


	x_pos = ((q.x_available-(400*q.x_ratio))/2).asInteger;
	y_pos = (625*q.y_ratio).asInteger;
	x_size = (30*q.y_ratio).asInteger;
	y_size = (30*q.x_ratio).asInteger;	
	mc_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	mc_box.value = false;
	mc_box.action = {
		if (mc_box.value,{
			q.mc = true;
			q.cond_mc = "mc_on";
		},{
			q.mc = false;
			q.cond_ms = "mc_off";
		});	
	};

	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (625*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	mc_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	mc_label.string = "Mix Control"; 	
	mc_label.font = Font("Calibri",font_size);
	mc_label.stringColor=Color.gray(0.4);




	x_pos = ((q.x_available-(400*q.x_ratio))/2).asInteger;
	y_pos = (675*q.y_ratio).asInteger;
	x_size = (30*q.y_ratio).asInteger;
	y_size = (30*q.x_ratio).asInteger;	
	ms_box = CheckBox(s, Rect(x_pos,y_pos,x_size,y_size));
	ms_box.value = false;
	ms_box.action = {
		if (ms_box.value,{
			q.ms = true;
			q.cond_ms = "ms_on";
			q.tp=false;
			q.cond_tp= "tp_off";
			tp_box.value=false;
				
		},{
			q.ms = false;
			q.cond_ms = "ms_off";
		});	
	};

	x_pos =  ((q.x_available-(400*q.x_ratio))/2+30).asInteger;
	y_pos = (675*q.y_ratio).asInteger;
	x_size = ((400-25)*q.y_ratio).asInteger;	
	y_size = (30*q.x_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	ms_label = StaticText(s, Rect(x_pos,y_pos,x_size,y_size));
	ms_label.string = "Musician Spatialization"; 	
	ms_label.font = Font("Calibri",font_size);
	ms_label.stringColor=Color.gray(0.4);


	

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

