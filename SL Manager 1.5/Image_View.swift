//
//  Image_View.swift
//  SL Manager 1.5
//
//  Created by Belotte on 13/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Image_View: NSView {
	var image: NSImage
	
	init(frame: NSRect, image_name: String) {
		self.image = NSImage(named: image_name)!
		
		super.init(frame: frame)
		
		self.wantsLayer = true
		self.layer!.contents = self.image
	}
	
	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}