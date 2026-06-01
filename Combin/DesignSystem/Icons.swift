//  Icons.swift
//  Combin
//
//  `Sym` mirrors the prototype's primitives.jsx <Sym/> helper. The prototype
//  hand-drew "SF Symbol-like" line SVGs as a web stand-in; the design brief's
//  non-negotiable #7 calls for real SF Symbols with aligned line weight, so in
//  the native target we map each name to the closest SF Symbol. Names are kept
//  identical to the handoff so screen code reads the same.

import SwiftUI

struct Sym: View {
    var name: String
    var size: CGFloat = 20
    var color: Color = .primary
    /// Stroke weight from the prototype (1.4 thin … 2.0 bold), mapped to a
    /// matching SF Symbol font weight.
    var stroke: CGFloat = 1.6

    var body: some View {
        Image(systemName: Self.symbol(for: name))
            .font(.system(size: size * 0.9, weight: Self.weight(forStroke: stroke)))
            .foregroundStyle(color)
            .symbolRenderingMode(.monochrome)
    }

    private static func weight(forStroke s: CGFloat) -> Font.Weight {
        switch s {
        case ..<1.45:        return .light
        case 1.45..<1.7:     return .regular
        case 1.7..<1.95:     return .medium
        default:             return .semibold
        }
    }

    static func symbol(for name: String) -> String {
        switch name {
        case "lock":        return "lock"
        case "shield":      return "shield"
        case "eye-slash":   return "eye.slash"
        case "trash":       return "trash"
        case "no-ad":       return "nosign"
        case "camera":      return "camera"
        case "photo":       return "photo"
        case "hanger":      return "tshirt"
        case "compass":     return "safari"
        case "book":        return "book"
        case "arrow-up":    return "arrow.up"
        case "chevron-r":   return "chevron.right"
        case "chevron-l":   return "chevron.left"
        case "chevron-d":   return "chevron.down"
        case "x":           return "xmark"
        case "check":       return "checkmark"
        case "bookmark":    return "bookmark"
        case "share":       return "square.and.arrow.up"
        case "sun-cloud":   return "cloud.sun"
        case "bell":        return "bell"
        case "flip":        return "arrow.triangle.2.circlepath"
        case "gallery-sm":  return "photo.on.rectangle"
        case "plus":        return "plus"
        case "dots":        return "ellipsis"
        case "queue":       return "clock"
        case "briefcase":   return "briefcase"
        case "glass":       return "fork.knife"   // Dinner occasion
        case "sparkle":     return "party.popper"  // Party occasion (never the AI ✨)
        case "tree":        return "leaf"          // Casual occasion
        case "plane":       return "airplane"
        case "heart":       return "heart"
        case "pencil":      return "pencil"
        case "sun":         return "sun.max"
        case "cloud":       return "cloud"
        case "rain":        return "cloud.rain"
        case "snow":        return "cloud.snow"
        case "wind":        return "wind"
        case "pin":         return "mappin"
        default:            return "circle"
        }
    }
}
