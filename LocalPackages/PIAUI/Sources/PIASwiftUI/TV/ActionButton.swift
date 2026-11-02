//
//  ActionButton.swift
//  PIASwiftUI
//
//  Created by Said Rehouni on 9/2/24.
//  Copyright © 2024 Private Internet Access Inc. All rights reserved.
//

#if os(tvOS)
    import PIADesignSystem
    import SwiftUI

    public struct ActionButtonStyle {
        public var focusedColor: Color
        public var focusedTitleColor: Color
        public var unfocusedColor: Color
        public var unfocusedTitleColor: Color
        public var titleAlignment: Alignment
        public var titlePadding: EdgeInsets
        public var titleFont: Font

        public init(
            focusedColor: Color = Color.pia.primary,
            focusedTitleColor: Color = Color.pia.onPrimary,
            unfocusedColor: Color = Color.pia.surfaceContainerSecondary,
            unfocusedTitleColor: Color = Color.pia.onSurface,
            titleAlignment: Alignment = .center,
            titlePadding: EdgeInsets = EdgeInsets(),
            titleFont: Font = .system(size: 38)
        ) {
            self.focusedColor = focusedColor
            self.focusedTitleColor = focusedTitleColor
            self.unfocusedColor = unfocusedColor
            self.unfocusedTitleColor = unfocusedTitleColor
            self.titleAlignment = titleAlignment
            self.titlePadding = titlePadding
            self.titleFont = titleFont
        }
    }

    public enum ActionButtonStyleType {
        case centerAligned
        case leadingAligned

        public var style: ActionButtonStyle {
            switch self {
            case .centerAligned:
                return ActionButtonStyle()
            case .leadingAligned:
                return ActionButtonStyle(titleAlignment: .leading, titlePadding: EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            }
        }
    }

    public struct ActionButton: View {
        private let title: String
        private let action: () -> Void
        @FocusState private var isFocus: Bool
        private let style: ActionButtonStyle

        public init(title: String, style: ActionButtonStyle = ActionButtonStyle(), action: @escaping () -> Void, isFocus: Bool = false) {
            self.title = title
            self.action = action
            self.style = style
            self.isFocus = isFocus
        }

        public var body: some View {
            Button(
                action: action,
                label: {
                    ZStack {
                        if isFocus {
                            style.focusedColor
                        } else {
                            style.unfocusedColor
                        }
                        Text(title)
                            .font(style.titleFont)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: style.titleAlignment)
                            .foregroundStyle(isFocus ? style.focusedTitleColor : style.unfocusedTitleColor)
                            .padding(style.titlePadding)
                    }
                }
            )
            .buttonStyle(.card)
            .focused($isFocus)
        }
    }
#endif
