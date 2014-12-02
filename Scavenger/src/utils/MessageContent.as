package utils 
{
	import feathers.data.VectorIntListCollectionDataDescriptor;
	public class MessageContent 
	{
		
		private static var messages:Object;
		public function MessageContent() 
		{
			throw("CAN'T INSTANCIATE THIS CLASS");
		}
		
		public static function getMessage(name:String):String
		{
			if ( MessageContent.messages == null ) MessageContent.initialize();
			return MessageContent.messages[name];
		}
		
		private static function initialize():void
		{
			MessageContent.messages = new Object();
			MessageContent.messages["welcome"] = "Welcome. You've been sent here to gather some strange artifacts that have been detected in this region of the universe. This is the only ship we had for you, so you'll have to get use to this antiquity. As this is an old model, maybe you don't remember how to use this. You should have some Arrows in the bottom corner of the control panel. Use the left and right to rotate your ship and the two others to propel it forward or backward. You'll get use to it. You should be searching for something to tow the junk you'll find in space. There should be one around the coordinates (16,10). Good luck pilot. Over & out.";
			MessageContent.messages["see_door_not_hook"] = "Pilot. Do you see this thing? It kind of look like a door. I think it is linked to something our radars located. It looks like a shipwreck with something being able to destroy those doors. The only one we located is around the coordinates (9,5). By the way, you should go around the (16,10) to get something to tow the shipwreck back to the station. Over & out.";
			MessageContent.messages["see_door_hook_unlock"] = "Pilot. Do you see this thing? It kind of look like a door. I think it is linked to something our radars located. It looks like a shipwreck with something being able to destroy those doors. The only one we located is around the coordinates (9,5). Over & out.";
			MessageContent.messages["unlock_door_red"] = "Pilot. We have successfully desactivated the red doors. You should be able to explore more of this sector. Over & out.";
			MessageContent.messages["unlock_door_blue"] = "Pilot. We have successfully desactivated the blue doors. We also retrieved some old music from this shipwreck, but I don't think you can use it in any way. You can continue your mission. Over & out.";
			MessageContent.messages["unlock_door_yellow"] = "Pilot. Yellow doors destroyed! It is starting to feel like a cheap way to make your mission longer. Sorry for the inconvinience. Over & out.";
			MessageContent.messages["unlock_door_cyan"] = "Pilot. Cyan doors destroyed. We think it was the last ones. Well, we just didn't located any other shipwreck in the area. I don't think I'll be communicating with you anymore, unless you find something interesting. Keep up the good work. Over & out.";
			MessageContent.messages["booster_1"] = "Pilot. You found an old Nitrogen Accelerator Module. This is perfect! The N.A.M. is activated by the switch on the control panel with the 'CTRL' on it. It used to stand for something, but I don't have any information on that. All you have to do is keep this switch  on and you should be able to go much faster. Although it is a nice finding, don't forget that your mission is to bring back the artifacts. Not collect junk. Over & out.";
			MessageContent.messages["booster_2"] = "Pilot. You found another N.A.M. I see. You know that no one is gonna try to race you out there, you're alone. Go onward with the mission. Please. Over & out.";
			MessageContent.messages["damage_ship"] = "Pilot. I'm reading that you damaged your ship quick a good amount. First of, can you try not to do it? Second, don't forget that we have a repair module back at the base at the coordinates (12,1). The nano-bots can take care of your ship if you feel like there's anything wrong. We can't afford to lose you because you just didn't repair your ship. Over & out.";
			MessageContent.messages["shipwreck_after_door"] = "Pilot. I see you've got your hand on a shipwreck. Bring it back to the station and put it in the repair area. We should be able to recycle it and desactivate those doors I talked to you about. Don't ask how we can do it, we just can. Over & out.";
			MessageContent.messages["shipwreck_before_door"] = "Pilot. I see you've got your hand on a shipwreck. Bring it back to the station and put it in the repair area. We should be able to recycle it. I don't think you saw it yet, but some part of this universe are blocked by some sort of doors. I think that with that shipwreck we can desactivate those doors. At least the red ones. Don't ask how we can do it, we just can. Over & out.";
			MessageContent.messages["treasure_hooked"] = "Pilot. You finally found one of the artifact. Good job! Bring it back to the station and put it in the repair area. We will transport it in a container. Scavenge the other ones as fast as possible. There should be around 7 other artifacts in this sector. Over & out.";
			MessageContent.messages["unlock_hook"] = "Pilot. I just saw that you got your hands on an old towing hook. Well done. You can connect it to the missile launcher panel, I don't think you'll see any missile that can be loaded in  this old ship. Once this is done, you'll be able to press the big 'X' button on the control panel. Now go get the artifacts. The only one we precisely located was around the coordinates (15,4). Over & out.";
			MessageContent.messages["map"] = "Pilot. I forgot to tell you, I don't know if you already saw it, but there's a button on your control panel labeled 'M'. If you press it, it can display a map of the sector of the universe you're in. It might be helpful to avoid  getting lost. Over & out.";
			MessageContent.messages["end"] = "Pilot. Everyone here is congratuling you. You did a really good job gathering all those artifacts. We will try to suck the power out of them and then teleport you back to our mothership. Nothing to worry about. Nothing's going to happen. But stay on guard. You know... just in case. Over & out.";
		}
		
	}

}