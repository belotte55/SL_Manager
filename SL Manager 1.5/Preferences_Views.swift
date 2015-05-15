//
//  Preferences_View.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Preferences_View: NSTabView, NSTabViewDelegate {
	var log_file: Log_File?
	//var storage: Storage
	var new_storage: Storage
	var app_delegate: App_Delegate
	
	let general_tab: NSTabViewItem
	let connection_tab: NSTabViewItem
	let about_tab: NSTabViewItem
	let raspberry_tab: NSTabViewItem
	
	let general_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 100, height: 120))
	let connection_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 150, height: 140))
	let about_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 200, height: 100))
	let raspberry_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 200, height: 100))
	
	var is_first_tab: Bool = true
	
	//var need_to_reload: NSDictionary = [String: Bool]()//["Buttons": false as Bool, "Socket": false as Bool, "Server": false as Bool]
	var need_to_reload: [String: Bool]
	
	init(frame: NSRect, delegate: App_Delegate) {
		self.new_storage = delegate.storage!.copy()!
		self.app_delegate = delegate
		
		self.general_tab = NSTabViewItem(identifier: delegate)
		self.connection_tab = NSTabViewItem(identifier: delegate)
		self.about_tab = NSTabViewItem(identifier: delegate)
		self.raspberry_tab = NSTabViewItem(identifier: delegate)
		
		self.need_to_reload = ["Buttons": false, "Socket": false, "Server": false]
		
		super.init(frame: frame)
		
//		self.new_storage.document!["Connection"]!.setValue("toto", forKey: "Port_Client")
//		println(self.app_delegate.storage!.document!["Connection"]!["Port_Client"])
		
		self.delegate = self
		
		self.log_file = (NSApplication.sharedApplication().delegate as! App_Delegate).log_file
		
		self.general_tab.label = "General"
		self.general_tab.view = General_View(frame: self.general_tab_view_frame, delegate: self)
	
		self.connection_tab.label = "Connection"
		self.connection_tab.view = Connection_View(frame: self.connection_tab_view_frame, delegate: self)
		
		self.raspberry_tab.label = "Raspberry"
		self.raspberry_tab.view = Raspberry_View(frame: self.raspberry_tab_view_frame, delegate: self)
		
		self.about_tab.label = "About"
		self.about_tab.view = About_View(frame: self.about_tab_view_frame, delegate: self)
		
		self.addTabViewItem(self.general_tab)
		self.addTabViewItem(self.connection_tab)
		self.addTabViewItem(self.raspberry_tab)
		self.addTabViewItem(self.about_tab)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func init_tabs() {
		
	}
	
	func did_appear() {
		self.new_storage = self.app_delegate.storage!.copy()!
		
		for item in self.need_to_reload {
			self.need_to_reload[item.0] = false
		}
	}
	
	func check() {
		(self.connection_tab.view as! Connection_View).check()
		(self.general_tab.view as! General_View).check()
		
		if (NSApplication.sharedApplication().delegate as! App_Delegate).storage!.document!["Connection"]!["IP_Client"] as! String != self.new_storage.document!["Connection"]!["IP_Client"] as! String ||
			(NSApplication.sharedApplication().delegate as! App_Delegate).storage!.document!["Connection"]!["Port_Client"] as! String != self.new_storage.document!["Connection"]!["Port_Client"] as! String {

			self.need_to_reload["Socket"] = true
		}
		
		if (NSApplication.sharedApplication().delegate as! App_Delegate).storage!.document!["Connection"]!["IP_Server"] as! String != self.new_storage.document!["Connection"]!["IP_Server"] as! String {
				
			self.need_to_reload["Server"] = true
		}
		
		if (NSApplication.sharedApplication().delegate as! App_Delegate).storage!.document!["Settings"]!["Use_Color"] as! Bool != self.new_storage.document!["Settings"]!["Use_Color"] as! Bool {
				
			self.need_to_reload["Buttons"] = true
		}
	}

	func tabView(tabView: NSTabView, willSelectTabViewItem tabViewItem: NSTabViewItem?) {
		if self.is_first_tab {
			self.app_delegate.resize_preferences_window("First")
			self.is_first_tab = false
		} else {
			self.app_delegate.resize_preferences_window(tabViewItem!.label)
		}
	}
}

