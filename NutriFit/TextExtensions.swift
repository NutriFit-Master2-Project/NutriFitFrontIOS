//
//  TextExtensions.swift
//  NutriFit
//
//  Created by Maxence Walter on 17/09/2024.
//

import Foundation
import SwiftUI

extension Text {
    func customTitle1() -> Text {
        self
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundColor(.white)
    }

    func customTitle2() -> Text {
        self
            .font(.system(size: 20, design: .default))
            .foregroundColor(.white)
    }
    
    func customSmallUnderlined() -> Text {
        self
            .font(.system(size: 15))
            .underline()
            .foregroundColor(.white)
    }
    
    func customSmallText() -> Text {
        self
            .font(.system(size: 15))
            .foregroundColor(.white)
    }
}
