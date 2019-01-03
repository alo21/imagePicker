//
//  ViewController.swift
//  imagePicker
//
//  Created by Alessandro Losavio on 12/26/18.
//  Copyright © 2018 Losavio. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var topText: UITextField!
    @IBOutlet var bottomText: UITextField!
    var currentTappedTextField : UITextField?
    
    @IBOutlet var TakeButton: UIBarButtonItem!
    @IBOutlet var PickButton: UIBarButtonItem!
    
    @IBOutlet var shareButton: UIBarButtonItem!
    
    
    @IBOutlet var bottomToolbar: UIToolbar!
    @IBOutlet var topToolbar: UIToolbar!
    
     var navBar: UINavigationBar = UINavigationBar()
    
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.black,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
    ]
    
    struct Meme{
    
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topText.delegate = self
        self.bottomText.delegate = self
        
        shareButton.isEnabled = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        TakeButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        bottomText.attributedPlaceholder = NSAttributedString(string: "BOTTOM", attributes: memeTextAttributes)
        
        
        topText.attributedPlaceholder = NSAttributedString(string: "TOP", attributes: memeTextAttributes )
        
        formatTextField(textField: topText)
        formatTextField(textField: bottomText)
        
        
    }
    
    func formatTextField(textField : UITextField){
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        
    }
    
    
    @IBAction func EditDidBegin(_ sender: UITextField) {
        
        sender.placeholder = nil
        
        
    }
    

    @IBAction func EditDidEnd(_ sender: UITextField) {
        
        if sender.text == "" {
        sender.placeholder = "TEXT"
        }
        
    }

    //Use different sourceType depending on which is the sender
    @IBAction func TakeOrLibrary(_ sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if sender == TakeButton {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        imageView.image = newImage
        
        shareButton.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }

    

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        
    }
    
    
    @IBAction func shareAction(_ sender: Any) {
        
        let activityVC = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        activityVC.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                print("cancelled")
                return
            }
            print("saved")
            self.save()
        }
        
        
        self.present(activityVC, animated: true, completion: nil)
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Setting cuttent TextField selected
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTappedTextField = textField
        return true
    }
    
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        
        if (currentTappedTextField == bottomText) {
        
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification) {
        
        view.frame.origin.y = 0
        
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func save() {
        
        // Create the meme
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
    }
    
    func generateMemedImage() -> UIImage {
        
        setToolbarsHidden(status: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        setToolbarsHidden(status: false)
        
        return memedImage
    }
    
    //Set toolbars visibility
    func setToolbarsHidden( status : Bool){
        
        topToolbar.isHidden = status
        bottomToolbar.isHidden = status
        
    }
    
    
}

