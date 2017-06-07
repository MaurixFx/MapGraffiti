//
//  Graffiti.swift
//  GrafitiMap
//
//  Created by Mauricio Figueroa Olivares on 10-04-17.
//  Copyright © 2017 Mauricio Figueroa Olivares. All rights reserved.
//

import UIKit
import MapKit

class Graffiti: NSObject, NSCoding {
    
    // Declaramos las propiedades de la clase
    let graffitiAddress : String
    let graffitiLatitud : Double
    let graffitiLongitud: Double
    let graffitiImageName: String
    
    
    // Inicializamos la clase
    init(address: String, lattiude: Double, longitude: Double, image: String) {
        self.graffitiAddress = address
        self.graffitiLatitud = lattiude
        self.graffitiLongitud = longitude
        self.graffitiImageName = image
    }
    
    //MARK: NSCoding
    
    // Inicializamos NSCoding
    required convenience init?(coder aDecoder: NSCoder) {
        // Comenzamos a decodificar todos los objetos de la Clase Graffiti
        let graffitiAddress = aDecoder.decodeObject(forKey: "graffitiAddress") as! String
        let graffitiLatitud = aDecoder.decodeDouble(forKey: "graffitiLatitud")
        let graffitiLongitud = aDecoder.decodeDouble(forKey: "graffitiLongitud")
        let graffitiImageName = aDecoder.decodeObject(forKey: "graffitiImageName") as! String
        
        
        // Iniciamos el init de la clase Graffiti pasando las variables decodificadas
        self.init(address: graffitiAddress, lattiude: graffitiLatitud, longitude: graffitiLongitud, image: graffitiImageName)
        
    }
    
    // Implementamos la funcion que Codifica
    func encode(with aCoder: NSCoder) {
        // Comenzamos a Codificar todos los objetos de la Clase Graffiti
        aCoder.encode(self.graffitiAddress, forKey: "graffitiAddress")
        aCoder.encode(self.graffitiLatitud, forKey: "graffitiLatitud")
        aCoder.encode(self.graffitiLongitud, forKey: "graffitiLongitud")
        aCoder.encode(self.graffitiImageName, forKey: "graffitiImageName")
    }

}

// Extendemos la clase para implementar otros delegados
extension Graffiti: MKAnnotation {
    
    // Implementamos las coordenadas latitud y longitud
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: graffitiLatitud, longitude: graffitiLongitud)
        }
    }
    
    // Implementamos el Titulo
    var title: String? {
        return "Graffiti"
    }
    
    
    // Asignamos la direccion al Subtitulo
    var subtitle: String? {
        get {
            // replacingOccurrences sirve para reemplazar un caracter por otro
            return graffitiAddress.replacingOccurrences(of: "\n", with: "")
        }
    }
    
}

