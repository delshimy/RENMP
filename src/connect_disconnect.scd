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
					if(connection_received==[1,1,0],{
						q.connect_label.string="All musicians are now connected.";
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

