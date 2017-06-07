//
//  GraffitiImageViewController.swift
//  GrafitiMap
//
//  Created by Mauricio Figueroa Olivares on 12-04-17.
//  Copyright © 2017 Mauricio Figueroa Olivares. All rights reserved.
//

import UIKit

class GraffitiImageViewController: UIViewController {
    
    
    @IBOutlet var graffitiImage: UIImageView!
    
    // Variable de la imagen seleccionada
    var selectedCallout : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Si viene la imagen de la pantalla anterior
        // Se la asignamos a la imagen de la pantalla
        if let selectedCallout = selectedCallout {
            graffitiImage.image = selectedCallout
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func closeButton(_ sender: UIBarButtonItem) {
        
        // Cerramos la pantalla y volvemos atras
        dismiss(animated: true, completion: nil)
    }
   
}
