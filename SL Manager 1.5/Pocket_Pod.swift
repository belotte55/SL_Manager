//
//  Pocket_Pod.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa
import CoreMIDI

class Pocket_Pod {
	var client: MIDIClientRef = MIDIClientRef()
	
	var iPort: MIDIPortRef = MIDIPortRef()
	var oPort: MIDIPortRef = MIDIPortRef()
	
	var device_name: String = "Line 6 Pocket POD"
	var device_reference: MIDIDeviceRef?
	
	var entity: MIDIEntityRef?
	var source: MIDIEndpointRef?
	
	var current_value: Int = 1
	
	let number_of_devices: Int = Int(MIDIGetNumberOfDevices())
	
	init(name: String) {
		self.change_name(name)
	}
	
	func change_name(name: String) {
		self.device_name = name
		
		MIDIClientCreate("client", nil, nil, &client)
		
		MIDIInputPortCreate(client, "iPort", MIDIReadProc(COpaquePointer([MIDIInput])), nil, &iPort)
		MIDIOutputPortCreate(client, "oPort", &oPort)
		
		for i in 0..<number_of_devices {
			let device = MIDIGetDevice(i)
			
			var name: Unmanaged<CFString>?
			
			if MIDIObjectGetStringProperty(device, kMIDIPropertyName, &name) == noErr {
				let device_name: String = name!.takeRetainedValue() as String
				
				if self.device_name == device_name {
					self.device_reference = device
					break
				}
			}
		}
		
		if self.device_reference == nil {
			log("\(name) not found.")
		} else {
			self.entity = MIDIDeviceGetEntity(self.device_reference!, 0)
			self.source = MIDIEntityGetSource(self.entity!, 0)
			
			MIDIPortConnectSource(self.iPort, self.source!, nil)
		}
	}
	
	func send_value(value:Int) {
		if self.device_reference != nil {
			var packet = UnsafeMutablePointer<MIDIPacket>.alloc(1)
			var packet_list = UnsafeMutablePointer<MIDIPacketList>.alloc(1)
			let data_to_send:[UInt8] = [0xCC, 1, UInt8(value)];
			
			packet = MIDIPacketListInit(packet_list);
			packet = MIDIPacketListAdd(packet_list, 1024, packet, 0, 3, data_to_send);
			
			MIDISend(self.oPort, MIDIEntityGetDestination(self.entity!, 0), packet_list)
			
			packet.destroy()
			packet_list.destroy()
			packet_list.dealloc(1)
		} else {
			log("Unable to find device.")
		}
	}
	
	func next() {
		self.current_value++
		self.check()
		self.send_value(self.current_value)
	}
	
	func prev() {
		self.current_value--
		self.check()
		self.send_value(self.current_value)
	}
	
	func go_to(value: Int) {
		self.current_value = value
		self.check()
		self.send_value(self.current_value)
	}
	
	func check() {
		if self.current_value == -1 {
			self.current_value = 123
		} else if self.current_value == 124 {
			self.current_value = 0
		} else if self.current_value < 0 {
			self.current_value = 0
		} else if self.current_value > 123 {
			self.current_value = 123
		}
	}
}

func MIDIInput(packets: UnsafePointer<MIDIPacketList>, source: UnsafePointer<Void>, connectSource: UnsafePointer<Void>) {
	var a: Int
	var b: Int
	var c: Int
	
	a = Int(packets.memory.packet.data.0)
	b = Int(packets.memory.packet.data.1)
	c = Int(packets.memory.packet.data.2)
	
	println("a: \(a), b= \(b), c: \(c)")
}