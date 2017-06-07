//
//  CurrentViewController
//  GrafitiMap
//
//  Created by Mauricio Figueroa Olivares on 09-04-17.
//  Copyright © 2017 Mauricio Figueroa Olivares. All rights reserved.
//

import UIKit
import MapKit

class CurrentViewController: UIViewController {

    @IBOutlet var getLocation: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var newGraffity: UIBarButtonItem!
    
    @IBOutlet var activity: UIActivityIndicatorView!
    
    var graffiti : Graffiti?  // Declaramos una variable de la clase Graffiti

    let locationManager = CLLocationManager()
    

    // Variable para verificar el estado de la locacion
    var updatingLocation = false {
        didSet{
            
            if updatingLocation {
                getLocation.setImage(#imageLiteral(resourceName: "btn_localizar_off"), for: .normal)
                activity.isHidden = false // Ponemos visible el activityIndicator
                activity.startAnimating() // Le damos animacion al activity
                
                // Permite que el usuario no pueda tocar el botton
                getLocation.isUserInteractionEnabled = false
            } else {
                getLocation.setImage(#imageLiteral(resourceName: "btn_localizar_on"), for: .normal)
                activity.isHidden = true // Ocultamos el activity
                activity.stopAnimating() // Paramos la animacion
                // Habilitamos el boton para que se pueda volver a utilizar
                getLocation.isUserInteractionEnabled = true
            }
            
        }
    }
    
    
    
    let geoCoder = CLGeocoder() // Propiedad para hacer la localizacion inversa

    
    // Creamos la variable donde se muestra la foto sobre el pincho
    var selectedCalloutImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Cargamos los graffitis guardados
        GraffitiManager.sharedInstance.load()
        
        // Agregamos la imagen al menu de arriba
        let image = UIImage(named: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)
        
        updatingLocation = false // Inicializamos false
        newGraffity.isEnabled = false // Lo seteamos a false para que este inhabilitado
        
    }
    
    // Cuando la vista aparezca
    override func viewWillAppear(_ animated: Bool) {
        
        mapView.delegate = self
        
        // Agregamos las anotaciones al mapa
        mapView.addAnnotations(GraffitiManager.sharedInstance.graffitis)
        
    }
    
    @IBAction func getUbication(_ sender: UIButton) {
        startLocationManager()
    }
    
    func startLocationManager() {
        
        // Obtenemos el estado del permiso del usuario
        let authStatus = CLLocationManager.authorizationStatus()
        
        switch authStatus {
        case .notDetermined: // La aplicacion no sabe si tiene permiso
            // Pedimos permiso
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:  // denegada o restrictiva
            // No se puede localizar al usuario
            showLocationServicesDeniedAlert()
        default:
            // Si esta habilitada la locacion
            if CLLocationManager.locationServicesEnabled() {
                self.updatingLocation = true // habilitamos la variable
               // self.newGraffity.isEnabled = true // Desabilitamos el boton añadir
                
                locationManager.delegate = self // Nos hacemos delegados del locationManagaer
                // Le asignamos 10 METROS de proximidad
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.requestLocation() // Esperamos la localizacion
                
                // Hacemos zoom sobre la localizacion del usuario
                let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000) // Definimos una region alrededor de mi ubicacion a 10 Kilometros
                
                // Asignamos la region al Mapa
                mapView.setRegion(mapView.regionThatFits(region), animated: true)
                
                
                if activity.isHidden == true {
                    // Habilitamos el botom para agregar la foto
                    newGraffity.isEnabled = true
                }
                
            }
        }
        
    }
    
    // Funcion de mensaje de alerta
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "La Localización desactivada", message: "Por favor, activa la localización para esta App en Ajustes", preferredStyle: .alert)
        let accion = UIAlertAction(title: "OK", style: .default, handler: nil) // Creamos la alerta
        
        alert.addAction(accion) // Añadimos la accion a la alerta
        
        present(alert, animated: true, completion: nil) // Presentamos la alerta
    }
    

}


// Implementamos el delegado
extension CurrentViewController: CLLocationManagerDelegate {
    
