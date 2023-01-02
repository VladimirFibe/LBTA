import MapKit

extension MKMapItem {
    var address: String {
        var address = ""
        if let subThoroughfare = placemark.subThoroughfare {
            address += subThoroughfare + " "
        }
        if let thoroughfare = placemark.thoroughfare {
            address += thoroughfare + ", "
        }
        if let postalCode = placemark.postalCode {
            address += postalCode + ", "
        }
        if let locality = placemark.locality {
            address += locality + ", "
        }
        if let administrativeArea = placemark.administrativeArea {
            address += administrativeArea + ", "
        }
        if let country = placemark.country {
            address += country
        }
        return address
    }
}
