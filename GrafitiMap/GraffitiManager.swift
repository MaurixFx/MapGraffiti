//
//  GraffitiManager.swift
//  GrafitiMap
//
//  Created by Mauricio Figueroa Olivares on 11-04-17.
//  Copyright © 2017 Mauricio Figueroa Olivares. All rights reserved.
//

import Foundation

class GraffitiManager {
    
    static let sharedInstance = GraffitiManager()
    
    // Inicializamos la variable graffiti de la clase Graffiti vacia
    var graffitis : [Graffiti] = [Graffiti]()
    
    
    // Funcion para guardar el graffiti
    func save() {
        if let url = databaseURL() {
            
            NSKeyedArchiver.archiveRootObject(graffitis, toFile: url.path)
        } else {
            print("Ocurrio un error al guardar datos")
        }
    }
    
    // Funcion donde retornamos la URL de la base
    func databaseURL() -> URL? {
        
        // Obtenemos el Directorio de documentos
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let url = URL(fileURLWithPath: documentDirectory)
            return url.appendingPathComponent("graffitis.data") // Archivo donde se guardaran los datos
        } else {
            
            return nil
        }
    }
    
    // Funcion para cargar los datos
    func load() {
        // Comprobamos si existe la ruta del directorio de documentos
        if let url = databaseURL(),
            let saveData = NSKeyedUnarchiver.unarchiveObject(withFile: url.path) as? [Graffiti] {
            graffitis = saveData // Ahi tendriamos los datos cargados en el objeto de la clase
        } else {
            print("Error al cargar los datos")
        }
    }
    
    
    // Funcion para guardar las imagenes
    func imagesURL() -> URL? {
        
        // Obtenemos el Directorio de documentos para las imagenes
        if let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let url = URL(fileURLWithPath: documentDirectory)
            return url
        } else {
            return nil
        }
    }

    
    
}
