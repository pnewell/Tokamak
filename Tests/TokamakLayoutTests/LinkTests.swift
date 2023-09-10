// Copyright 2022 Tokamak contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Created by Carson Katri on 2/4/23.
//

#if os(macOS)
import SwiftUI
import TokamakStaticHTML
import XCTest

final class LinkTests: XCTestCase {
  func testLink() async {
    await compare(size: .init(width: 500, height: 500)) {
      SwiftUI.Link(destination: URL(string: "https://tokamak.dev")!) {
        Rectangle()
          .fill(Color(white: 0))
          .frame(width: 250, height: 100)
      }
    } to: {
      TokamakStaticHTML.Link(destination: URL(string: "https://tokamak.dev")!) {
        Rectangle()
          .fill(TokamakStaticHTML.Color(white: 0))
          .frame(width: 250, height: 100)
      }
    }
  }
}
#endif
