//
//  AppDelegate.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class App_Delegate: NSObject, NSApplicationDelegate {
	
	/* # WINDOW */
	/* Window attributes */
	let window_size: NSSize = NSSize(width: 680, height: 280)
	let preferences_window_size: NSSize = NSSize(width: 400, height: 170)

	var principal_window: NSWindow?
	var preferences_window: NSWindow?

	/* # STORAGE */
	
	/* Contains .plist file */
	var storage: Storage?
	/* Used to store preferences file's path */
	let user_defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
	
	/* # VIEWS */
	
	var loading_view: Loading_View?
	var principal_view: Principal_View?
	var preferences_view: Preferences_View?
	
	/* # CONNECTIONS */
	
	var server: Server?
	var socket: Socket?
	
	/* # OTHERS */
	
	var log_file: Log_File?
	var pocket_pod: Pocket_Pod?
	let notification_center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
	
	/*		NOTIFIED METHODS		*/
	func applicationDidFinishLaunching(notification: NSNotification) {
		self.init_windows()
		
		self.notification_center.addObserver(self, selector: "display_preferences_pane", name: "display_preferences_pane", object: nil)
		self.notification_center.addObserver(self, selector: "resize_preferences_window:", name: "resize_preferences_window", object: nil)
		
		/* The loading view is initialized first, to be displayed while storage is loading */
		self.init_loading_view()
		self.init_logs()
		self.init_storage()
		self.init_socket()
		self.init_server()
		self.init_views()
		self.load_window_title()
		
		/* All is ok, application get launched */
		log("Launched.")
		
		self.pocket_pod = Pocket_Pod(name: "Line 6 Pocket POD")
		
		if self.storage!.document!["Settings"]!["Send_At_Launch"]! as! Bool {
			self.send_all()
		}
	}
	
	func applicationWillTerminate(aNotification: NSNotification) {
		/* Save preferences if option is checked */
		if self.storage!.document!["Settings"]!["Save_When_Quit"]! as! Bool {
			self.storage!.write_document()
		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
		return true
	}
	
	/*		END NOTIFIED METHODS */
	
	
	
	/*		INITIALIZATIONS		*/
	
	/**
		Initializes both principal's and preferences's windows.
	*/
	func init_windows() {
		self.principal_window = NSWindow(contentRect: NSRect(origin: NSPoint(x: 100, y: 100), size: self.window_size),
										 styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask,
											backing: .Buffered,
											  defer: false)
		self.principal_window!.title = "SL Manager"
		
		/* Display the window */
		self.principal_window!.makeKeyAndOrderFront(self)
		
		self.preferences_window = NSWindow(contentRect: NSRect(origin: default_origin,
																size: NSSize(width: 0, height: 0)),//preferences_window_size),
														 styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask,
															backing: .Buffered,
															  defer: false)
	}
	
	/**
		Initializes the loading view.
	*/
	func init_loading_view() {
		self.loading_view = Loading_View(frame: self.principal_window!.frame, delegate: self)
		
		/* Set loading view to principal window's content view, to be displayed */
		self.principal_window!.contentView = self.loading_view!
	}
	
	/**
		Initializes the log's file.
	*/
	func init_logs() {
		self.log_file = Log_File(file_name: "logs.txt", dir_name: dir_name)
	}
	
	/**
		Initializes storage's file.
	*/
	func init_storage() {
		/* Check if a path is saved */
		if let path: String = self.user_defaults.valueForKey("SL Preferences Path") as? String {
			/* Try to load storage */
			if let storage: Storage = Storage(bundle_file_name: bundle_storage_file_name, file_path: path) {
				self.storage = storage
			} else {
				log("Unable to create \(path).")
				log("Please reinstall application.")

				/* Close application */
				NSApplication.sharedApplication().terminate(self)
			}
		} else {
			/* Try to init storage */
			if let storage: Storage = Storage(bundle_file_name: bundle_storage_file_name, file_name: "SL Manager Preferences.plist", directory_name: dir_name) {
				self.storage = storage
				
				/* Set new storage's path */
				self.user_defaults.setValue(self.storage!.file_path, forKey: "SL Preferences Path")
			} else {
				log("Unable to init preferences file.")
				log("Please reinstall application.")
				
				/* Close application */
				NSApplication.sharedApplication().terminate(self)
			}
		}
	}
	
	/**
		Initializes socket.
	*/
	func init_socket() {
		self.socket = Socket(delegate: self, ip: self.storage!.get_ip_client(), port: self.storage!.get_port_client())
	}
	
	/**
		Initializes server.
	*/
	func init_server() {
		self.reconnect_server()
	}
	
	/**
		Initializes both principal's and preferences's views.
	*/
	func init_views() {
		self.preferences_view = Preferences_View(frame: preferences_window!.frame, delegate: self)
		self.preferences_window!.contentView = self.preferences_view!
		
		self.principal_view = Principal_View(frame: self.principal_window!.frame, delegate: self)
		self.principal_window!.contentView = self.principal_view!
	}
	
	/*		END INITIALIZATIONS	*/

	/**
		Save preferences's file path and set window's name with the preferences's file name.
	*/
	func load_window_title() {
		/* Save preferences file path */
		self.user_defaults.setValue(self.storage!.file_path, forKey: "SL Preferences Path")
		/* Change window's name */
		self.principal_window!.title = "SL Manager - \(self.storage!.file_name.stringByDeletingPathExtension)"
	}
	
	func reconnect_socket() {
		/* If socket can be created */
		if let is_socket_usable: Bool = self.socket?.connect_to(self.storage!.get_ip_client(), port: self.storage!.get_port_client()) {
			/* If it's usable */
			if !is_socket_usable {
				self.socket = nil
			}
		} else {
			self.socket = nil
		}
	}
	
	func reconnect_server() {
		let ip: String = self.socket!.socket.localHost_IPv4()
		let port: Int
		
		if self.storage!.get_port_server() < 5000 ||
			self.storage!.get_port_server() > 5100 {
			port = 5000
		} else {
			port = self.storage!.get_port_server() + 1
		}
		
		self.storage!.set_port_server(port)
		
		if self.server != nil {
			if let socket: Socket = Socket(delegate: self, ip: ip, port: port) {
				socket.send("stop")
				log("Server stopped")
			} else {
				log("Failed to stop server")
			}
		}
		
		self.socket?.send("new_host \(ip) \(port)")
		self.server = Server(delegate: self, ip: ip, port: port)
	}
	
	func received_trame(trame: String) {
		println(trame)
		switch trame {
		case "Next":
			self.pocket_pod?.next()
			break
		case "Prev":
			self.pocket_pod?.prev()
			break
		case "Go_To":
			let value: Int = self.storage!.document!["Pedals"]![(self.principal_window!.contentView as! Principal_View).pedal_selected!.name]!?.valueForKey("Go_To_Value") as! Int
			self.pocket_pod?.go_to(value)
			break
		default:
			break
		}
	}
	
	func display_preferences_pane() {
		self.principal_window!.beginSheet(self.preferences_window!, completionHandler: nil)
		(self.preferences_window!.contentView as! Preferences_View).did_appear()
	}
	
	func close_preferences_pane(sender: NSButton) {
		self.principal_window!.endSheet(self.preferences_window!)
		
		switch sender.title {
		case "Apply":
			(self.preferences_window!.contentView as! Preferences_View).check()
			self.storage = (self.preferences_window!.contentView as! Preferences_View).new_storage
			
			self.load_window_title()
			
			let need_to_reload: [String: Bool] = (self.preferences_window!.contentView as! Preferences_View).need_to_reload
			let principal_view: Principal_View = self.principal_window!.contentView as! Principal_View
			/* ["Buttons": false, "Socket": false, "Server": false, "Storage": false] */
			
			if need_to_reload["Buttons"]! {
				principal_view.reload_buttons()
				principal_view.reload_pedals()
			}
			
			if need_to_reload["Socket"]! {
				self.reconnect_socket()
			}
			
			if need_to_reload["Server"]! {
				self.reconnect_server()
			}
			
			break
		case "Cancel":
			break
		default:
			break
		}
	}
	
	func resize_preferences_window(notif: NSNotification?) {
		let label: String = notif!.userInfo!["Label"] as! String
		
		let general_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 400, height: 120))
		let connection_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 500, height: 110))
		//let raspberry_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 350, height: 120))
		let about_tab_view_frame: NSRect = NSRect(origin: default_origin, size: NSSize(width: 400, height: 200))
		
		let frame: NSRect
		
		switch label {
		case "General":
			frame = general_tab_view_frame
			break
		case "Connection":
			frame = connection_tab_view_frame
			break
		//case "Raspberry":
		//	frame = raspberry_tab_view_frame
		//	break
		case "About":
			frame = about_tab_view_frame
			break
		default:
			frame = NSRect(origin: default_origin, size: NSSize(width: 400, height: 140))
			break
		}

		self.preferences_window!.setFrame(frame, display: true, animate: true)
	}
	
	func send_all() {
		var trame: String = "Set_All"
		
		for i in 0..<5 {
			let actions: NSDictionary = self.storage?.document?.objectForKey("Pedals")?.objectForKey("Pedal_\(i)")?.objectForKey("Actions") as! NSDictionary
			let simple: Int = actions.valueForKey("Simple_Press") as! Int
			let double: Int = actions.valueForKey("Double_Press") as! Int
			let long: Int = actions.valueForKey("Long_Press") as! Int
		
			trame = "\(trame) \(simple) \(double) \(long)"
		}
		
		self.socket?.send(trame)
	}
}