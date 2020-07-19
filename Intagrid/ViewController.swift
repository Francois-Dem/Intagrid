//
//  ViewController.swift
//  Intagrid
//
//  Created by Noblus Mac on 15/05/2020.
//  Copyright © 2020 FrancoisDemichelis. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var shareView: UIView!
    
    let imagePicker = UIImagePickerController()
    var activeButton: UIButton?
    var gesture:  UISwipeGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        let btn3 = view.viewWithTag(3) as? UIButton
        btn3?.isEnabled = false
        
        gesture = UISwipeGestureRecognizer(target: self, action: #selector(shareAction))
        shareView.addGestureRecognizer(gesture!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setOrientation()
    }
    
    private func setOrientation() {
        gesture?.direction = UIApplication.shared.statusBarOrientation.isLandscape ? .left : .up
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { (_) in
            self.setOrientation()
        }
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        (view.viewWithTag(1) as? UIButton)?.isEnabled = true
        (view.viewWithTag(2) as? UIButton)?.isEnabled = true
        (view.viewWithTag(3) as? UIButton)?.isEnabled = true
        sender.isEnabled = false
        
        view2.isHidden = sender.tag == 1
        view4.isHidden = sender.tag == 2
    }
    
    // Start check if all views is not empty
    private func showAlert() {
        let alert = UIAlertController(title: "Erreur", message: "Tous les boutons ne sont pas renseignés", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func compareImages(image1: UIImage?, isEqualTo image2: UIImage?) -> Bool {
        guard let data1: Data = image1?.pngData() else { return false }
        guard let data2: Data = image2?.pngData() else { return false}
        
        return data1 == data2
    }
    
    private func compareBtn(with tag: Int) -> Bool {
        let plusImg = #imageLiteral(resourceName: "Plus")
        
        let btn = view.viewWithTag(tag) as? UIButton
        let img = btn?.image(for: .normal)
                
        if compareImages(image1: plusImg, isEqualTo: img) {
            showAlert()
            return false // if button image is + it's false
        }
        
        return true
    }
    
    @objc func shareAction(sender: UISwipeGestureRecognizer) {
        
        if !compareBtn(with: 11) || !view2.isHidden && !compareBtn(with: 12) || !view4.isHidden && !compareBtn(with: 14) || !compareBtn(with: 13) {
            return
        }

        doShareAction()
    }
    // End checking views
    

    private func doShareAction() {
        //UIView ->UIImage
        let renderer = UIGraphicsImageRenderer(size: shareView.bounds.size)
        let image = renderer.image { ctx in
            shareView.drawHierarchy(in: shareView.bounds, afterScreenUpdates: true)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            if self.gesture?.direction == .left {
                self.shareView.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            } else {
                self.shareView.transform = CGAffineTransform(translationX: 0, y: -self.view.frame.height)
            }
        }) { (_) in
            let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            ac.popoverPresentationController?.sourceView = self.shareView
            ac.completionWithItemsHandler = { activity, success, items, error in
                self.shareView.transform = .identity
            }
            self.present(ac, animated: true)
        }
    }
    
    @IBAction func insertImg (_ sender: UIButton) {
        activeButton = sender
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let activeBtn = activeButton, let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        activeBtn.contentMode = .scaleAspectFit
        activeBtn.setImage(pickedImage, for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
    
}


