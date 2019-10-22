//
//  HistoryList.swift
//  PolluxUI
//
//  Created by Edward Arenberg on 10/22/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import SwiftUI

struct HistoryRow: View {
    let title : String
    let date : String
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
            Spacer()
            Text(date)
        }
    }
}

struct HistoryList: View {
    var body: some View {
        List {
            HStack {
                Spacer()
                Text("History")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Spacer()
            }

            HistoryRow(title: "Lego Batman", date: "10/20/2019")
            HistoryRow(title: "Wonder Woman", date: "10/21/2019")
        }
    }
}

struct HistoryList_Previews: PreviewProvider {
    static var previews: some View {
        HistoryList()
    }
}