class General_View: NSView {
	let delegate: Preferences_View
	
	var buttons: [Button] = []
	var check_boxs: [Button] = []
	
	let settings: [String] = ["Save_When_Quit", "Send_At_Launch", "Use_Color"]
	
	var new_path: String?
	
	init(frame: NSRect, delegate: Preferences_View) {
		self.delegate = delegate
		
		super.init(frame: frame)
		
		self.buttons.append(Button(title: "Load", action_id: 2, target: self, action: "load:", frame: NSRect(x: 5, y: 28, width: 75, height: 45)))
		self.buttons.append(Button(title: "Save To", action_id: 3, target: self, action: "save_to:", frame: NSRect(x: 85, y: 28, width: 75, height: 45)))
		self.buttons.append(Button(title: "Send All", action_id: 4, target: self, action: "sendAll", frame: NSRect(x: 5, y: 0, width: 155, height: 25)))
		
		self.check_boxs.append(Button(title: "Save all when quit.", action_id: 0, target: self, action: "", frame: NSRect(x: 170, y: 50, width: 160, height: 20)))
		self.check_boxs.append(Button(title: "Send all at launch.", action_id: 1, target: self, action: "", frame: NSRect(x: 170, y: 30, width: 160, height: 20)))
		self.check_boxs.append(Button(title: "Use colors.", action_id: 2, target: self, action: "", frame: NSRect(x: 170, y: 10, width: 160, height: 20)))
		
		
		for button in self.buttons {
			button.setButtonType(NSButtonType.MomentaryPushInButton)
			self.addSubview(button)
		}
		
		for button in self.check_boxs {
			button.is_check_box(.RightTextAlignment)
			button.alignment = .LeftTextAlignment
			self.addSubview(button)
		}
		
		self.addSubview(Apply_Button())
		self.addSubview(Cancel_Button())
		
		let settings: [String] = ["Save_When_Quit", "Send_At_Launch", "Use_Color"]
		
		for i in 0..<settings.count {
			if self.delegate.new_storage.document!["Settings"]![settings[i]] as! Bool {
				self.check_boxs[i].state = 1
			} else {
				self.check_boxs[i].state = 0
			}
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func load(sender: Button) {
		let panel: NSOpenPanel = NSOpenPanel()
		panel.allowedFileTypes = ["plist"]
		
		if panel.runModal() == NSFileHandlingPanelOKButton {
			self.new_path = panel.URL!.path!
			self.delegate.new_storage = Storage(bundle_file_name: bundle_storage_file_name, file_path: self.new_path!)!
			
			log("Preferences file loaded: \(self.new_path)")
			
			for i in 0..<settings.count {
				if self.delegate.new_storage.document!["Settings"]![settings[i]] as! Bool {
					self.check_boxs[i].state = on
				} else {
					self.check_boxs[i].state = off
				}
			}
			
			self.delegate.need_to_reload["Buttons"] = true
		}
	}
	
	func save_to(sender: Button) {
		let panel: NSSavePanel = NSSavePanel()
		
		if panel.runModal() == NSFileHandlingPanelOKButton {
			var new_path: String = panel.URL!.path!
			
			if new_path.lastPathComponent.componentsSeparatedByString(".").last! != "plist" {
				new_path = "\(new_path).plist"
			}
			
			let alert: NSAlert = NSAlert()
			alert.informativeText = "If you press No, you'll continue to use \((NSApplication.sharedApplication().delegate as! App_Delegate).storage!.file_name)."
			alert.messageText = "Load \(new_path.lastPathComponent) ?"
			alert.addButtonWithTitle("Yes")
			alert.addButtonWithTitle("No")
			
			(NSApplication.sharedApplication().delegate as! App_Delegate).storage!.write_document_to(new_path)

			if alert.runModal() == 1000 {
				(NSApplication.sharedApplication().delegate as! App_Delegate).storage = Storage(bundle_file_name: bundle_storage_file_name, file_path: new_path)
				(NSApplication.sharedApplication().delegate as! App_Delegate).load_window_title()
			}
			
			log("Preferences file saved to \(new_path)")
		}
	}
	
	func check() {
		for button in self.check_boxs {
			if button.state == on {
				self.delegate.new_storage.document!["Settings"]!.setValue(true, forKey: settings[button.action_id])
			} else {
				self.delegate.new_storage.document!["Settings"]!.setValue(false, forKey: settings[button.action_id])
			}
		}
	}
}

class Connection_View: NSView {
	let delegate: Preferences_View
	
	var ip_labels: [NSTextField] = []
	var port_labels: [NSTextField] = []
	
	var radios: Radio_Matrix?
	
	init(frame: NSRect, delegate: Preferences_View) {
		self.delegate = delegate
		
		super.init(frame: frame)
		
		self.ip_labels.append(Label(text: "IP", frame: NSRect(x: 0, y: 25, width: 50, height: 20)))
		self.ip_labels.append(Input(frame: NSRect(x: 40, y: 25, width: 100, height: 20), action_id: 0))
		self.ip_labels[1].target = self.delegate
		self.ip_labels[1].action = ""
		self.ip_labels[1].stringValue = self.delegate.new_storage.document!["Connection"]!["IP_Client"] as! String
		
		self.port_labels.append(Label(text: "Port", frame: NSRect(x: 0, y: 0, width: 50, height: 20)))
		self.port_labels.append(Input(frame: NSRect(x: 40, y: 0, width: 100, height: 20), action_id: 1))
		self.port_labels[1].target = self.delegate
		self.port_labels[1].action = ""
		self.port_labels[1].stringValue = self.delegate.new_storage.document!["Connection"]!["Port_Client"] as! String
		
		for label in self.ip_labels {
			self.addSubview(label)
		}
		
		for label in self.port_labels {
			self.addSubview(label)
		}
		
		self.radios = Radio_Matrix()
		
//		let ips: [String] = NSHost.currentHost().addresses as! [String]
//		var current_ip_not_found: Bool = true
//		
//		for i in 0..<ips.count {
//			if ips[i].componentsSeparatedByString(".").count == 4 {
//				self.radios!.new_radio(ips[i] as String)
//				
//				if ips[i] == self.delegate.new_storage.get_ip_server() {
//					self.radios!.changed(self.radios!.matrix.last!)
//					current_ip_not_found = false
//				}
//			}
//		}
//		
//		if current_ip_not_found {
//			self.radios!.changed(self.radios!.matrix.last!)
//		}
		
		for radio in self.radios!.matrix {
			self.addSubview(radio)
		}
		
		self.addSubview(Label(text: "Raspberry", frame: NSRect(x: 0, y: 45, width: 100, height: 20)))
		self.addSubview(Label(text: "Mac", frame: NSRect(x:160, y: 45, width: 100, height: 20)))
		
		self.addSubview(Apply_Button(x: 100))
		self.addSubview(Cancel_Button(x: 100))
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func check() {
		self.delegate.new_storage.set_ip_client(self.ip_labels[1].stringValue)
		self.delegate.new_storage.set_port_client(self.port_labels[1].stringValue)
		
		//self.delegate.new_storage.set_ip_server(self.radios!.radio_selected!.title)
	}
}

class Raspberry_View: NSView {
	let delegate: Preferences_View
	
	let image_view: Image_View = Image_View(frame: NSRect(x: 250, y: 0, width: 70, height: 70), image_name: "raspi.png")
	
	var reboot_button: Button?
	var halt_button: Button?
	
	init(frame: NSRect, delegate: Preferences_View) {
		self.delegate = delegate
		
		super.init(frame: frame)
		
		self.addSubview(self.image_view)
		
		self.reboot_button = Button(title: "Reboot", action_id: -1, target: self, action: "reboot", frame: NSRect(x: 20, y: 40, width: 100, height: 30))
		self.halt_button = Button(title: "Halt", action_id: -1, target: self, action: "halt", frame: NSRect(x: 20, y: 5, width: 100, height: 30))
		
		self.addSubview(reboot_button!)
		self.addSubview(halt_button!)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func reboot() {
		(NSApplication.sharedApplication().delegate as! App_Delegate).socket?.send("Reboot")
		(NSApplication.sharedApplication().delegate as! App_Delegate).close_preferences_pane(reboot_button!)
	}
	
	func halt() {
		(NSApplication.sharedApplication().delegate as! App_Delegate).socket?.send("Halt")
		(NSApplication.sharedApplication().delegate as! App_Delegate).close_preferences_pane(halt_button!)
	}
}

class About_View: NSView {
	let delegate: Preferences_View
	
	let image_view: Image_View = Image_View(frame: NSRect(x: 5, y: 5, width: 150, height: 150), image_name: "Logo rounded.png")
	let members: [String] = ["Frédéric HENNER", "Justin STEPHAN", "Frank BELLOTTO"]
	let mail: String = "slmanager.team@gmail.com"
	
	init(frame: NSRect, delegate: Preferences_View) {
		self.delegate = delegate
		
		super.init(frame: frame)

		self.addSubview(self.image_view)
		
		var labels: [Label] = []
		
		for i in 0..<3 {
			labels.append(Label(text: self.members[i], frame: NSRect(x: 170, y: 60 + i*20, width: 200, height: 20)))
		}
		
		labels.append(Label(text: "SL Manager", frame: NSRect(x: 170, y: 125, width: 200, height: 30)))
		labels.last!.font = NSFont(name: "Lucida Grande", size: 22)
		
		labels.append(Label(text: "Contact", frame: NSRect(x: 0, y: 50, width: 200, height: 20)))
		labels.last!.font = NSFont(name: "Lucida Grande", size: 15)
		
		let button: Button = Button(title: self.mail, action_id: -1, target: self, action: "send_mail", frame: NSRect(x: 160, y: 40, width: 210, height: 20))
		button.font = NSFont(name: "Lucida Grande", size: 12)
		button.setButtonType(NSButtonType.MomentaryChangeButton)
		button.bordered = false
		
		for label in labels {
			label.alignment = .CenterTextAlignment
			self.addSubview(label)
		}
		
		self.addSubview(button)
		
		self.addSubview(Apply_Button())
		self.addSubview(Cancel_Button())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func send_mail() {
		var url: NSURL = NSURL(string: "mailto:\(self.mail)")!
		NSWorkspace.sharedWorkspace().openURL(url)
	}
}

class Apply_Button: NSButton {	
	init(x: Int = 0) {
		super.init(frame: NSRect(x: 330 + x, y: 0, width: 50, height: 30))
		
		self.title = "Apply"
		self.target = NSApplication.sharedApplication().delegate as! App_Delegate
		self.action = "close_preferences_pane:"
		
		self.bezelStyle = .SmallSquareBezelStyle
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}

class Cancel_Button: NSButton {
	init(x: Int = 0) {
		super.init(frame: NSRect(x: 275 + x, y: 0, width: 50, height: 30))
		
		self.title = "Cancel"
		
		self.target = NSApplication.sharedApplication().delegate as! App_Delegate
		self.action = "close_preferences_pane:"
		
		self.bezelStyle = .SmallSquareBezelStyle
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}