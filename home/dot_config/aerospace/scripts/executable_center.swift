#!/usr/bin/swift
import AppKit

// Define your target width
let desiredWidth: CGFloat = 1500
let desiredHeight: CGFloat = 900 // Customize your preferred height

if let screen = NSScreen.main {
    let screenFrame = screen.visibleFrame
    let newX = screenFrame.origin.x + (screenFrame.width - desiredWidth) / 2
    let newY = screenFrame.origin.y + (screenFrame.height - desiredHeight) / 2
    
    // Commands sent to AeroSpace CLI to make it float and resize
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", "aerospace layout floating && aerospace resize smart \(Int(desiredWidth)) \(Int(desiredHeight))"]
    try? process.run()
}

