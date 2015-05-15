//
//  Midi.m
//  SendMidiCmd
//
//  Created by Belotte on 28/01/2015.
//  Copyright (c) 2015 Justin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Midi.h"

@implementation Midi

- (id) init {
	MIDIClientCreate(CFSTR("Client"), NULL, NULL, &client);
	MIDIInputPortCreate(client, CFSTR("iPort"), MIDIInput, (__bridge void *)(self), &iPort);
	MIDIOutputPortCreate(client, CFSTR("oPort"), &oPort);
	
	myDeviceName = @"Line 6 Pocket POD";
	myDevice = 0;
	
	int nbOfDevices = (int)MIDIGetNumberOfDevices();
	
	for (int i = 0; i < nbOfDevices; i++) {
		MIDIDeviceRef device = MIDIGetDevice(i);
		
		if (device) {
			CFStringRef name;
			
			if (MIDIObjectGetStringProperty(device, kMIDIPropertyName, &name) == noErr) {
				NSString *deviceName = (__bridge NSString *)name;
				
				if ([myDeviceName isEqualToString:deviceName]) {
					myDevice = device;
					
					CFRelease(name);
					
					break;
				}
			}
			
			CFRelease(name);
		}
	}
	
	MIDIEndpointRef entity = MIDIDeviceGetEntity(myDevice, 0);
	MIDIEndpointRef source = MIDIEntityGetSource(entity, 0);
	
	MIDIPortConnectSource(iPort, source, NULL);
	
	Byte data[3] = {0xCC, 1, 122}; //modifier uniquement la dernière valeur
	
	char buffer[1024];
	MIDIPacketList *packets = (MIDIPacketList *)buffer;
	
	MIDIPacket *packet = MIDIPacketListInit(packets);
	MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
	
	return self;
}

- (bool) send {
	[self send:-1];
	
	return true;
}

- (bool) send: (int) value {
	MIDIEndpointRef entity = MIDIDeviceGetEntity(myDevice, 0);
	
	if (value == -1)
		value = currentValue;
	
	Byte data[3] = {0xCC, 1, value};
	
	char buffer[1024];
	MIDIPacketList *packets = (MIDIPacketList *)buffer;
	
	MIDIPacket *packet = MIDIPacketListInit(packets);
	MIDIPacketListAdd(packets, 1024, packet, 0, 3, data);
	
	MIDIEndpointRef destination = MIDIEntityGetDestination(entity, 0);
	MIDISend(oPort, destination, packets);
	
	return true;
}

- (int) getCurrentValue {
	return currentValue;
}

- (void) addToCurrentValue: (int) value {
	currentValue += value;
	[self control];
}

- (void) up {
	currentValue += 1;
	[self control];
}

- (void) down {
	currentValue -= 1;
	[self control];
}

- (void) control {
	if (currentValue > 123)
		currentValue -= 123;
	else if (currentValue < 1)
		currentValue += 123;
}

@end

void MIDIInput (const MIDIPacketList *packets, void *source, void *connectSource) {
	int a, b, c;
	
	a = (int)packets->packet[0].data[0];
	b = (int)packets->packet[0].data[1];
	c = (int)packets->packet[0].data[2];
	
	NSLog(@"%i, %i, %i", a, b, c);
};