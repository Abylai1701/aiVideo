//
//  CategoriesView.swift
//  TestBroadApps
//
//  Created by Abylaikhan Abilkayr on 04.10.2025.
//

import SwiftUI

struct CategoriesView: View {
    let categories: [TemplateCategory]
    var ontap: (TemplateCategory) -> Void
    var ontapItem: (Template) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(categories) { category in
                    CategorySection(category: category) { category in
                        ontap(category)
                    } onTapItem: { item in
                        ontapItem(item)
                    }

                }
            }
            .padding(.top)
            .padding(.bottom, 100)
        }
    }
}
