//
//  Toast.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 18/08/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation
import TextAttributes

class Toast {
    private static let windowWidth: CGFloat = 350
    private static let toastWindow: ToastWindow = {
        let w = ToastWindow()
        
        w.opaque = false
        w.hasShadow = false
        w.acceptsMouseMovedEvents = true
        w.styleMask = NSBorderlessWindowMask
        w.level = Int(CGWindowLevelForKey(CGWindowLevelKey.MaximumWindowLevelKey))
        w.backgroundColor = .clearColor()
        
        w.orderFrontRegardless()
        
        let screenRect = NSScreen.screens()!.first!.frame
        let height = NSHeight(screenRect)
        let x = NSWidth(screenRect) / 2 - windowWidth / 2
        
        let rect = NSRect(x: x, y: NSMinY(screenRect), width: windowWidth, height: height)
        w.setFrame(rect, display: true)
        
        return w
    }()
   
    class func show(title: String, message: String? = nil, duration: Double? = 3,
                    actionTitle: String? = nil, action: (() -> ())? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            let panel = ToastPanel(title: title,
                                   message: message,
                                   duration: duration,
                                   actionTitle: actionTitle,
                                   action: action)
            
            toastWindow.add(panel)
        }
    }
    
    private class ToastPanel: NSView {
        private lazy var trackingArea: NSTrackingArea = {
            return NSTrackingArea(rect: NSRect.zero,
                                  options: [.InVisibleRect, .ActiveAlways, .MouseEnteredAndExited],
                                  owner: self,
                                  userInfo: nil)
        }()
        
        private var title: String?
        private var message: String?
        private var duration: Double = 3
        private var actionTitle: String?
        private var action: (() -> ())?
        
        private let buttonWidth: CGFloat = 80
        private var inClick = false
        
        convenience init(title: String, message: String? = nil, duration: Double? = nil,
                         actionTitle: String? = nil, action: (() -> ())? = nil) {
            self.init()
            
            self.title = title
            self.message = message
            
            if let duration = duration {
                self.duration = duration
            } else if let _ = action {
                self.duration = 6
            }
            
            self.actionTitle = actionTitle
            self.action = action
            
            self.layerContentsRedrawPolicy = .OnSetNeedsDisplay
            self.wantsLayer = true
            self.layer?.backgroundColor = NSColor.clearColor().CGColor
            self.layer?.cornerRadius = 10
        }
        
        private override func drawRect(dirtyRect: NSRect) {
            super.drawRect(dirtyRect)
            
            let starting = NSColor(red: 0.9508, green: 0.9507, blue: 0.9507, alpha: 1.0)
            let ending = NSColor(red: 0.7928, green: 0.7928, blue: 0.7928, alpha: 1.0)
            let gradient = NSGradient(startingColor: starting, endingColor: ending)
            gradient?.drawInRect(dirtyRect, angle: 270)
            
            var titleFrame = NSRect(x: 20, y: NSHeight(dirtyRect) - 30,
                                    width: NSWidth(dirtyRect) - 40, height: 20)
            var messageFrame = NSRect(x: 20, y: NSMinY(titleFrame) - 40,
                                    width: NSWidth(dirtyRect) - 40, height: 40)
            
            if let actionTitle = actionTitle {
                var line = NSBezierPath()
                line.moveToPoint(NSPoint(x: NSWidth(dirtyRect) - buttonWidth, y: NSMinX(dirtyRect)))
                line.lineToPoint(NSPoint(x: NSWidth(dirtyRect) - buttonWidth, y: NSMaxX(dirtyRect)))
                line.lineWidth = 1.0
                NSColor.whiteColor().set()
                line.stroke()
                
                line = NSBezierPath()
                line.moveToPoint(NSPoint(x: NSWidth(dirtyRect) - buttonWidth - 2,
                    y: NSMinX(dirtyRect)))
                line.lineToPoint(NSPoint(x: NSWidth(dirtyRect) - buttonWidth - 2,
                    y: NSMaxX(dirtyRect)))
                line.lineWidth = 1.0
                NSColor(red: 0.1647, green: 0.1647, blue: 0.1647, alpha: 1.0).set()
                line.stroke()

                let actionFrame = NSRect(x: NSWidth(dirtyRect) - buttonWidth + 2,
                                         y: NSMidY(dirtyRect) - 15,
                                         width: buttonWidth - 4, height: 20)
                let attributes = TextAttributes()
                    .font(NSFont(name: "ChunkFive", size: 14))
                    .foregroundColor(.blackColor())
                    .alignment(.Center)
                NSAttributedString(string: actionTitle, attributes: attributes)
                    .drawInRect(actionFrame)
                
                titleFrame.size.width -= buttonWidth + 2
                messageFrame.size.width -= buttonWidth + 2
            }
            if let title = title {
                let attributes = TextAttributes()
                    .font(NSFont(name: "ChunkFive", size: 16))
                    .foregroundColor(.blackColor())
                NSAttributedString(string: title, attributes: attributes)
                    .drawInRect(titleFrame)
            }
            if let message = message {
                let attributes = TextAttributes()
                    .font(NSFont(name: "ChunkFive", size: 14))
                    .foregroundColor(.blackColor())
                NSAttributedString(string: message, attributes: attributes)
                    .drawInRect(messageFrame)
            }
        }
        
        func remove() {
            NSAnimationContext.beginGrouping()
            NSAnimationContext.currentContext().completionHandler = { [weak self] in
                self?.removeFromSuperview()
            }
            NSAnimationContext.currentContext().duration = 1.2
            
            animator().alphaValue = 0
            
            NSAnimationContext.endGrouping()
        }
        
        // MARK: - mouse hover
        override func updateTrackingAreas() {
            super.updateTrackingAreas()
            
            if !self.trackingAreas.contains(trackingArea) {
                self.addTrackingArea(trackingArea)
            }
        }
        
        private var actionFrame: NSRect {
            return NSRect(x: NSWidth(bounds) - buttonWidth + 2,
                                     y: NSMinY(bounds),
                                     width: buttonWidth - 4,
                                     height: NSHeight(bounds))
        }
        
        private override func mouseDown(event: NSEvent) {
            guard let _ = self.action else { return }
            
            let point = convertPoint(event.locationInWindow, fromView: nil)
            guard actionFrame.contains(point) else { return }
            inClick = true
        }
        private override func mouseUp(event: NSEvent) {
            guard let _ = self.action else { return }
            guard inClick else { return }
            
            let point = convertPoint(event.locationInWindow, fromView: nil)
            guard actionFrame.contains(point) else { return }
            inClick = false
            action?()
            toastWindow.remove(self)
        }
    }
    
    private class ToastWindow: NSWindow {
        private var panels: [ToastPanel] = []
        
        func add(panel: ToastPanel) {
            if let contentView = self.contentView {
                let y = NSMaxY(contentView.frame)
                panel.frame = NSRect(x: 0, y: y, width: windowWidth, height: 70)
                contentView.addSubview(panel)
                panels.append(panel)
                
                var when = dispatch_time(DISPATCH_TIME_NOW, Int64(500 * Double(NSEC_PER_MSEC)))
                let queue = dispatch_get_main_queue()
                dispatch_after(when, queue) { [weak self] in
                    self?.refresh()
                }
                
                when = dispatch_time(DISPATCH_TIME_NOW,
                                     Int64((0.5 + panel.duration) * Double(NSEC_PER_SEC)))
                dispatch_after(when, queue) { [weak self] in
                    self?.remove(panel)
                }
            }
        }
        
        func remove(panel: ToastPanel) {
            panel.remove()
            panels.remove(panel)
        }
        
        private func refresh() {
            NSAnimationContext.beginGrouping()
            NSAnimationContext.currentContext().duration = 0.8
            
            var y: CGFloat = NSMaxY(contentView!.frame)
            panels.reverse().forEach {
                y -= 80
                let newOrigin = NSPoint(x: 0, y: y)
                $0.animator().setFrameOrigin(newOrigin)
            }
            
            NSAnimationContext.endGrouping()
        }
    }
}