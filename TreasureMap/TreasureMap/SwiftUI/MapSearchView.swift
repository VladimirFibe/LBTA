import SwiftUI
import MapKit

struct MapSearchView: View {
    @ObservedObject var viewModel = MapSearchViewModel()
   
    var body: some View {
        ZStack(alignment: .top) {
            MapViewContainer(annotations: viewModel.annotations)
                .ignoresSafeArea()
            VStack {
                TextField("Search term", text: $viewModel.searchQuery)
                    .padding(12)
                    .background(Color.white)
                    .padding()
                .shadow(radius: 3)
                Text(viewModel.isSearching ? "Searching..." : "")
                    .foregroundColor(.black)
                    .shadow(color: .white, radius: 2)
            }
        }
    }
    var buttons: some View {
        HStack {
            Button(action: {
                viewModel.performLocalSearch("sushi")
            }) {
                Text("Search for Airports")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
            }
            Button(action: {
                viewModel.removeLocations()
            }) {
                Text("Search for Airports")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
            }
        }
        .shadow(radius: 3)
        .padding()
    }
}

struct MapSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchView()
    }
}
