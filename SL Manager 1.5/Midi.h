//
//  Midi.h
//  SendMidiCmd
//
//  Created by Belotte on 28/01/2015.
//  Copyright (c) 2015 Justin. All rights reserved.
//

#ifndef SendMidiCmd_Midi_h
#define SendMidiCmd_Midi_h

#import <CoreMIDI/CoreMIDI.h>

@interface Midi : NSObject {
	MIDIClientRef client;
	MIDIPortRef iPort, oPort;
	NSString *myDeviceName;
	MIDIDeviceRef myDevice;
	
	int currentValue;
}

- (id) init;

/*! Send the current value
 */
- (bool) send;

/*! Send the parameter
 @param value Value to send
 */
- (bool) send: (int) value;

/*! Return the current value
 \return currentValue
 */
- (int) getCurrentValue;

/*! Increment current value with 'value'
 @param value Value to add to currentValue
 */
- (void) addToCurrentValue: (int) value;

/*! Increment current value from 1
 */
- (void) up;

/*! Decrement currenv value from 1
 */
- (void) down;

/*! Adapt value to be between 1 and 123
 */
- (void) control;

@end

void MIDIInput (const MIDIPacketList *packets, void *source, void *connectSource);

#endif