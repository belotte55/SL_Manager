//
//  main.swift
//  SL Manager 1.5
//
//  Created by Belotte on 04/04/2015.
//  Copyright (c) 2015 Belotte. All rights reserved.
//

import Cocoa

/* Instancie l'application */
let application: NSApplication = NSApplication.sharedApplication()
/* Instancie le delegate */
let delegate: App_Delegate = App_Delegate()

/* Associe le delegate à l'application */
application.delegate = delegate
/* Lance l'application */
application.run()