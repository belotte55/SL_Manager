//
//  Server.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

public class Server: NSObject {
	/**
		Get configured ip. (read-only)
	*/
	public let ip: String

	/**
		Get configured port. (read-only)
	*/
	public let port: Int
	
	/**
		State of the server. (read-only)
	*/
	public private(set) var is_running: Bool = true
	
	public let delegate: AnyObject
	var server: UDPServer?
	
	public private(set) var selector: Selector = "trame_received:"
	
	/**
		Init the server..
	
		If the server receive something, it'll send a notification to the "trame_received:" method of delegate, if it exist.
		
		The notification's userInfo contains:
		
		- ["trame"]
		
		- ["remote_ip"]
		
		- ["remote_port"]
		
		:param: delegate Object which will receive notification
		:param: ip Set ip of connection.
		:param: port Set port of connection.
	*/
	public init(delegate: AnyObject, ip: String, port: Int) {
		self.ip = ip
		self.port = port
		
		self.delegate = delegate
	
		super.init()
		
		/* Add observer to delegate */
		NSNotificationCenter.defaultCenter().addObserver(self.delegate, selector: "trame_received:", name: "trame_received", object: nil)
		
		self.run()
	}
	
	func run() {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
			self.server = UDPServer(addr: self.ip, port: self.port)
			
			println("Server is running on \(self.ip):\(self.port)")
			
			while self.is_running {
				var (d, remote_ip, remote_port) = self.server!.recv(1024)
				if let data = d {
					if let trame = String(bytes: data, encoding: NSUTF8StringEncoding) {
						if self.delegate.respondsToSelector(self.selector) {
							NSNotificationCenter.defaultCenter().postNotificationName("trame_received", object: nil, userInfo: ["trame": trame, "remote_ip": remote_ip, "remote_port": remote_port])
						}
					}
				}
			}
		})
	}
	
	/**
		Stop the server.
	
		If it's stop, it can't be restarted.
	*/
	public func stop() {
		self.server = nil
		self.is_running = false
	}
	
	/**
		Change selector.
	
		:param: selector The new selector.
	*/
	public func set_selector(selector: Selector) {
		self.selector = selector
		
		NSNotificationCenter.defaultCenter().removeObserver(self.delegate, name: "trame_received", object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self.delegate, selector: self.selector, name: "trame_received", object: nil)
	}
}