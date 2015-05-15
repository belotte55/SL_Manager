//
//  Button.swift
//  SL Manager 1.5
//
//  Created by Belotte on 06/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Button: NSButton {
	let action_id: Int
	let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
	
	var color: Circle_of_Color?
	
	var is_check_box: Bool = false
	
	init(title: String, action_id: Int, target: AnyObject, action: Selector, frame: NSRect) {
		self.action_id = action_id
		
		super.init(frame: frame)
		
		self.target = target
		self.action = action
		
		self.title = title
		
		self.bezelStyle = NSBezelStyle.SmallSquareBezelStyle
		self.setButtonType(.OnOffButton)
		
		self.style.alignment = .CenterTextAlignment
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func is_check_box(alignment: NSTextAlignment) {
		self.setButtonType(.SwitchButton)
		self.style.alignment = alignment
		
		self.is_check_box = true
	}
	
	func set_color(color: NSColor) {
		self.remove_color()
		
		if self.is_check_box {
			self.color = Circle_of_Color(radius: 5, color: color, x: 3, y: Int(self.frame.height)-16)
		} else {
			self.color = Circle_of_Color(radius: 5, color: color, x: 5, y: Int(self.frame.height)-10)
		}
		
		self.addSubview(self.color!)
	}
	
	func remove_color() {
		self.color?.removeFromSuperview()
	}
	
	func active() {
		if !self.enabled {
			self.enabled = true
		}
		
		if self.state == 0 {
			self.state = 1
		}
	}
	
	func pause() {
		if self.enabled {
			self.enabled = false
		}
		
		if self.state == 1 {
			self.state = 0
		}
	}
	
	func clear() {
		if !self.enabled {
			self.enabled = true
		}
		
		if self.state == 1 {
			self.state = 0
		}
		
		self.remove_color()
	}
}

class Pop_Up_Button: NSPopUpButton {
	var action_id: Int?
	
	init(action_id: Int, target: AnyObject, action: Selector,frame: NSRect) {
		super.init(frame: frame, pullsDown: false)
		
		self.action_id = action_id
		
		self.action = action
		self.target = target
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func init_items(items: [String]) {
		for item in items {
			self.addItemWithTitle(item)
		}
	}
	
	func get_type_of_press() -> Type_Of_Press {
		switch self.indexOfSelectedItem {
		case 0:
			return .simple
		case 1:
			return .double
		default:
			return .long
		}
	}
}

class Radio_Matrix: NSObject {
	var matrix: [Radio_Button] = []
	var radio_selected: Radio_Button?
	
	let width: Int = 110
	let height: Int = 20
	
	override init() {
		super.init()
	}
	
	func new_radio(title: String) {
		let nb_of_buttons: Int = self.matrix.count
		self.matrix.append(Radio_Button(frame: NSRect(x: 160 + nb_of_buttons%2 * (self.width + 5), y: 25 - Int(nb_of_buttons/2) * (self.height + 5), width: self.width, height: self.height), title: title, target: self, id: nb_of_buttons))
		
		if nb_of_buttons == 0 {
			self.radio_selected = self.matrix.last!
			self.radio_selected!.state = on
		}
	}
	
	func changed(new_radio: Radio_Button) {
		self.radio_selected?.state = off
		self.radio_selected = new_radio
		self.radio_selected!.state = on
	}
}

class Radio_Button: NSButton {
	let id: Int
	
	init(frame: NSRect, title: String, target: Radio_Matrix, id: Int) {
		self.id = id
		
		super.init(frame: frame)
		
		self.target = target
		self.action = "changed:"
		
		self.title = title
		
		self.setButtonType(.RadioButton)
		self.state = off
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}