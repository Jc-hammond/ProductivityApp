//
//  DesignSystem.swift
//  ProductivityApp
//
//  Design System - The foundation of visual excellence
//

import SwiftUI

// MARK: - Colors

enum AppColors {
    // MARK: Brand Colors
    static let accent = Color("AccentBlue")

    // MARK: Status Colors (Richer, more saturated)
    enum Status {
        static let todo = Color(nsColor: .systemGray)
        static let todoSubtle = Color(nsColor: .systemGray).opacity(0.15)

        static let inProgress = Color(nsColor: .systemBlue)
        static let inProgressSubtle = Color(nsColor: .systemBlue).opacity(0.15)

        static let done = Color(nsColor: .systemGreen)
        static let doneSubtle = Color(nsColor: .systemGreen).opacity(0.15)

        static let overdue = Color(nsColor: .systemRed)
        static let overdueSubtle = Color(nsColor: .systemRed).opacity(0.15)
    }

    // MARK: UI Colors
    enum Surface {
        static let primary = Color(nsColor: .windowBackgroundColor)
        static let secondary = Color(nsColor: .controlBackgroundColor)
        static let tertiary = Color(nsColor: .tertiarySystemFill)

        // Card backgrounds with subtle tinting
        static let card = Color(nsColor: .controlBackgroundColor)
        static let cardHover = Color.primary.opacity(0.05)
        static let cardSelected = Color.primary.opacity(0.08)
    }

    enum Text {
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let tertiary = Color(nsColor: .tertiaryLabelColor)
        static let placeholder = Color(nsColor: .placeholderTextColor)
    }

    enum Border {
        static let subtle = Color.primary.opacity(0.06)
        static let medium = Color.primary.opacity(0.1)
        static let strong = Color.primary.opacity(0.2)
        static let divider = Color(nsColor: .separatorColor)
    }

    // MARK: Semantic Colors
    enum Success {
        static let fill = Color.green
        static let background = Color.green.opacity(0.12)
        static let border = Color.green.opacity(0.3)
    }

    enum Warning {
        static let fill = Color.orange
        static let background = Color.orange.opacity(0.12)
        static let border = Color.orange.opacity(0.3)
    }

    enum Error {
        static let fill = Color.red
        static let background = Color.red.opacity(0.12)
        static let border = Color.red.opacity(0.3)
    }
}

// MARK: - Typography

enum AppTypography {
    // MARK: Font Styles

    /// Large page titles - 28pt, bold
    static let largeTitle = Font.system(size: 28, weight: .bold)

    /// Page titles - 24pt, semibold
    static let title = Font.system(size: 24, weight: .semibold)

    /// Section headers - 17pt, semibold
    static let headline = Font.system(size: 17, weight: .semibold)

    /// Prominent text - 16pt, medium
    static let subheadline = Font.system(size: 16, weight: .medium)

    /// Body text - 15pt, regular
    static let body = Font.system(size: 15, weight: .regular)

    /// Body text emphasized - 15pt, medium
    static let bodyEmphasis = Font.system(size: 15, weight: .medium)

    /// Secondary text - 13pt, regular
    static let callout = Font.system(size: 13, weight: .regular)

    /// Secondary text emphasized - 13pt, medium
    static let calloutEmphasis = Font.system(size: 13, weight: .medium)

    /// Small labels - 12pt, regular
    static let caption = Font.system(size: 12, weight: .regular)

    /// Small labels emphasized - 12pt, medium
    static let captionEmphasis = Font.system(size: 12, weight: .medium)

    /// Tiny text - 11pt, regular
    static let footnote = Font.system(size: 11, weight: .regular)

    /// Tiny text emphasized - 11pt, medium
    static let footnoteEmphasis = Font.system(size: 11, weight: .medium)

    /// Extra large composer input - 20pt, medium
    static let composerInput = Font.system(size: 20, weight: .medium)
}

// MARK: - Spacing

enum AppSpacing {
    /// 4pt - Tight spacing within small components
    static let xs: CGFloat = 4

    /// 8pt - Standard spacing between related elements
    static let sm: CGFloat = 8

    /// 12pt - Medium spacing, card padding
    static let md: CGFloat = 12

    /// 16pt - Standard component padding
    static let lg: CGFloat = 16

    /// 20pt - Generous padding
    static let xl: CGFloat = 20

    /// 24pt - Section spacing
    static let xxl: CGFloat = 24

    /// 32pt - Large section gaps
    static let xxxl: CGFloat = 32

    /// 48pt - Page margins
    static let huge: CGFloat = 48

    /// 64pt - Extra large spacing
    static let massive: CGFloat = 64
}

// MARK: - Corner Radius

enum AppRadius {
    /// 6pt - Small elements (chips, badges)
    static let sm: CGFloat = 6

    /// 8pt - Standard cards
    static let md: CGFloat = 8

    /// 10pt - Medium cards
    static let lg: CGFloat = 10

    /// 12pt - Large cards and sections
    static let xl: CGFloat = 12

    /// 16pt - Extra large cards
    static let xxl: CGFloat = 16
}

// MARK: - Shadows

enum AppShadow {
    /// Subtle card elevation
    static let card = ShadowStyle(
        color: Color.black.opacity(0.06),
        radius: 8,
        x: 0,
        y: 2
    )

    /// Medium elevation for hover states
    static let cardHover = ShadowStyle(
        color: Color.black.opacity(0.1),
        radius: 12,
        x: 0,
        y: 4
    )

    /// Strong elevation for modals and toasts
    static let elevated = ShadowStyle(
        color: Color.black.opacity(0.15),
        radius: 16,
        x: 0,
        y: 8
    )

    /// Dramatic shadow for drag and drop
    static let dramatic = ShadowStyle(
        color: Color.black.opacity(0.2),
        radius: 24,
        x: 0,
        y: 12
    )

    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }
}

// MARK: - Enhanced Animations

extension AppAnimation {
    /// Bouncy spring for delightful interactions
    static let springBouncy = Animation.spring(response: 0.35, dampingFraction: 0.7)

    /// Gentle spring for subtle movements
    static let springGentle = Animation.spring(response: 0.5, dampingFraction: 0.9)

    /// Smooth ease for opacity changes
    static let fadeIn = Animation.easeIn(duration: 0.2)
    static let fadeOut = Animation.easeOut(duration: 0.15)
}

// MARK: - View Extensions

extension View {
    /// Apply a card style with shadow
    func cardStyle(isHovered: Bool = false) -> some View {
        let shadow = isHovered ? AppShadow.cardHover : AppShadow.card
        return self
            .background(AppColors.Surface.card)
            .cornerRadius(AppRadius.md)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Apply an elevated card style (for modals, popovers)
    func elevatedCardStyle() -> some View {
        let shadow = AppShadow.elevated
        return self
            .background(AppColors.Surface.card)
            .cornerRadius(AppRadius.xl)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Apply consistent padding
    func cardPadding() -> some View {
        self.padding(AppSpacing.lg)
    }

    /// Apply section spacing
    func sectionSpacing() -> some View {
        self.padding(.vertical, AppSpacing.xxl)
    }
}
