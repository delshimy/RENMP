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

q.createGUI_main = { |q|
	var pos_window;
	var connect_label;
	var on_off=0;
	var colors;
	var color_array;
	var volume_range_label, volume_min_label, volume_max_label;
	var reverb_range_label, reverb_min_label, reverb_max_label;	
	var left_margin=0;
	var ideal_height; 
	var x_pos,y_pos,x_size,y_size,font_size;
	var instrument_image, vocals_image;
	var box_width;
	var volume_instrument_label, reverb_instrument_label, volume_vocals_label, reverb_vocals_label;

	q.volume_image=Array2D.new(4,4);

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
	y_pos = (175*q.y_ratio).asInteger;
	x_size = (300*q.x_ratio).asInteger;
	y_size = (100*q.y_ratio).asInteger;
	font_size = (25*q.min_effective_ratio).asInteger;
	q.connect_button = GUI.button.new(w, Rect(x_pos, y_pos, x_size, y_size));
	q.connect_button.font=Font("Calibri",font_size, bold:true);
	q.connect_button.states=[[ "Start Performance", Color.black, Color.new255(48,120,0)],[ "Stop Performance", Color.black, Color.new255(162,0,0)]];
	
	x_pos = 0;
	y_pos = (275*q.y_ratio).asInteger;
	x_size = left_margin;
	y_size = (50*q.y_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	q.connect_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	q.connect_label.align=\center;
	q.connect_label.font = Font("Calibri", font_size, bold:true);		
	q.connect_label.string = "You are now disconnected.";


	w.drawFunc = {
		x_pos = (25*q.x_ratio).asInteger;
		y_pos = (325*q.y_ratio).asInteger;
		x_size = ((left_margin-(3*25*q.x_ratio))/2).asInteger;
		y_size = (353*q.y_ratio).asInteger;
		Pen.color = Color.grey(0.8);
		Pen.width = 5;
		Pen.addRect(
			Rect(x_pos, y_pos, x_size, y_size);
		);
		Pen.perform(\stroke);


		x_pos = ((50*q.x_ratio)+x_size).asInteger;
		Pen.addRect(
			Rect(x_pos, y_pos, x_size, y_size);
		);
		Pen.perform(\stroke);
		
	};

	instrument_image = Image.open(catArgs(q.current_directory,"/figures/note.jpg"));
	vocals_image = Image.open(catArgs(q.current_directory,"/figures/mic.jpg"));

	box_width = ((left_margin-(3*25*q.x_ratio))/2).asInteger;
	x_pos = ((25*q.x_ratio)+(box_width/2)-(20/2)).asInteger;
	y_pos = (335*q.y_ratio).asInteger;
	x_size = 20;
	y_size = 36;	
 	q.instrument_icon = UserView(w, Rect(x_pos, y_pos, x_size, y_size));
   	q.instrument_icon.drawFunc = { 
           Pen.image(instrument_image); 
   	}; 


	x_pos = ((50*q.x_ratio)+(1.5*box_width)-(20/2)).asInteger;
	y_pos = (335*q.y_ratio).asInteger;
	x_size = 20;
	y_size = 41;	
 	q.vocals_icon = UserView(w, Rect(x_pos, y_pos, x_size, y_size));
   	q.vocals_icon.drawFunc = { 
           Pen.image(vocals_image); 
   	}; 



	x_pos = ((25*q.x_ratio)+(box_width/3)-((15*q.x_ratio)/2)).asInteger;
	y_pos = (380*q.y_ratio).asInteger;
	x_size = (15*q.x_ratio).asInteger;
	y_size = (225*q.min_effective_ratio).asInteger;
	q.volume_instrument_slider=Slider(w,Rect(x_pos, y_pos, x_size, y_size));
	q.volume_instrument_slider.enabled=false;
		
	x_pos = ((25*q.x_ratio)+(box_width/3)-((30*q.x_ratio)/2)).asInteger;
	y_pos = (605*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (15*q.min_effective_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	volume_instrument_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	volume_instrument_label.align=\center;
	volume_instrument_label.font = Font("Calibri", font_size, bold:true);		
	volume_instrument_label.string = "Vol";


	x_pos = ((25*q.x_ratio)+(2*box_width/3)-((15*q.x_ratio)/2)).asInteger;
	y_pos = (380*q.y_ratio).asInteger;
	x_size = (15*q.x_ratio).asInteger;
	y_size = (225*q.min_effective_ratio).asInteger;
	q.reverb_instrument_slider=Slider(w,Rect(x_pos, y_pos, x_size, y_size));
	q.reverb_instrument_slider.enabled=false;


	x_pos = ((25*q.x_ratio)+(2*box_width/3)-((30*q.x_ratio)/2)).asInteger;
	y_pos = (605*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (15*q.min_effective_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	reverb_instrument_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	reverb_instrument_label.align=\center;
	reverb_instrument_label.font = Font("Calibri", font_size, bold:true);		
	reverb_instrument_label.string = "Rev";
	

	x_pos = ((50*q.x_ratio)+(4*box_width/3)-((15*q.x_ratio)/2)).asInteger;
	y_pos = (380*q.y_ratio).asInteger;
	x_size = (15*q.x_ratio).asInteger;
	y_size = (225*q.min_effective_ratio).asInteger;
	q.volume_vocals_slider=Slider(w,Rect(x_pos, y_pos, x_size, y_size));
	q.volume_vocals_slider.enabled=false;
		
	x_pos = ((50*q.x_ratio)+(4*box_width/3)-((30*q.x_ratio)/2)).asInteger;
	y_pos = (605*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (15*q.min_effective_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	volume_vocals_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	volume_vocals_label.align=\center;
	volume_vocals_label.font = Font("Calibri", font_size, bold:true);		
	volume_vocals_label.string = "Vol";


	x_pos = ((50*q.x_ratio)+(5*box_width/3)-((15*q.x_ratio)/2)).asInteger;
	y_pos = (380*q.y_ratio).asInteger;
	x_size = (15*q.x_ratio).asInteger;
	y_size = (225*q.min_effective_ratio).asInteger;
	q.reverb_vocals_slider=Slider(w,Rect(x_pos, y_pos, x_size, y_size));
	q.reverb_vocals_slider.enabled=false;


	x_pos = ((50*q.x_ratio)+(5*box_width/3)-((30*q.x_ratio)/2)).asInteger;
	y_pos = (605*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (15*q.min_effective_ratio).asInteger;
	font_size = (15*q.min_effective_ratio).asInteger;
	reverb_vocals_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	reverb_vocals_label.align=\center;
	reverb_vocals_label.font = Font("Calibri", font_size, bold:true);		
	reverb_vocals_label.string = "Rev";
	
	


	

	4.do({arg i;
		4.do({arg j;
			q.volume_image[i,j] = Image.open(catArgs(q.current_directory,"/figures/volume_",i,"_reverb_",j,".jpg" ));
		}); 
	});	


	x_pos = ((25*q.x_ratio)+(box_width/2)-(50/2)).asInteger;
	y_pos = (625*q.y_ratio).asInteger;
	x_size = 50;
	y_size = 40;	
 	q.volume_instrument_icon = UserView(w, Rect(x_pos, y_pos, x_size, y_size));
   	q.volume_instrument_icon.drawFunc = { 
           Pen.image(q.volume_image[0,0]); 
   	}; 

	x_pos = ((50*q.x_ratio)+(1.5*box_width)-(50/2)).asInteger;
	y_pos = (625*q.y_ratio).asInteger;
	x_size = 50;
	y_size = 40;	
 	q.volume_vocals_icon = UserView(w, Rect(x_pos, y_pos, x_size, y_size));
   	q.volume_vocals_icon.drawFunc = { 
           Pen.image(q.volume_image[0,0]); 
   	}; 




	x_pos = 0;
	y_pos = (690*q.y_ratio).asInteger;
	x_size = left_margin;
	y_size = (40*q.y_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	volume_range_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	volume_range_label.font = Font("Calibri", font_size);
	volume_range_label.align=\center;
	volume_range_label.string = "Sensitivity of Dynamic Volume";

	 
	x_pos = (45*q.x_ratio).asInteger;
	y_pos = (715*q.y_ratio).asInteger;
	x_size = left_margin-(2*(50*q.x_ratio));
	y_size = (30*q.y_ratio).asInteger;
	q.volume_range_slider = Slider(w, Rect(x_pos, y_pos, x_size, y_size));
	q.volume_range_slider.enabled=false;

	x_pos = (15*q.x_ratio).asInteger;
	y_pos = (715*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (30*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	volume_min_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	volume_min_label.align=\left;
	volume_min_label.font = Font("Calibri", font_size, bold:true);		
	volume_min_label.string = "-";
		
	
	//x_pos = left_margin-(40*q.x_ratio).asInteger-((75-17)*q.x_ratio).asInteger;
	x_pos = left_margin-(45*q.x_ratio).asInteger;
	y_pos = (715*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (30*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	volume_max_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	volume_max_label.align=\right;
	volume_max_label.font = Font("Calibri", font_size, bold:true);		
	volume_max_label.string = "+";	


	x_pos = 0;
	y_pos = (750*q.y_ratio).asInteger;
	x_size = left_margin;
	y_size = (40*q.y_ratio).asInteger;
	font_size = (20*q.min_effective_ratio).asInteger;
	reverb_range_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	reverb_range_label.font = Font("Calibri", font_size);
	reverb_range_label.align=\center;
	reverb_range_label.string = "Sensitivity of Dynamic Reverb";

	 
	x_pos = (45*q.x_ratio).asInteger;
	y_pos = (775*q.y_ratio).asInteger;
	x_size = left_margin-(2*(50*q.x_ratio));
	y_size = (30*q.y_ratio).asInteger;
	q.reverb_range_slider = Slider(w, Rect(x_pos, y_pos, x_size, y_size));
	q.reverb_range_slider.enabled=false;

	x_pos = (15*q.x_ratio).asInteger;
	y_pos = (775*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (30*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	reverb_min_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	reverb_min_label.align=\left;
	reverb_min_label.font = Font("Calibri", font_size, bold:true);		
	reverb_min_label.string = "-";
		
	
	//x_pos = left_margin-(40*q.x_ratio).asInteger-((75-17)*q.x_ratio).asInteger;
	x_pos = left_margin-(45*q.x_ratio).asInteger;
	y_pos = (775*q.y_ratio).asInteger;
	x_size = (30*q.x_ratio).asInteger;
	y_size = (30*q.y_ratio).asInteger;
	font_size = (30*q.min_effective_ratio).asInteger;
	reverb_max_label = StaticText(w, Rect(x_pos, y_pos, x_size, y_size));
	reverb_max_label.align=\right;
	reverb_max_label.font = Font("Calibri", font_size, bold:true);		
	reverb_max_label.string = "+";		

	

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
		if(b!=nil,{
			if((b.isClosed).not,{
				b.close;
			});
		});
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


