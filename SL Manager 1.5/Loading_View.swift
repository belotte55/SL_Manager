//
//  Loading_View.swift
//  SL Manager 1.5
//
//  Created by Belotte on 13/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

class Loading_View: NSView {
	let image_view: Image_View = Image_View(frame: NSRect(x: 200, y: 0, width: 280, height: 280), image_name: "logo x512.png")
	
	init(frame: NSRect, delegate: App_Delegate) {
		super.init(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
	
		self.addSubview(self.image_view)
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
}

/* ScrollView */

//		let size: NSSize = self.contentSize
//
//		self.borderType = .NoBorder
//		self.hasVerticalScroller = true
//		self.hasHorizontalScroller = false
//		self.autoresizingMask = .ViewHeightSizable// | .ViewWidthSizable
//
//
//		self.allowsMagnification = true
//		self.documentView = self.image_view
//		self.contentView = self.image_view
//		self.contentSize = NSRect()
//		self.contentSize = image_view.bounds.size