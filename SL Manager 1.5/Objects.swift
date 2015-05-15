//
//  Objects.swift
//  SL Manager 1.5
//
//  Created by Belotte on 06/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

let colors: [NSColor] = [.yellowColor(), .greenColor(), .whiteColor(), .cyanColor(), .magentaColor()]

let on: Int = 1
let off: Int = 0

let default_origin: NSPoint = NSPoint(x: 0, y: 0)
/* Name of default preferences file */
let bundle_storage_file_name: String = "Preferences.plist"
let dir_name: String = "SL Manager"

struct Boxes {
	var actions_box: Actions_Box
	var pocket_pod_box: Pocket_Pod_Box
	var loops_box: Loops_Box
	
	init(target: AnyObject, action: Selector, action_box_frame: NSRect, pocket_pod_box_frame: NSRect, loops_box_frame: NSRect) {
		self.actions_box = Actions_Box(frame: action_box_frame, target: target, action: action)
		self.pocket_pod_box = Pocket_Pod_Box(frame: pocket_pod_box_frame, target: target, action: action)
		self.loops_box = Loops_Box(frame: loops_box_frame, target: target, action: action)
	}
}

enum Type_Of_Press: String {
	case simple = "Simple_Press"
	case double = "Double_Press"
	case long = "Long_Press"
	
	func get() -> String {
		return self.rawValue.stringByReplacingOccurrencesOfString(" ", withString: "_", options: .LiteralSearch, range: nil)
	}
}

class Circle_of_Color: NSView{
	let circle_path: NSBezierPath
	let color: NSColor
	
	init(radius: Int, color: NSColor, x: Int, y: Int) {
		self.circle_path = NSBezierPath(ovalInRect: NSRect(x: 0, y: 0, width: radius, height: radius))
		self.color = color
		
		super.init(frame: NSRect(x: x, y: y, width: radius, height: radius))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func drawRect(dirtyRect: NSRect)
	{
		self.color.set()
		self.circle_path.fill()
	}
}

class Label: NSTextField {
	init(text: String, frame: NSRect) {
		super.init(frame: frame)
		
		self.stringValue = "\(text)"
		
		self.bezeled = false
		self.drawsBackground = false
		self.editable = false
		self.selectable = false
		
		self.font = NSFont(name: "Lucida Grande", size: 13.0)
		self.alignment = .LeftTextAlignment
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class Input: NSTextField {
	var action_id: Int = -1
	
	init(frame: NSRect, action_id: Int) {
		super.init(frame: frame)
		
		self.action_id = action_id
		self.alignment = .RightTextAlignment
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

func log(text: String) {
	(NSApplication.sharedApplication().delegate as! App_Delegate).log_file?.log(text)
}

func post_notification_named(#name: String) {
	NSNotificationCenter.defaultCenter().postNotificationName(name, object: nil)
}

func observe_for_notification(#receiver: AnyObject, #selector: Selector, #name: String) {
	NSNotificationCenter.defaultCenter().addObserver(receiver, selector: selector, name: name, object: nil)
}

extension Bool {
	mutating func toggle() -> Bool {
		self = !self
		
		return self
	}
}