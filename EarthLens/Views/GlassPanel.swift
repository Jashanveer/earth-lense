import SwiftUI

struct GlassPanel<Content: View>: View {
    private let padding: CGFloat
    @ViewBuilder private let content: Content

    init(padding: CGFloat = 22, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .glassEffect(in: .rect(cornerRadius: 30))
    }
}


