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


q.createGUI_feature_control = { |q|

	var features_question, dv_box, dv_label, dr_box, dr_label, tp_box, tp_label, mc_box, mc_label, ms_box, ms_label;

	b = Window("Feature Control", Rect(0, 0, 400, 400));
	


	features_question=StaticText(b, Rect(0,25,400,100));
	features_question.align=\center;
	features_question.font=Font("Calibri",25);
	features_question.string = ("Select performance features:");
	//features_question.stringColor=Color.gray(0.4);

	
	dv_box = CheckBox(b, Rect(50,125,30,30));
	dv_box.action = {arg value;
		if (dv_box.value,{
			q.dv = true;
			q.cond_dv = "dv_on";
			q.volume_range_slider.enabled = true;
			//q.volume_range_slider.value=q.volume_range;
		},{
			q.dv = false;
			q.cond_dv = "dv_off";
			q.volume_range_slider.enabled = false;
		});	

		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("feature_change",q.current_time.asString, q.cond_dv.asString,"\n"));
		});
	};

	if(q.dv != nil, {
		dv_box.value = q.dv;
	},{
		dv_box.value = false;
	});
		
	dv_label = StaticText(b, Rect(80,125,295,30));
	dv_label.string = "Dynamic Volume"; 	
	dv_label.font = Font("Calibri",20);
	dv_label.stringColor=Color.gray(0.4);
	

	dr_label = StaticText(b, Rect(80,175,295,30));
	dr_label.string = "Dynamic Reverb"; 	
	dr_label.font = Font("Calibri",20);
	dr_label.stringColor=Color.gray(0.4);

	dr_box = CheckBox(b, Rect(50,175,30,30));
	dr_box.action = {
		if (dr_box.value,{
			q.dr = true;
			q.cond_dr = "dr_on";
			q.reverb_range_slider.enabled = true;
			//q.volume_range_slider.value=q.volume_range;
		},{
			q.dr = false;
			q.cond_dr = "dr_off";
			q.reverb_range_slider.enabled = false;
		});	

		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("feature_change",q.current_time.asString, q.cond_dr.asString,"\n"));
		});
	};

	if(q.dr != nil, {
		dr_box.value = q.dr;
	},{
		dr_box.value = false;
	});

	tp_box = CheckBox(b, Rect(50,225,30,30));
	tp_box.action = {
		if (tp_box.value,{
			q.tp = true;
			q.cond_ti = "tp_on";
			q.ms=false;
			q.cond_ms= "ms_off";
			ms_box.value=false;
		},{
			q.tp = false;
			q.cond_ti = "tp_off";
		});

		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("feature_change",q.current_time.asString, q.cond_ti.asString,"\n"));
		});	
	};

	if(q.tp != nil, {
		tp_box.value = q.tp;
	},{
		tp_box.value = false;
	});


	tp_label = StaticText(b, Rect(80,225,295,30));
	tp_label.string = "Track Panning"; 	
	tp_label.font = Font("Calibri",20);
	tp_label.stringColor=Color.gray(0.4);


	mc_box = CheckBox(b, Rect(50,275,30,30));
	mc_box.action = {
		if (mc_box.value,{
			q.mc = true;
			q.cond_mc = "mc_on";
		},{
			q.mc = false;
			q.cond_mc = "mc_off";
		});	

		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("feature_change",q.current_time.asString, q.cond_mc.asString,"\n"));
		});
	};

	if(q.mc != nil, {
		mc_box.value = q.mc;
	},{
		mc_box.value = false;
	});	


	mc_label = StaticText(b, Rect(80,275,325,30));
	mc_label.string = "Mix Control"; 	
	mc_label.font = Font("Calibri",20);
	mc_label.stringColor=Color.gray(0.4);
	




	ms_box = CheckBox(b, Rect(50,325,30,30));
	ms_box.action = {
		if (ms_box.value,{
			q.ms = true;
			q.cond_ms = "ms_on";
			q.tp=false;
			q.cond_ti= "tp_off";
			tp_box.value=false;
	
	
		},{
			q.ms = false;
			q.cond_ms = "ms_off";
		});	

		if(q.save,{
			q.current_time=thisThread.clock.beats*1000-q.start_time;		
			q.file_settings.putString(scatArgs("feature_change",q.current_time.asString, q.cond_ms.asString,"\n"));
		});
	};

	if(q.ms != nil, {
		ms_box.value = q.ms;
	},{
		ms_box.value = false;
	});	


	ms_label = StaticText(b, Rect(80,325,325,30));
	ms_label.string = "Musician Spatialization"; 	
	ms_label.font = Font("Calibri",20);
	ms_label.stringColor=Color.gray(0.4);
		

		

	b.front;

};
