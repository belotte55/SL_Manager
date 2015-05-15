//
//  Pedal_Accessories.swift
//  SL Manager 1.5
//
//  Created by Belotte on 10/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Id_Label: NSTextField {
	let origin: NSPoint = NSPoint(x: 10, y: 10)
	let size: NSSize = NSSize(width: 40, height: 40)
	let color: NSColor
	let id: Int
	
	init(id: Int, color: NSColor, use_colors: Bool) {
		self.id = id
		self.color = color
		
		super.init(frame: NSRect(origin: self.origin, size: self.size))
		
		self.stringValue = "\(self.id + 1)"
		
		self.bezeled = false
		self.drawsBackground = false
		self.editable = false
		self.selectable = false
		self.alphaValue = 0.6
		
		if use_colors {
			self.textColor = color
		} else {
			self.textColor = .whiteColor()
		}
		
		self.font = NSFont(name: "Lucida Grande", size: 35.0)
		self.alignment = .CenterTextAlignment
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func use_color() {
		self.textColor = self.color
	}
	
	func remove_color() {
		self.textColor = NSColor.whiteColor()
	}
}

class Pedal_Button: NSButton {
	var id: Int?
	
	let origin: NSPoint = NSPoint(x: 0, y: 0)
	let size: NSSize = NSSize(width: 60, height: 96)
	
	init(target: AnyObject, action: Selector, id: Int) {
		super.init(frame: NSRect(origin: self.origin, size: self.size))
		
		self.alphaValue = 0
		self.bezelStyle = .ThickerSquareBezelStyle
		self.wantsLayer = true
		self.target = target
		self.action = action

		self.id = id
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

class On_Off_Image: NSImageView {
	let origin: NSPoint = NSPoint(x: 7, y: 80)
	let size: NSSize = NSSize(width: 10, height: 10)
	
	let on_image: NSImage = NSImage(named: "on.png")!
	let off_image: NSImage = NSImage(named: "off.png")!
	
	var is_on: Bool = false
	
	init(id: Int) {
		super.init(frame: NSRect(origin: self.origin, size: self.size))
		
		self.image = self.off_image
	}
	
	func toggle() {
		if self.is_on {
			self.image = self.off_image
		} else {
			self.image = self.on_image
		}
		
		self.is_on = !self.is_on
	}
	
	func turn_off() {
		if self.is_on {
			self.image = self.off_image
			self.is_on = false
		}
	}
	
	func turn_on() {
		if !self.is_on {
			self.image = self.on_image
			self.is_on = true
		}
	}
	
	required init(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}