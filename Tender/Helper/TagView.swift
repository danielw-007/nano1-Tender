//
//  TagView.swift
//  Tender
//
//  Created by Daniel Widjaja on 22/03/23.
//

import SwiftUI

struct TagView: View {
    
    @Binding var myInterest: [String]
    var tags: [String]
    
    @State private var totalHeight = CGFloat.zero
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(self.tags, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == self.tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == self.tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }
    
    private func item(for tag: String) -> some View {
        
        Text(tag)
            .font(.caption)
            .foregroundColor(Color.black)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(myInterest.contains(tag) ? Color.init(hex: "FEECD1") : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(myInterest.contains(tag) ? Color.init(hex: "804000") : Color.black, lineWidth: 0.5)
            )
        
    }
    
    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

//struct TagView_Previews: PreviewProvider {
//    static var previews: some View {
//        TagView()
//    }
//}
