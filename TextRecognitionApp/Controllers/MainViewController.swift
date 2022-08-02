//
//  ViewController.swift
//  TextRecognitionApp
//
//  Created by Radik Gazetdinov on 23.04.2022.
//

import UIKit
import Vision

class MainViewController: UIViewController {

    var imagePicker = UIImagePickerController()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Выбрать изображение", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(btnChooseImageOnClick), for: .touchUpInside)
        return button
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(button)
        view.addSubview(imageView)
        view.addSubview(textView)

        imageView.isUserInteractionEnabled = true
    }
    
    @objc func btnChooseImageOnClick(_ sender: UIButton) {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: { _ in
                self.openCamera()
            }))
            
            alert.addAction(UIAlertAction(title: "Выбрать фото", style: .default, handler: { _ in
                self.openGallery()
            }))
            
            alert.addAction(UIAlertAction.init(title: "Отмена", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        func openCamera(){
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                self.present(imagePicker, animated: true, completion: nil)
            }
            else{
                let alert  = UIAlertController(title: "Предупреждение", message: "Нет доступа к камере", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        func openGallery(){
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top,
            width: view.frame.size.width-40,
            height: view.frame.size.width-40)
        button.frame = CGRect(
            x: 20,
            y: view.safeAreaInsets.top + (view.frame.size.width-40)+5,
            width: view.frame.size.width-40,
            height: 50
        )
        textView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top + (view.frame.size.width-40)+85,
            width: view.frame.width,
            height: view.frame.size.width)
    }
    
    func recognizeText(image: UIImage?) {
            guard let cgImage = image?.cgImage else { return }
    
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
            let request = VNRecognizeTextRequest { [weak self] request, error in
                guard let observations = request.results as? [VNRecognizedTextObservation],
                      error == nil else {
                          return
                      }
    
                let text = observations.compactMap({
                    $0.topCandidates(1).first?.string
                }).joined(separator: ", ")
    
                DispatchQueue.main.async {
                    self?.textView.text = text
                }
            }
    
            //request.recognitionLanguages = ["ru-RU"]
    
            do {
                //var t = try VNRecognizeTextRequest.supportedRecognitionLanguages(for: .fast, revision: 2)
                try handler.perform([request])
            }
            catch {
                print(error)
            }
    }
}

extension MainViewController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true, completion: nil)
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }
            imageView.image = image
            recognizeText(image: image)
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.isNavigationBarHidden = false
        self.dismiss(animated: true, completion: nil)
    }
}
