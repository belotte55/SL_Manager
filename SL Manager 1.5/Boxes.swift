//
//  Boxes.swift
//  SL Manager 1.5
//
//  Created by Belotte on 06/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Box: NSBox {
	let target: AnyObject
	let action: Selector
	
	var buttons: [Button] = []
	
	init(frame: NSRect, target: AnyObject, action: Selector) {
		self.target = target
		self.action = action
		
		super.init(frame: frame)
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}

class Actions_Box: Box {
	override init(frame: NSRect, target: AnyObject, action: Selector) {
		super.init(frame: frame, target: target, action: action)
		
		self.title = "Actions"
		self.init_buttons()
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func init_buttons() {
		self.buttons.append(Button(title: "Undo", action_id: 0, target: self.target, action: self.action, frame:
			NSRect(x: 5, y: 70, width: 70, height: 60)))
		self.buttons.append(Button(title: "Redo", action_id: 1, target: self.target, action: self.action, frame:
			NSRect(x: 5, y: 5, width: 70, height: 60)))
		
		self.buttons.append(Button(title: "Record", action_id: 2, target: self.target, action: self.action, frame:
			NSRect(x: 80, y: 92, width: 100, height: 38)))
		self.buttons.append(Button(title: "Overdub", action_id: 3, target: self.target, action: self.action, frame:
			NSRect(x: 80, y: 48, width: 100, height: 39)))
		self.buttons.append(Button(title: "Multiply", action_id: 4, target: self.target, action: self.action, frame:
			NSRect(x: 80, y: 5, width: 100, height: 38)))
		
		self.buttons.append(Button(title: "Load", action_id: 5, target: self.target, action: self.action, frame:
			NSRect(x: 185, y: 95, width: 71, height: 35)))
		self.buttons.append(Button(title: "Save", action_id: 6, target: self.target, action: self.action, frame:
			NSRect(x: 185, y: 55, width: 71, height: 35)))
		self.buttons.append(Button(title: "Trig", action_id: 7, target: self.target, action: self.action, frame:
			NSRect(x: 261, y: 95, width: 73, height: 35)))
		self.buttons.append(Button(title: "Once", action_id: 8, target: self.target, action: self.action, frame:
			NSRect(x: 261, y: 55, width: 73, height: 35)))
		self.buttons.append(Button(title: "Mute", action_id: 9, target: self.target, action: self.action, frame:
			NSRect(x: 339, y: 95, width: 71, height: 35)))
		self.buttons.append(Button(title: "Solo", action_id: 10, target: self.target, action: self.action, frame:
			NSRect(x: 339, y: 55, width: 71, height: 35)))
		
		self.buttons.append(Button(title: "Replace", action_id: 11, target: self.target, action: self.action, frame:
			NSRect(x: 185, y: 30, width: 110, height: 20)))
		self.buttons.append(Button(title: "Substitute", action_id: 12, target: self.target, action: self.action, frame:
			NSRect(x: 185, y: 5, width: 110, height: 20)))
		self.buttons.append(Button(title: "Insert", action_id: 13, target: self.target, action: self.action, frame:
			NSRect(x: 300, y: 30, width: 110, height: 20)))
		self.buttons.append(Button(title: "Delay", action_id: 14, target: self.target, action: self.action, frame:
			NSRect(x: 300, y: 5, width: 110, height: 20)))
		
		self.buttons.append(Button(title: "Rev", action_id: 15, target: self.target, action: self.action, frame:
			NSRect(x: 415, y: 92, width: 100, height: 38)))
		self.buttons.append(Button(title: "Scratch", action_id: 16, target: self.target, action: self.action, frame:
			NSRect(x: 415, y: 48, width: 100, height: 39)))
		self.buttons.append(Button(title: "Pause", action_id: 17, target: self.target, action: self.action, frame:
			NSRect(x: 415, y: 5, width: 100, height: 38)))
		
		for button in self.buttons {
			self.addSubview(button)
		}
	}
}

class Pocket_Pod_Box: Box {
	var go_to_value_text_field: NSTextField = NSTextField()
	
