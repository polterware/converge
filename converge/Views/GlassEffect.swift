//
//  GlassEffect.swift
//  converge
//

import SwiftUI
import AppKit

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State = .active

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}

struct WindowConfigurator: NSViewRepresentable {
    let configure: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                configure(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                configure(window)
            }
        }
    }
}

struct GlassBackground: View {
    let tint: Color
    var material: NSVisualEffectView.Material = .hudWindow
    var tintOpacity: Double = 0.35

    var body: some View {
        ZStack {
            VisualEffectView(material: material, blendingMode: .behindWindow)
            tint.opacity(tintOpacity)
        }
        .ignoresSafeArea()
    }
}

extension View {
    func glassWindow() -> some View {
        background(
            WindowConfigurator { window in
                if window.isOpaque {
                    window.isOpaque = false
                }
                if window.backgroundColor != .clear {
                    window.backgroundColor = .clear
                }
                window.titlebarAppearsTransparent = true
                window.isMovableByWindowBackground = true
            }
        )
    }
}
