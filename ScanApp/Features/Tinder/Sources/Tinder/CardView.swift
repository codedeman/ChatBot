//
//  CardView.swift
//  
//
//  Created by Kevin on 6/8/24.
//

import SwiftUI


struct CardView: View {
    var profile: UserProfile

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: profile.imageName))
                .scaledToFill()
                .frame(
                    width: UIScreen.main.bounds.width * 0.9,
                    height: UIScreen.main.bounds.height * 0.7
                )
                .clipped()
                .cornerRadius(10)
                .shadow(radius: 5)

            VStack(alignment: .leading, spacing: 8) {
                Text("\(profile.name), \(profile.age)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(profile.name)
                    .font(.body)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .bottom, endPoint: .top)
            )
            .cornerRadius(10)
        }
        .frame(
            width: UIScreen.main.bounds.width * 0.9,
            height: UIScreen.main.bounds.height * 0.7
        )
        .padding(.leading, 10)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(
            profile: .init(
                id: "123",
                name: "Did",
                age: 12,
                imageName: "https://scontent.fhan5-6.fna.fbcdn.net/v/t39.30808-6/440856987_417271671091914_3298011467750712032_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=5f2048&_nc_eui2=AeFHdD-_WMHXf1UYb1-WwZRrLzHNcCqKSUwvMc1wKopJTIDVSuaxGwdpnuFowW3zMMjWHajdolBa8UtxHrQIKP0a&_nc_ohc=gTDFsyDIaS0Q7kNvgFXUFyW&_nc_ht=scontent.fhan5-6.fna&cb_e2o_trans=t&oh=00_AYBnkPViRPdTInmP0VwB6kyP6xnf_StYRxnlSxBT7YioDw&oe=666B37F9"
            )
        )
    }
}
