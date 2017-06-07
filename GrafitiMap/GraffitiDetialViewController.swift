//
//  GraffitiDetialViewController.swift
//  GrafitiMap
//
//  Created by Mauricio Figueroa Olivares on 10-04-17.
//  Copyright © 2017 Mauricio Figueroa Olivares. All rights reserved.
//

import UIKit

 // Creamos un protocolo de delegado
protocol GraffitiDetialViewControllerDelegate: class {
    func graffitiDidFinishGetTagged(sender: GraffitiDetialViewController, taggedGraffiti : Graffiti)
}

class GraffitiDetialViewController: UIViewController {
    
    // Creamnos la variable delegate
    weak var  delegate: GraffitiDetialViewControllerDelegate?
    
    
    @IBOutlet var imageGraffitiView: UIImageView!
    
    @IBOutlet var longitudeLavel: UILabel!
    
    @IBOutlet var latitudeLabel: UILabel!
    
    @IBOutlet var direccionLabel: UILabel!
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var taggedGraffiti : Graffiti?  // Declaramos una variable de tipo Clase Graffiti
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Agregamos la imagen al menu de arriba
        let image = UIImage(named: "img_navbar_title")
        self.navigationItem.titleView = UIImageView(image: image)
        
        // Creamos un gestureRecognizer
        let takePictureGesture = UITapGestureRecognizer(target: self, action: #selector(takePictureTap))
        
        // Lo añadimos a la imagen para que cuando se toque la foto se tome como una accion
        self.imageGraffitiView.addGestureRecognizer(takePictureGesture)
        
        // Le asignamos a la imagen el gestureRecognizer
        self.imageGraffitiView.addGestureRecognizer(takePictureGesture)
        
        // Habilitamos la interacción del usuario con la imagen
        self.imageGraffitiView.isUserInteractionEnabled = true
        
        //Metodo para configurar los Labels
        ConfigureLabels()
        
    }
    
    
    // Boton Save para guardar los graffitis
    @IBAction func saveGraffity(_ sender: UIBarButtonItem) {
    
        // Si existe la imagen
        if let image = imageGraffitiView.image {
            
            // Generamos un nombre aleatorio
            let randomName = UUID().uuidString.appending(".png")
            
            // Asignamos la url con todo el nombre
            if let url = GraffitiManager.sharedInstance.imagesURL()?.appendingPathComponent(randomName),
                // Convertimos la imagen capturada en PNG
                let imageData = UIImagePNGRepresentation(image) {
                
                do {
                    try imageData.write(to: url)  // Crea la imagen
                } catch (let error) {
                    print("Error al guardar la imagen: \(error.localizedDescription)")
                }
                
            }
            
            // Creamos el objeto graffiti con todos los parametros
            taggedGraffiti = Graffiti(address: direccionLabel.text!, lattiude: Double(latitudeLabel.text!)!, longitude: Double(longitudeLavel.text!)!, image: randomName)
            
            // si existe el objeto
            if let taggedGraffiti = taggedGraffiti {
                
                // Llamamos al metodo de la clase CurrentViewController para devolver el objeto taggedGraffiti
                delegate?.graffitiDidFinishGetTagged(sender: self, taggedGraffiti: taggedGraffiti)
                
                // Como ya guardamos volvemos a la pantalla del mapa
                dismiss(animated: true, completion: nil)
            }
            
        
        }
    
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        
        // Permite volver a la pantalla anterior
        dismiss(animated: true, completion: nil)
    }
    
    func ConfigureLabels() {
        
        // Asignamos la latitud a nuestro Label
        latitudeLabel.text = String(format: "%.8f", (taggedGraffiti?.coordinate.latitude)!)
        
        // Asignamos la longitud a nuestro Label
         longitudeLavel.text = String(format: "%.8f", (taggedGraffiti?.coordinate.longitude)!)
        
        // Asignamos la direccion a nuestro label
        direccionLabel.text = taggedGraffiti?.graffitiAddress
        
    }

}

// Extendemos la clase para implementar los delegados
extension GraffitiDetialViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Funcion para cuando el usuario toque el gestureRecognizer que tiene la imagen
    func takePictureTap() {
        
        // Si la camara esta habilitada
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            // llamamos al metodo para menu de la camara
            showPhotoMenu()
        } else {
            // No tenemos la camara, obtenemos de la libreria
            choosePhotoFromLibrary()
        }
        
        
    }
    
    // Metodo para Menu de la camara
    func showPhotoMenu() {
    
        // Implementamos la alerta
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Implementamos la accion de cancelar
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        // Asignamos la accion de cancelar a nuestro alertController
        alertController.addAction(cancelAction)
        
        // Implementamos la accion de tomar foto
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (_) in
            // Llamamos al metodo que toma la foto
            self.takePhotoWithCamera()
        }
        
        // Añadimos la accion de tomar foto a la alerta
        alertController.addAction(takePhotoAction)
        
        // Implementamos la accion para tomar la foto desde la libreria
        let chooseFromLibraryAction = UIAlertAction(title: "Elegir de la Libreria", style: .default) { (_) in
            
            // Llamamos a la funcion que obtiene la foto de la libreria
            self.choosePhotoFromLibrary()
        }
        
        // Añadimos la accion de elegir foto de la libreria a nuestra alerta
        alertController.addAction(chooseFromLibraryAction)
        
        // Presentamos la alerta en pantalla
        present(alertController, animated: true, completion: nil)
    }
    
    // Funcion para tomar foto desde la Camara
    func takePhotoWithCamera() {
        
        // Inicializamos el picker
        let imagePicker = UIImagePickerController()
        
        // Le asignamos la fuente de la camara
        imagePicker.sourceType = .camera
        
        // Le asignamos el delegado
        imagePicker.delegate = self
        
        // Le asignamos que si se pueda editar
        imagePicker.allowsEditing = true
        
        // Presentamos el picker en pantalla
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    // Funcion para obtener la foto desde la libreria
    func choosePhotoFromLibrary() {
        
        
        // Inicializamos el picker
        let imagePicker = UIImagePickerController()
        
        // Le asignamos la fuente de la libreria
        imagePicker.sourceType = .photoLibrary
        
        // Le asignamos el delegado
        imagePicker.delegate = self
        
        // Le asignamos que si se pueda editar
        imagePicker.allowsEditing = true
        
        // Presentamos el picker en pantalla
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // Funcion para cuando se toma la foto
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Obtenemos la foto sacada y la transformamos en imagen
        let imageTaken = info[UIImagePickerControllerEditedImage] as? UIImage
        
        // Le asignamos la foto sacada por la camara a la imagen de la pantalla
        imageGraffitiView.image = imageTaken
        
        // Como ya tenemos una imagen, Habilitamos el boton Save
        saveButton.isEnabled = true
        
        // Volvemos atras
        dismiss(animated: true, completion: nil)
    }
    
    // Funcion para cuando se cancele
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}