    // Funcion para verificar si hubo algun error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("******** Error en CoreLocation ************")
    }
    
    // Funcion en caso de que haya un cambio en la localizacion
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Nos aseguramos que obtenemos la ultima localizacion
        guard let newLocation = locations.last else { return }
        
        // Obtenemos la latitude de la nueva localizacion
        let latitude = Double(newLocation.coordinate.latitude)
        
        // Obtenemos la longitud de la nueva localizacion
        let longitude = Double(newLocation.coordinate.longitude)
        
    
        geoCoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
            if error == nil {
                var address = "No se ha podido determinar"
                
                if let placemark = placemarks?.last { // Si hay un punto de localizacion
                
                    // Asignamos la direccion obteniendo desde un metodo el placemark
                    address = self.stringFromPlacemark(placemark : placemark)
                }
                
                
                // Almacenamos provisoriamente en el objeto las propiedades del graffiti
                self.graffiti = Graffiti(address: address, lattiude: latitude, longitude: longitude, image: "")
                
                self.updatingLocation = false // cambiamos el estado de la variable
                self.getLocation.isEnabled = true // Habilitamos el boton
                
            }
        }
        
    }
    
    // Funcion para obtener la direccion desde un Placemark
    func stringFromPlacemark(placemark : CLPlacemark) -> String {
        var linea1 = ""
        
        // Obtenemos el nombre de la calle
        if let s = placemark.thoroughfare {
            
            linea1 += s + ", "
        }
        
        // Obtenemos el numero
        if let s = placemark.subThoroughfare {
            linea1 += s
        }
        
        
        var Linea2 = ""
        
        // Obtenemos el codigo Postal
        if let s = placemark.postalCode {
            Linea2 += s + " "
        }
        
        // Obtenemos la localidad
        if let s = placemark.locality {
            Linea2 += s
        }
        
        var linea3 = ""
        
        // Obtenemos la area
        if let s = placemark.administrativeArea {
            linea3 += s
        }
        
        return linea1 + "\n" + Linea2 + "\n" + linea3
    }
    
    // Implementamos el segue para poder pasar las variables a la pantalla de  Detalle
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Si el segue es tagGraffiti
        if segue.identifier == "tagGraffiti" {
            
            // Asignamos el navigationcontroller de destino
            let navigationController = segue.destination as! UINavigationController
            
            // Obtenemos el viewController destino, que estaba dentro del navigationController
            let detailsViewController = navigationController.topViewController as! GraffitiDetialViewController
            
            // Asignamos el objeto de la clase Graffiti, al objeto de la clase Grafifiti que
            // esta en el GraffitiDetailsViewController
            detailsViewController.taggedGraffiti = self.graffiti
            
            // Le asignamos el delegado de esta clase
            // Porque necesita conocerlo para despues devolver los datos
            // y poner el pincho en el Mapa
            detailsViewController.delegate = self
            
        }
    
        // Si el segue es de GraffitiImagenDetial
        if segue.identifier == "showPinImage" {
        
            // Asignamos el navigationcontroller de destino
            let navigationController = segue.destination as! UINavigationController
            
             // Obtenemos el viewController destino, que estaba dentro del navigationController
            let graffitiImageView = navigationController.topViewController as! GraffitiImageViewController
            
            // Asignamos la imagen del pin a la imagen de la vista detalle
            graffitiImageView.selectedCallout = selectedCalloutImage
                        
        }
        
    }

    
}

// Implementamos el protocolo de la clase
extension CurrentViewController: GraffitiDetialViewControllerDelegate {
    func graffitiDidFinishGetTagged(sender: GraffitiDetialViewController, taggedGraffiti: Graffiti) {
       
        // Obtenemos el objeto taggedGraffiti que viene de la clase GraffitiDetailViewController
        GraffitiManager.sharedInstance.graffitis.append(taggedGraffiti)
        
        // Guardamos
        GraffitiManager.sharedInstance.save()
        
        
    }
}


// Implementamos la extension para poner los pinchos en el mapa
extension CurrentViewController: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Si es nuestra localizacion
        if annotation is MKUserLocation {
            return nil
        }
        
        // Reutiliza el Mapa para seguir poniendo pines
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "graffitiPin")
        
        
        if annotationView == nil {
            
            // Creamos una nueva annotation
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "graffitiPin")
        
        } else {
          
            annotationView?.annotation = annotation
        }
        
        
        // Si la annotacion es de tipo Graffiti
        if let place = annotation as? Graffiti {
            
            // Asignamos el nombre del graffiti
            let imageName = place.graffitiImageName
            
            // Si existe la imagen la cargamos
            if let imagesURL = GraffitiManager.sharedInstance.imagesURL() {
                

                do {
                    // Asignamos la imagen
                    let imageData = try Data(contentsOf: imagesURL.appendingPathComponent(imageName))

                    // Asignamos la imagen obtenida a la imagen de pantalla
                    selectedCalloutImage = UIImage(data: imageData)
                    
                    // Llamamos la funcion que nos modifica el tamaño de nuestra imagen a 40.0
                    let image = resizeImage(image: selectedCalloutImage!, newwidth: 40.0)
                    
                    // Creamos el boton
                    let btnImagenView = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                    
                    // Asignamos la imagen al boton
                    btnImagenView.setImage(image, for: .normal)
                    
                    // Le asignamos el boton a pin del mapa
                    annotationView?.leftCalloutAccessoryView = btnImagenView
                    
                    // Asignamos la foto del pin
                    annotationView?.image = #imageLiteral(resourceName: "img_pin")
                    
                    // Le indicamos que muestre los datos
                    annotationView?.canShowCallout = true
                    
                } catch (let error) {
                    print("Error al guardar la imagen: \(error.localizedDescription)")
                }
  
            }
            
            
        }
        
        return annotationView
    
    }
    
    // Funcion para achicar la imagen para el pincho
    func resizeImage(image: UIImage, newwidth: CGFloat) -> UIImage {
        
        
        let scale = newwidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newwidth, height: newHeight))
        
        image.draw(in: CGRect(x: 0, y: 0, width: newwidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
    
    // Funcion para cuando se apreta el pin del mapa
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // Collaut que esta a la izquierda
        if control == view.leftCalloutAccessoryView {
           
            // Nos dirigimos a la pantalla de detalle de la imagen
            performSegue(withIdentifier: "showPinImage", sender: view)
        }
        
    }
    
    
    
}

