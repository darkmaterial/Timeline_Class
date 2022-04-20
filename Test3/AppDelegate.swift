//
//  AppDelegate.swift
//  Test3
//
//  Created by Daniel Zollitsch on 27.09.21.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    
    private var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window = NSWindow(contentRect: NSMakeRect(0, 0, NSScreen.main?.frame.width ?? 100, NSScreen.main?.frame.height ?? 100), // for full height and width of screen
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false)
        window?.title = "A Random App"
        window?.contentMinSize=NSSize(width: 600, height: 500)
        window?.contentViewController = ViewController()
        window?.makeKeyAndOrderFront(nil)
        window?.appearance = NSAppearance(named: .darkAqua)// remove for supporting both

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

