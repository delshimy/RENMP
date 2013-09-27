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

SynthDef(\player_mix,{ |amp_instrument=#[0,0,0], amp_vocals =#[0,0,0], channel_out, revtime_instrument=#[0,0,0], revtime_vocals=#[0,0,0], damp_instrument=#[0,0,0], damp_vocals=#[0,0,0]|	 
			var source_instruments=Array.newClear(q.num);
			var source_vocals=Array.newClear(q.num);
			var source_instruments_plus_reverb = Array.newClear(q.num);
			var source_vocals_plus_reverb = Array.newClear(q.num);
			var reverb_instruments = Array.newClear(q.num);
			var reverb_vocals = Array.newClear(q.num);
			var source_mix;	
			var in_channels=Array.newClear(q.num*2);
			//var in_channels=Array.newClear(q.num);
			//format of GVerb is:
			//GVerb.ar(source, roomsize, revtime, damping,inputbw, spread, drylevel.dbamp,earlylevel.dbamp, taillevel.dbamp, roomsize, 0.3)							
			(q.num).do({arg i;
				in_channels[i]=i;
				in_channels[i+q.num]=i+q.num;
				source_instruments[i]=Limiter.ar(SoundIn.ar(in_channels[i], amp_instrument[i]),amp_instrument[i], 0.001);
				source_vocals[i]=Limiter.ar(SoundIn.ar(in_channels[i+q.num], amp_vocals[i]),amp_vocals[i], 0.001);
				//source_instruments[i]=SoundIn.ar(in_channels[i],amp_instrument[i]);
				//source_vocals[i]=SoundIn.ar(in_channels[i+q.num],amp_vocals[i]);
				

				//settings for church are [\roomsize, 80, \revtime, 4.85, \damping, 0.41, \inputbw, 0.19, \drylevel -3, \earlylevel, -9, \taillevel, -11]
				//setting for living room are [\roomsize, 16, \revtime, 1.24, \damping, 0.10, \inputbw, 0.95, \drylevel -3, \earlylevel, -15, \taillevel, -17]
				reverb_instruments[i]=GVerb.ar(source_instruments[i], 16, revtime_instrument[i], damp_instrument[i],0.95,15,(-3).dbamp, (-15).dbamp,(-17).dbamp, 16, 0.3);
				//reverb_instruments[i]= GVerb.ar(source_instruments[i], 80, reverb_time[i], 0.41, 0.19, 15, (-3).dbamp, (-9).dbamp, (-11).dbamp, 80, 0.3); 
				reverb_vocals[i]= GVerb.ar(source_vocals[i], 16, revtime_vocals[i], damp_vocals[i],0.95,15,(-3).dbamp, (-15).dbamp,(-17).dbamp, 16, 0.3); 
				source_instruments_plus_reverb[i]=source_instruments[i]+reverb_instruments[i];
				source_vocals_plus_reverb[i]=source_vocals[i]+reverb_vocals[i];
			});		
			source_mix=((source_vocals_plus_reverb.sum)+(source_instruments_plus_reverb.sum))/(q.num*2);
			//source_mix=(source_instruments_plus_reverb.sum)/(q.num);
			//source_mix=(source_instruments.sum)/(q.num);
			Out.ar(channel_out,source_mix);
}).add;



