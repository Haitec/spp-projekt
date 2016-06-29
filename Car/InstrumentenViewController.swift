//
//  InstrumentenViewController.swift
//  Car
//
//  Created by michael on 03.06.16.
//  Copyright © 2016 michael. All rights reserved.
//

import UIKit

class InstrumentenViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureViewForSize(view.bounds.size)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator
        coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        configureViewForSize(size)
    }
    
    
    //Setzt die Achse des stackViews je nach Orientierung des Gerätes
    private func configureViewForSize(size: CGSize) {
        if size.width > size.height {
            stackView.axis = .Horizontal
        } else {
            stackView.axis = .Vertical
        }
    }
}
