//
//  Principal_View.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Principal_View: NSView {
	var pedals: [Pedal] = []
	var buttons: [Button] = []
	var boxes: Boxes?
	var unboxed_box: Unboxed_Box?
	
	var pedal_selected: Pedal?
	var press_selected: Type_Of_Press?
	var button_selected: Button?
	var buttons_activated: [Button?] = []
	
	var use_color: Bool = false
	
	var storage: Storage
	
	let delegate: App_Delegate
	
	init(frame: NSRect, delegate: App_Delegate) {
		self.storage = delegate.storage!
		self.delegate = delegate
		
		super.init(frame: frame)
		
		self.init_boxes()
		self.init_pedals()
		self.init_press()
		self.init_buttons()
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func init_boxes() {
		self.boxes = Boxes(target: self, action: "button_pressed:",
			action_box_frame: NSRect(x: 5, y: 5, width: 535, height: 160),
			pocket_pod_box_frame: NSRect(x: 360, y: 155, width: 120, height: 120),
			loops_box_frame: NSRect(x: 485, y: 155, width: 175, height: 120))
		self.unboxed_box = Unboxed_Box(frame: NSRect(x: 540, y: 5, width: 120, height: 160), target: self, press_action: "press_changed:", unboxed_action: "unboxed_button_pressed:")
		
		self.addSubview(self.boxes!.actions_box)
		self.addSubview(self.boxes!.pocket_pod_box)
		self.addSubview(self.boxes!.loops_box)
		self.addSubview(self.unboxed_box!)
	}
	
	func init_pedals() {
		self.use_color = self.storage.document!["Settings"]!["Use_Color"] as! Bool
		
		for i in 0..<5 {
			self.pedals.append(Pedal(target: self, action: "pedal_pressed:", id: i, use_color: self.use_color))
			self.addSubview(self.pedals.last! as Pedal)
		}
		
		self.pedal_selected = self.pedals[self.delegate.storage!.document!["Current_Items"]!["Pedal_Selected"] as! Int]
		self.pedal_selected!.on_off_image.toggle()
	}
	
	func init_press() {
		self.press_selected = Type_Of_Press(rawValue: self.delegate.storage!.document!["Current_Items"]!["Press_Selected"] as! String)
		self.unboxed_box!.pop_up_button!.selectItemWithTitle(self.press_selected!.rawValue.stringByReplacingOccurrencesOfString("_", withString: " ", options: .LiteralSearch, range: nil))
	}
	
	func init_buttons() {
		for buttons in [ self.boxes!.actions_box.buttons, self.boxes!.pocket_pod_box.buttons, self.boxes!.loops_box.buttons ] {
			for button in buttons {
				self.buttons.append(button)
			}
		}
		
		if self.use_color != self.delegate.storage!.document!["Settings"]!["Use_Color"] as! Bool {
			self.use_color.toggle()
		}
		
		let button_id: Int = self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.objectForKey("Actions")!.valueForKey(self.press_selected!.rawValue) as! Int
		
		if button_id != -1 {
			self.button_selected = self.buttons[button_id]
		} else {
			self.button_selected = nil
		}
		
		for i in 0..<5 {
			let button_id: Int = self.delegate.storage!.document!["Pedals"]!["Pedal_\(i)"]!!.objectForKey("Actions")!.valueForKey(self.press_selected!.rawValue) as! Int
			
			if button_id != -1 {
				self.buttons_activated.append(self.buttons[button_id])
			} else {
				self.buttons_activated.append(nil)
			}
			
			if self.use_color {
				self.buttons_activated.last!?.set_color(colors[i])
			}
			
			self.buttons_activated.last!?.pause()
		}
		
		self.button_selected?.active()
		
		let go_to_value: Int = self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.valueForKey("Go_To_Value") as! Int
		self.boxes!.pocket_pod_box.go_to_value_text_field.integerValue = go_to_value
	}
	
	func pedal_pressed(pedal: Pedal) {
		/* Pausing last button if it exist */
		self.buttons_activated[self.pedal_selected!.id]?.pause()
		
		/* Toggle previous pedal */
		self.pedal_selected!.on_off_image.toggle()
		/* Assign new pedal */
		self.pedal_selected = self.pedals[pedal.id]
		/* Toggle new pedal */
		self.pedal_selected!.on_off_image.toggle()
		
		/* Assign new selected button */
		self.button_selected = self.buttons_activated[self.pedal_selected!.id]
		/* Active selected button */
		self.button_selected?.active()
		
		self.delegate.storage!.document!["Current_Items"]!.setValue(self.pedal_selected!.id, forKey: "Pedal_Selected")

		let go_to_value: Int = self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.valueForKey("Go_To_Value") as! Int
		self.boxes!.pocket_pod_box.go_to_value_text_field.integerValue = go_to_value
	}
	
	func button_pressed(sender: AnyObject) {
		post_notification_named(name: "notif")
		
		switch sender {
		case is Button:
			self.button_selected?.clear()
			
			let action: Int
			let pedal: Int = self.pedal_selected!.id
			let press: String = self.press_selected!.rawValue
			
			if (sender as! Button).state == on {
				self.button_selected = sender as? Button
				self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.objectForKey("Actions")!.setValue(self.button_selected!.action_id, forKey: self.press_selected!.rawValue)
				action = self.button_selected!.action_id
			} else {
				self.button_selected = nil
				self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.objectForKey("Actions")!.setValue(-1, forKey: self.press_selected!.rawValue)
				action = -1
			}
			
			self.buttons_activated[self.pedal_selected!.id] = self.button_selected
			
			if self.use_color {
				self.button_selected?.set_color(colors[self.pedal_selected!.id])
			}
			
			/* println("Set \(pedal) \(press) \(action)") */
			/* Set pedal_id press_name action_id */
			if self.button_selected == 20 {
				let go_to_value: Int = self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.valueForKey("Go_To_Value") as! Int
				self.delegate.socket?.send("Set \(pedal) \(press) \(action) \(go_to_value)")
			} else {
				self.delegate.socket?.send("Set \(pedal) \(press) \(action)")
			}
			
			break
		case is NSTextField:
			let go_to_value: Int = (sender as! NSTextField).integerValue
			self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.setValue(go_to_value, forKey: "Go_To_Value")
			break
		default:
			break
		}
	}
	
	func press_changed(sender: Pop_Up_Button) {
		self.press_selected = Type_Of_Press(rawValue: sender.titleOfSelectedItem!.stringByReplacingOccurrencesOfString(" ", withString: "_", options: .LiteralSearch, range: nil))
		
		self.reload_buttons()
		
		self.button_selected = self.buttons_activated[self.pedal_selected!.id]
		self.button_selected?.active()
		
		self.delegate.storage!.document!["Current_Items"]!.setValue(self.press_selected!.rawValue, forKey: "Press_Selected")
	}
	
	func unboxed_button_pressed(sender: Button) {
		switch sender.action_id {
			/* Clear */
		case 0:
			for i in 0..<5 {
				self.delegate.storage!.document!["Pedals"]!["Pedal_\(i)"]!!.objectForKey("Actions")!.setValue(-1, forKey: "Simple_Press")
				self.delegate.storage!.document!["Pedals"]!["Pedal_\(i)"]!!.objectForKey("Actions")!.setValue(-1, forKey: "Double_Press")
				self.delegate.storage!.document!["Pedals"]!["Pedal_\(i)"]!!.objectForKey("Actions")!.setValue(-1, forKey: "Long_Press")
				self.delegate.storage!.document!["Current_Items"]!.setValue(self.pedal_selected!.id, forKey: "Pedal_Selected")
				self.delegate.storage!.document!["Current_Items"]!.setValue(self.press_selected!.rawValue, forKey: "Press_Selected")
				self.delegate.storage!.document!["Pedals"]!["Pedal_\(i)"]!!.setValue(0, forKey: "Go_To_Value")
				
				self.boxes!.pocket_pod_box.go_to_value_text_field.integerValue = 0
				
				self.reload_buttons()
			}
			break
			/* Save */
		case 1:
			if self.delegate.storage!.write_document() {
				log("Preferences saved.")
			} else {
				log("Failed to save preferences")
			}
			
			break
			/* Preferences */
		case 2:
			self.delegate.display_preferences_pane()
			break
		default:
			break
		}
	}
	
	func reload_pedals() {
		for pedal in self.pedals {
			if self.use_color {
				pedal.use_color()
			} else {
				pedal.remove_color()
			}
		}
	}
	
	func reload_buttons() {
		if self.use_color != self.delegate.storage!.document!["Settings"]!["Use_Color"] as! Bool {
			self.use_color.toggle()
		}
		
		for i in 0..<5 {
			self.buttons_activated[i]?.clear()
			
			let button_id: Int = self.delegate.storage!.document!["Pedals"]!["Pedal_\(i)"]!!.objectForKey("Actions")!.valueForKey(self.press_selected!.rawValue) as! Int
			
			if button_id != -1 {
				self.buttons_activated[i] = self.buttons[button_id]
			} else {
				self.buttons_activated[i] = nil
			}
		}
		
		let id = self.delegate.storage!.document!["Pedals"]![self.pedal_selected!.name]!!.objectForKey("Actions")?.valueForKey(self.press_selected!.rawValue) as! Int
		
		if id != -1 {
			self.button_selected = self.buttons[id]
		} else {
			self.button_selected = nil
		}
		
		for i in 0..<5 {
			self.buttons_activated[i]?.pause()
			
			if self.use_color {
				self.buttons_activated[i]?.set_color(colors[i])
			} else {
				self.buttons_activated[i]?.remove_color()
			}
		}
		
		self.button_selected?.active()
	}
}