	override init(frame: NSRect, target: AnyObject, action: Selector) {
		super.init(frame: frame, target: target, action: action)
		
		self.title = "Actions"
		self.init_buttons()
		self.init_go_to()
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func init_buttons() {
		self.buttons.append(Button(title: "Next", action_id: 18, target: self.target, action: self.action, frame:
			NSRect(x: 5, y: 63, width: 95, height: 28)))
		self.buttons.append(Button(title: "Prev", action_id: 19, target: self.target, action: self.action, frame:
			NSRect(x: 5, y: 30, width: 95, height: 28)))
		self.buttons.append(Button(title: "Go To", action_id: 20, target: self.target, action: self.action, frame:
			NSRect(x: 5, y: 5, width: 60, height: 20)))
		
		self.buttons[2].is_check_box(.LeftTextAlignment)
		
		for button in self.buttons {
			self.addSubview(button)
		}
	}
	
	func init_go_to() {
		self.go_to_value_text_field.frame = NSRect(x: 70, y: 5, width: 30, height: 20)
		self.go_to_value_text_field.alignment = .CenterTextAlignment
		
		self.go_to_value_text_field.action = self.action
		self.go_to_value_text_field.target = self.target
		
		self.set_go_to_value(0)
		
		self.addSubview(self.go_to_value_text_field)
	}
	
	func set_go_to_value(value: Int) {
		self.go_to_value_text_field.stringValue = "\(value)"
	}
}

class Loops_Box: Box {
	override init(frame: NSRect, target: AnyObject, action: Selector) {
		super.init(frame: frame, target: target, action: action)
		
		self.title = "Loops"
		
		self.initButtons()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func initButtons() {
		self.buttons.append(Button(title: "Loop 5", action_id: 25, target: self.target, action: self.action, frame: NSRect(x: 5, y: 74, width: 60, height: 20)))
		self.buttons.append(Button(title: "Loop 4", action_id: 24, target: self.target, action: self.action, frame: NSRect(x: 5, y: 56, width: 60, height: 20)))
		self.buttons.append(Button(title: "Loop 3", action_id: 23, target: self.target, action: self.action, frame: NSRect(x: 5, y: 38, width: 60, height: 20)))
		self.buttons.append(Button(title: "Loop 2", action_id: 22, target: self.target, action: self.action, frame: NSRect(x: 5, y: 20, width: 60, height: 20)))
		self.buttons.append(Button(title: "Loop 1", action_id: 21, target: self.target, action: self.action, frame: NSRect(x: 5, y: 2, width: 60, height: 20)))
		
		self.buttons.append(Button(title: "Next", action_id: 26, target: self.target, action: self.action, frame: NSRect(x: 85, y: 74, width: 60, height: 20)))
		self.buttons.append(Button(title: "Prev", action_id: 27, target: self.target, action: self.action, frame: NSRect(x: 85, y: 56, width: 60, height: 20)))
		self.buttons.append(Button(title: "Add", action_id: 28, target: self.target, action: self.action, frame: NSRect(x: 85, y: 38, width: 60, height: 20)))
		self.buttons.append(Button(title: "Del", action_id: 29, target: self.target, action: self.action, frame: NSRect(x: 85, y: 20, width: 60, height: 20)))
		
		for button in self.buttons {
			button.is_check_box(.LeftTextAlignment)
			button.font = NSFont(name: ".HelveticaNeueDeskInterface-Regular", size: 10)
			self.addSubview(button)
		}
	}
}

class Unboxed_Box: NSView {
	var buttons: [Button] = []
	
	let target: AnyObject
	let press_action: Selector
	let unboxed_action: Selector
	
	var pop_up_button: Pop_Up_Button?
	
	init(frame: NSRect, target: AnyObject, press_action: Selector, unboxed_action: Selector) {
		self.target = target
		self.press_action = press_action
		self.unboxed_action = unboxed_action
		
		super.init(frame: frame)
		
		self.init_buttons()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func init_buttons() {
		self.buttons.append(Button(title: "Clear", action_id: 0, target: self.target, action: self.unboxed_action, frame: NSRect(x: 5, y: 12, width: 55, height: 55)))
		self.buttons.append(Button(title: "Save", action_id: 1, target: self.target, action: self.unboxed_action, frame: NSRect(x: 65, y: 12, width: 55, height: 55)))
		self.buttons.append(Button(title: "Preferences", action_id: 2, target: self.target, action: self.unboxed_action, frame: NSRect(x: 5, y: 72, width: 115, height: 30)))
		
		let items = ["Simple Press", "Double Press", "Long Press"]
		
		self.pop_up_button = Pop_Up_Button(action_id: 2, target: self.target, action: self.press_action, frame: NSRect(x: 2, y: 107, width: 121, height: 30))
		self.pop_up_button!.init_items(items)
		
		for button in self.buttons {
			button.setButtonType(NSButtonType.MomentaryPushInButton)
			self.addSubview(button)
		}
		
		self.addSubview(self.pop_up_button!)
	}
	
	func set_press_to(type: Type_Of_Press) {
		self.pop_up_button?.selectItemWithTitle(type.rawValue)
	}
	
	func get_press_selected() -> Type_Of_Press {
		switch self.pop_up_button!.indexOfSelectedItem {
		case 0:
			return .simple
		case 1:
			return .double
		default:
			return .long
		}
	}
}