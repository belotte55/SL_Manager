//
//  Log_File.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Log_File {
	let document_directory: String = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as NSArray)[0] as! String
	
	let file_name: String
	let file_path: String
	let dir_path: String
	
	var file: NSFileHandle? = nil
	let date_format: NSDateFormatter = NSDateFormatter()
	
	let file_manager: NSFileManager = NSFileManager.defaultManager()
	
	var error: NSError?
	
	init?(file_path: String) {
		self.file_name = file_path.lastPathComponent
		self.file_path = file_path
		self.dir_path = file_path.stringByDeletingLastPathComponent
		
		if !self.initialize() {
			return nil
		}
		
		if let file: NSFileHandle = NSFileHandle(forWritingAtPath: self.file_path) {
			self.file = file
		} else {
			return nil
		}
	}
	
	init?(file_name: String, dir_name: String) {
		self.file_name = file_name
		self.file_path = self.document_directory.stringByAppendingPathComponent(dir_name).stringByAppendingPathComponent(file_name)
		self.dir_path = self.file_path.stringByDeletingLastPathComponent
		
		if !self.initialize() {
			return nil
		}
		
		if let file: NSFileHandle = NSFileHandle(forWritingAtPath: self.file_path) {
			self.file = file
		} else {
			return nil
		}
	}
	
	init?(file_name: String, dir_path: String) {
		self.file_name = file_name
		self.file_path = dir_path.stringByAppendingPathComponent(file_name)
		self.dir_path = dir_path
		
		if !self.initialize() {
			return nil
		}
		
		if let file: NSFileHandle = NSFileHandle(forWritingAtPath: self.file_path) {
			self.file = file
		} else {
			return nil
		}
	}
	
	func initialize() -> Bool {
		self.date_format.dateFormat = "dd-MM-yy HH:mm:ss.SSS"
		
		if !is_file_exist(self.dir_path) {
			if !self.file_manager.createDirectoryAtPath(self.dir_path, withIntermediateDirectories: true, attributes: nil, error: &error) {
				let alert: NSAlert = NSAlert()
				
				println("Unable to create \(self.dir_path) for logs.")
				
				alert.informativeText = "Unable to create log directory."
				alert.messageText = "Error !"
				alert.runModal()
				
				return false
			}
		}
		
		if !is_file_exist(self.file_path) {
			if !self.file_manager.createFileAtPath(self.file_path, contents: nil, attributes: nil) {
				let alert: NSAlert = NSAlert()
				
				println("Unable to create \(self.file_path) for logs.")
				
				alert.informativeText = "Unable to create log file."
				alert.messageText = "Error !"
				alert.runModal()
				
				return false
			}
		}
		
		return true
	}
	
	func is_file_exist(file_name: String) -> Bool {
		return self.file_manager.fileExistsAtPath(file_name)
	}
	
	func log(data: String) {
		let new_data: NSData = "\(self.date_format.stringFromDate(NSDate())) - \(data)\n".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!

		self.file!.seekToEndOfFile()
		self.file!.writeData(new_data)
		
		println("\(data)")
	}
	
	func clear() {
		self.file_manager.removeItemAtPath(self.file_path, error: &error)
		self.file_manager.createFileAtPath(self.file_path, contents: nil, attributes: nil)
	}
}