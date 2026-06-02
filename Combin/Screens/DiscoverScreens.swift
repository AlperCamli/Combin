//  DiscoverScreens.swift
//  Combin · Journey 5 — Discover
//
//  Editorial catalogue. No prices anywhere — they appear only on the retailer's
//  site, after a deliberate click-out. Ported from screens-discover.jsx.

import SwiftUI

// MARK: - Flow

struct DiscoverFlow: View {
    @Binding var tab: String
    var onCapture: () -> Void

    private enum Page { case home, brand, item, whereToFind }
    @State private var page: Page = .home
    @State private var itemFromBrand = false

    var body: some View {
        ZStack {
            switch page {
            case .home:
                DiscoverHomeView(tab: $tab, onCapture: onCapture,
                                 onBrand: { go(.brand) },
                                 onItem: { itemFromBrand = false; go(.item) })
                    .transition(.opacity)
            case .brand:
                BrandPageView(onBack: { go(.home) },
                              onItem: { itemFromBrand = true; go(.item) })
                    .transition(.move(edge: .trailing))
            case .item, .whereToFind:
                ItemDetailDiscoView(onBack: { go(itemFromBrand ? .brand : .home) },
                                    onWhere: { go(.whereToFind) })
                    .transition(.move(edge: .trailing))
            }
            if page == .whereToFind {
                WhereToFindView(onDismiss: { go(.item) })
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
            }
        }
    }

    private func go(_ p: Page) { withAnimation(.easeInOut(duration: 0.34)) { page = p } }
}

// MARK: - Discover home

private struct DiscoverHomeView: View {
    @Binding var tab: String
    var onCapture: () -> Void
    var onBrand: () -> Void
    var onItem: () -> Void

    private let brands: [(PhotoTone, String, String)] = [
        (.ecru, "Lemaire", "France"), (.olive, "Engineered Garments", "NYC / Tokyo"),
        (.rust, "Bode", "NYC"), (.char, "Margiela", "Paris"),
    ]
    private let movements: [(PhotoTone, String)] = [
        (.cool, "Belgian avant-garde"), (.warm, "American sportswear lineage"),
        (.char, "1990s minimalism"), (.olive, "Lagos new-tailoring"),
    ]
    private let cols = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Discover").serif(22, color: C.ink, tracking: -0.2)
                Spacer()
                Sym(name: "dots", size: 18, color: C.inkSoft)
            }
            .padding(.horizontal, 24).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("A catalogue of fashion we think is worth your attention. Tap Where to find on anything to leave the app and shop.")
                        .sans(13, color: C.inkSoft, lineHeight: 1.55)
                        .padding(.leading, 12)
                        .overlay(alignment: .leading) { Rectangle().fill(C.paperLine).frame(width: 1) }
                        .padding(.horizontal, 24).padding(.top, 14)

                    // hero
                    Button(action: onBrand) {
                        Photo(height: 260, tone: .char, label: "featured · this week")
                            .overlay(alignment: .bottomLeading) {
                                VStack(alignment: .leading, spacing: 4) {
                                    MonoMarker("this week", color: Overlay.paperWhite.opacity(0.75))
                                    Text("Marni · S/S 2026").serif(22, color: Overlay.paperWhite, lineHeight: 1.2)
                                    Text("Risso's tightest collection in three years.")
                                        .sans(12, color: Overlay.paperWhite.opacity(0.85))
                                }
                                .padding(14)
                            }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 24).padding(.top, 14)

                    // brands rail
                    railHeader("brands in rotation").padding(.top, 32)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: 10) {
                            ForEach(Array(brands.enumerated()), id: \.offset) { _, b in
                                Button(action: onBrand) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Photo(width: 130, height: 160, tone: b.0)
                                        Text(b.1).serif(14, color: C.ink).padding(.top, 8)
                                        Text(b.2).sans(11, color: C.inkMute).padding(.top, 1)
                                    }
                                    .frame(width: 130)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.top, 12)

                    // movements grid
                    railHeader("movements & references").padding(.top, 28)
                    LazyVGrid(columns: cols, spacing: 10) {
                        ForEach(Array(movements.enumerated()), id: \.offset) { _, m in
                            Button(action: onItem) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Photo(height: 120, tone: m.0)
                                    Text(m.1).serif(14, color: C.ink, lineHeight: 1.2).padding(.top, 8)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 12)

                    Color.clear.frame(height: 24)
                }
            }

            TabBar(active: "discover", onSelect: { tab = $0 }, onCapture: onCapture)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }

    private func railHeader(_ title: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            MonoMarker(title)
            Spacer()
            Text("See all").sans(11.5, color: C.inkSoft)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Brand page

private struct BrandPageView: View {
    var onBack: () -> Void
    var onItem: () -> Void

    private let items: [(PhotoTone, String)] = [
        (.rust, "Striped knit"), (.ecru, "Camp-collar shirt"), (.cool, "Floor-length skirt"),
        (.olive, "Suede mule"), (.warm, "Bouclé jacket"), (.char, "Wool trouser"),
    ]
    private let cols = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) { Sym(name: "chevron-l", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("brand")
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Marni").serif(32, color: C.ink, tracking: -0.4)
                    Text("Founded 1994 · Italy · Print and craft.").sans(12.5, color: C.inkSoft).padding(.top, 4)
                    Text("Marni was founded by Consuelo Castiglioni in Milan and known for its prints, color, and surface texture. Since 2016, Francesco Risso has continued the house's relationship to craft while loosening its silhouette.")
                        .serif(15.5, color: C.ink, lineHeight: 1.55).padding(.top, 14)
                    HStack(spacing: 6) {
                        Text("Learn about Risso").sans(12, color: C.accent)
                        Sym(name: "chevron-r", size: 12, color: C.accent, stroke: 1.6)
                    }
                    .padding(.top, 12)

                    MonoMarker("S/S 2026 — items").padding(.top, 24).padding(.bottom, 10)
                    LazyVGrid(columns: cols, spacing: 8) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, it in
                            Button(action: onItem) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Photo(height: 170, tone: it.0)
                                    Text(it.1).serif(13, color: C.ink).padding(.top, 6)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Color.clear.frame(height: 24)
                }
                .padding(.horizontal, 24).padding(.top, 14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Item detail (no price)

private struct ItemDetailDiscoView: View {
    var onBack: () -> Void
    var onWhere: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) { Sym(name: "chevron-l", size: 18, color: C.inkSoft, stroke: 1.6).frame(width: 36, height: 36) }
                    .buttonStyle(.plain)
                Spacer()
                MonoMarker("item")
                Spacer()
                Sym(name: "bookmark", size: 16, color: C.inkSoft, stroke: 1.5).frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20).padding(.top, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Photo(height: 360, tone: .rust, label: "striped knit · marni")
                        .padding(.horizontal, 24).padding(.top, 12)

                    VStack(alignment: .leading, spacing: 0) {
                        MonoMarker("Marni · S/S 2026", tracking: 1.3)
                        Text("Striped wool knit").serif(22, color: C.ink, tracking: -0.15).padding(.top, 4)
                        Text("Hand-loomed in Italy. 100% merino. Boatneck, dropped shoulder. Designed by Francesco Risso.")
                            .sans(13, color: C.inkSoft, lineHeight: 1.6).padding(.top, 12)

                        // Where to find (no price)
                        Button(action: onWhere) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Where to find").sans(13.5, color: C.ink)
                                    Text("Prices live on the retailer's site, not here.").sans(11, color: C.inkMute)
                                }
                                Spacer()
                                Sym(name: "chevron-r", size: 16, color: C.inkSoft, stroke: 1.6)
                            }
                            .padding(.init(top: 14, leading: 16, bottom: 14, trailing: 14))
                            .background(C.paperDeep)
                            .clipShape(RoundedRectangle(cornerRadius: R.card))
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 22)

                        VStack(alignment: .leading, spacing: 6) {
                            MonoMarker("read more", color: C.accent)
                            Text("The references in Risso's S/S 2026 collection.")
                                .serif(15, color: C.ink, lineHeight: 1.4)
                        }
                        .padding(.top, 16)
                        .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                        .padding(.top, 18)
                    }
                    .padding(.horizontal, 28)

                    Color.clear.frame(height: 30)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(C.paper.ignoresSafeArea())
        .preferredColorScheme(.light)
    }
}

