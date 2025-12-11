import SwiftUI

struct SplashScreen: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack(alignment: .center) {
            Color.white.ignoresSafeArea()
            
            Image(.iconn)
                .resizable()
                .frame(width: 120, height: 120)
            
            ProgressView()
                .scaleEffect(2)
                .offset(y: 100)
                        
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isVisible = false
                }
            }
        }
    }
}
