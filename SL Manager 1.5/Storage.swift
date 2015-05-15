//
//  Storage.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Storage {
	
	/* User's Documents directory */
	let document_directory: String = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray)[0] as! String
	
	let bundle_file_name: String
	
	var file_name: String
	var file_path: String
	var dir_path: String
	
	var document: NSDictionary?
	
	var log_file: Log_File?
	
	let file_manager: NSFileManager = NSFileManager.defaultManager()
	
	var error: NSError?
	
	/* Inits */
	init?(bundle_file_name: String, file_name: String, directory_path: String) {
		self.bundle_file_name = bundle_file_name
		
		self.file_name = file_name
		self.file_path = directory_path.stringByAppendingPathComponent(file_name)
		self.dir_path = directory_path
		
		if !self.initialize() {
			return nil
		}
	}
	
	init?(bundle_file_name: String, file_name: String, directory_name: String) {
		self.bundle_file_name = bundle_file_name
		
		self.file_name = file_name
		self.file_path = self.document_directory.stringByAppendingPathComponent(directory_name).stringByAppendingPathComponent(file_name)
		self.dir_path = self.file_path.stringByDeletingLastPathComponent
		
		if !self.initialize() {
			return nil
		}
	}
	
	init?(bundle_file_name: String, file_name: String) {
		self.bundle_file_name = bundle_file_name
		
		self.file_name = file_name
		self.file_path = self.document_directory.stringByAppendingPathComponent(file_name)
		self.dir_path = self.file_path.stringByDeletingLastPathComponent
		
		if !self.initialize() {
			return nil
		}
	}
	
	init?(bundle_file_name: String, file_path: String) {
		self.bundle_file_name = bundle_file_name
		
		self.file_name = file_path.lastPathComponent
		self.file_path = file_path
		self.dir_path = file_path.stringByDeletingLastPathComponent
		
		if !self.initialize() {
			return nil
		}
		
//		let attributes: NSDictionary = self.file_manager.attributesOfItemAtPath(self.file_path, error: nil)!
//		println("\(attributes.fileModificationDate())")
	}
	/* End Inits */
	
	func copy() -> Storage? {
		return Storage(bundle_file_name: self.bundle_file_name, file_path: self.file_path)
	}
	
	func initialize() -> Bool {
		self.log_file = (NSApplication.sharedApplication().delegate as! App_Delegate).log_file
		
		/* Check if directory exist */
		if !is_file_exist(self.dir_path) {
			if !self.file_manager.createDirectoryAtPath(self.dir_path, withIntermediateDirectories: true, attributes: nil, error: &error) {
				let alert: NSAlert = NSAlert()
				
				log("Error: \(error)")
				
				alert.informativeText = "Unable to create \(self.dir_path)."
				alert.messageText = "Error !"
				alert.runModal()
				
				return false
			} else {
				log("\(self.file_path) created.")
			}
		}
		
		/* Check if file exist */
		if !is_file_exist(self.file_path) {
			let alert: NSAlert = NSAlert()
			
			if let bundle_file_path: String = NSBundle.mainBundle().pathForResource(self.bundle_file_name, ofType: nil) {
				let data: NSData = NSData(contentsOfFile: bundle_file_path)!
			
				if !self.file_manager.createFileAtPath(self.file_path, contents: data, attributes: nil) {
					log("Unable to create \(self.file_path).")
					
					alert.informativeText = "Unable to create \(self.file_path)."
					alert.messageText = "Error !"
					alert.runModal()
					
					return false
				} else {
					log("Data file created at \(self.file_path).")
					
					alert.informativeText = "Data file created at \(self.file_path)."
					alert.messageText = "No preferences file found."
					alert.runModal()
				}
			} else {
				log("Unable to found \(self.bundle_file_name) in bundle.")
				
				alert.informativeText = "Unable to found \(self.bundle_file_name) in bundle."
				alert.messageText = "Error !"
				alert.runModal()
				
				return false
			}
		}
		
		self.document = NSDictionary(contentsOfFile: self.file_path)
		
		return true
	}
	
	func is_file_exist(file_name: String) -> Bool {
		return self.file_manager.fileExistsAtPath(file_name)
	}
	
	func get_document() -> NSDictionary {
		return NSDictionary(contentsOfFile: self.file_path)!
	}
	
	func get_document_from(path: String) -> NSDictionary? {
		return NSDictionary(contentsOfFile: path)
	}
	
	func write_document() -> Bool {
		return self.document!.writeToFile(self.file_path, atomically: true)
	}
	
	func write_document_to(path: String) -> Bool {
		if !is_file_exist(path) {
			if !self.file_manager.createDirectoryAtPath(path.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil, error: &self.error) {
				log("Error: \(self.error)")

				return false
			}
			
			if !self.file_manager.createFileAtPath(path, contents: nil, attributes: nil) {
				log("Failed to create \(path)")
				
				return false
			}
			
			self.document!.writeToFile(path, atomically: true)
		}
		
		return true
	}
	
	func reload_document() -> Bool {
		if let document: NSDictionary = NSDictionary(contentsOfFile: self.file_path) {
			self.document = document
			
			return true
		}
		
		return false
	}
	
	/* Specific to SL Manager */
	func get_actions_for_pedal(pedal_id: Int) -> [Int] {
		let pedal: NSDictionary = self.document!["Pedals"]!["Pedal_\(pedal_id)"]! as! NSDictionary
		let actions: NSDictionary = pedal["Actions"]!as! NSDictionary
		var array_to_return: [Int] = []
		
		array_to_return.append(actions["Simple_Press"] as! Int)
		array_to_return.append(actions["Double_Press"] as! Int)
		array_to_return.append(actions["Long_Press"] as! Int)
		
		return array_to_return
	}
	
	func get_actions_for_pedal(pedal_name: String) -> [Int] {
		let pedal: NSDictionary = self.document!["Pedals"]!["\(pedal_name)"] as! NSDictionary
		let actions: NSDictionary = pedal["Actions"]! as! NSDictionary
		var array_to_return: [Int] = []
		
		array_to_return.append(actions["Simple_Press"] as! Int)
		array_to_return.append(actions["Double_Press"] as! Int)
		array_to_return.append(actions["Long_Press"] as! Int)
		
		return array_to_return
	}
	
	func set_simple_action_for_pedal(pedal_name: String, action: Int) {
		self.document!["Pedals"]![pedal_name]!?.setValue(action, forKey: "Simple_Press")
	}
	
	func set_double_action_for_pedal(pedal_name: String, action: Int) {
		self.document!["Pedals"]![pedal_name]!?.setValue(action, forKey: "Double_Press")
	}
	
	func set_long_action_for_pedal(pedal_name: String, action: Int) {
		self.document!["Pedals"]![pedal_name]!?.setValue(action, forKey: "Long_Press")
	}
	
	func get_ip_server() -> String {
		return self.document!["Connection"]!["IP_Server"]! as! String
	}
	
	func get_port_server() -> Int {
		return self.document!["Connection"]!["Port_Server"]! as! Int
	}
	
	func get_ip_client() -> String {
		return self.document!["Connection"]!["IP_Client"]! as! String
	}
	
	func get_port_client() -> Int {
		return (self.document!["Connection"]!["Port_Client"] as! String).toInt()!
	}
	
	func set_ip_server(ip: String) {
		self.document!["Connection"]!.setValue(ip, forKey: "IP_Server")
	}
	
	func set_port_server(port: Int) {
		self.document!["Connection"]!.setValue(port, forKey: "Port_Server")
	}
	
	func set_ip_client(ip: String) {
		self.document!["Connection"]!.setValue(ip, forKey: "IP_Client")
	}
	
	func set_port_client(port: String) {
		self.document!["Connection"]!.setValue("\(port)", forKey: "Port_Client")
	}
}