// MARK: - Where to find (sheet)

private struct WhereToFindView: View {
    var onDismiss: () -> Void

    private let retailers: [(String, String)] = [
        ("Marni — brand direct", "marni.com"), ("Mr Porter", "mrporter.com"),
        ("SSENSE", "ssense.com"), ("Net-a-Porter", "net-a-porter.com"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // dimmed item behind
            VStack {
                Photo(height: 300, tone: .rust).padding(.horizontal, 24).padding(.top, 40)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(0.3)
            .background(C.paper.ignoresSafeArea())
            .onTapGesture(perform: onDismiss)

            VStack(alignment: .leading, spacing: 0) {
                Capsule().fill(C.paperLine).frame(width: 36, height: 4)
                    .frame(maxWidth: .infinity).padding(.bottom, 16)
                MonoMarker("where to find").padding(.bottom, 6)
                Text("Striped wool knit — Marni S/S 2026.").serif(19, color: C.ink, lineHeight: 1.25)

                VStack(spacing: 0) {
                    ForEach(Array(retailers.enumerated()), id: \.offset) { i, d in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(d.0).sans(14, color: C.ink)
                                Text(d.1).mono(11, color: C.inkMute, tracking: 0)
                            }
                            Spacer()
                            Sym(name: "arrow-up", size: 14, color: C.inkSoft, stroke: 1.6)
                        }
                        .padding(.vertical, 14)
                        .overlay(alignment: .top) { Rectangle().fill(C.paperLine).frame(height: 0.5) }
                        .overlay(alignment: .bottom) { if i == retailers.count - 1 { Rectangle().fill(C.paperLine).frame(height: 0.5) } }
                    }
                }
                .padding(.top, 18)

                Text("You'll leave Combin. Prices appear on the retailer's site. We don't follow you back.")
                    .sans(11, color: C.inkMute, lineHeight: 1.5)
                    .padding(.top, 14)
            }
            .padding(.horizontal, 24).padding(.top, 14).padding(.bottom, 30)
            .background(C.paper)
            .clipShape(.rect(topLeadingRadius: R.sheet, topTrailingRadius: R.sheet))
        }
        .preferredColorScheme(.light)
    }
}
