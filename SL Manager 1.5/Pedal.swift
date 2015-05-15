//
//  Pedal.swift
//  SL Manager 1.5
//
//  Created by Belotte on 06/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Pedal: NSView {
	let size: NSSize = NSSize(width: 60, height: 96)
	let background_image: NSImage = NSImage(named: "Pedal.png")!
	
	let target: Principal_View
	let action: Selector
	
	var id: Int
	var name: String
	
	let id_label: Id_Label
	let on_off_image: On_Off_Image
	let pedal_button: Pedal_Button
	
	init(target: Principal_View, action: Selector, id: Int, use_color: Bool) {
		self.target = target
		self.action = action
		
		self.id_label = Id_Label(id: id, color: colors[id], use_colors: use_color)
		self.on_off_image = On_Off_Image(id: id)
		self.pedal_button = Pedal_Button(target: target, action: action, id: id)
		
		self.id = id
		self.name = "Pedal_\(id)"
		
		let origin: NSPoint = NSPoint(x: 10 + id * (10 + Int(self.size.width)), y: 174)
		let size: NSSize = NSSize(width: self.size.width, height: self.size.height)
		
		super.init(frame: NSRect(origin: origin, size: size))
		
		self.wantsLayer = true
		self.layer!.contents = self.background_image
		
		self.addSubview(self.id_label)
		self.addSubview(self.on_off_image)
		self.addSubview(self.pedal_button)
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	func use_color() {
		self.id_label.use_color()
	}
	
	func remove_color() {
		self.id_label.remove_color()
	}
}