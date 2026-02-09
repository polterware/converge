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
    var isFullScreen: Bool = false

    var body: some View {
        ZStack {
            if isFullScreen {
                Color(nsColor: NSColor(white: 0.15, alpha: 1))
            } else {
                VisualEffectView(material: material, blendingMode: .behindWindow)
            }
            tint.opacity(tintOpacity)
        }
        .ignoresSafeArea()
    }
}

struct ToolbarBackgroundHider: NSViewRepresentable {
    var isFullScreen: Bool

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            apply(from: view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.apply(from: nsView)
        }
    }

    private func apply(from view: NSView) {
        guard let window = view.window,
              let themeFrame = window.contentView?.superview else { return }

        for child in themeFrame.subviews {
            let name = String(describing: type(of: child))
            if name.contains("Titlebar") {
                setEffectViewsAlpha(in: child, alpha: isFullScreen ? 0 : 1)
            }
        }
    }

    private func setEffectViewsAlpha(in view: NSView, alpha: CGFloat) {
        let name = String(describing: type(of: view))
        if name.contains("NSToolbarView") { return }

        if view is NSVisualEffectView {
            view.alphaValue = alpha
        }
        for child in view.subviews {
            setEffectViewsAlpha(in: child, alpha: alpha)
        }
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
                window.titlebarSeparatorStyle = .none
                window.isMovableByWindowBackground = true
            }
        )
    }
}
