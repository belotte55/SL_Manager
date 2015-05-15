//
//  Socket.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Socket {
	var socket: GCDAsyncUdpSocket
	
	var ip: String
	var port: Int
	
	var log_file: Log_File?
	
	var error: NSError?
	
	let delegate: App_Delegate
	
	init?(delegate parent: App_Delegate, ip: String, port: Int) {
		self.delegate = parent
		
		self.socket = GCDAsyncUdpSocket(delegate: parent, delegateQueue: dispatch_get_main_queue())
		
		self.log_file = (NSApplication.sharedApplication().delegate as! App_Delegate).log_file
		
		self.ip = ip
		self.port = port
		
		if !self.connect_to(self.ip, port: self.port) {
			return nil
		}
	}
	
	func connect_to(ip: String, port: Int) -> Bool {
		self.close()
		
		self.ip = ip
		self.port = port
		
		if self.socket.connectToHost(self.ip, onPort: UInt16(self.port), error: &error) {
			log("Connected to \(self.ip):\(self.port).")
			let server_port: Int = (NSApplication.sharedApplication().delegate as! App_Delegate).storage!.get_port_server()
			self.send("Connection \(server_port + 1)")
			
			return true
		} else {
			log("Socket error: \(error!)")
			log("Please check your network connection.")
			
			return false
		}
	}
	
	func send(data: String) {
		self.socket.sendData(data.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), withTimeout: 2, tag: 1)
	}
	
	func close() {
		self.socket.close()
	}
}