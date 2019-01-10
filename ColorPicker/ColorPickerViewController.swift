//
//  ColorPickerViewController.swift
//  ColorPicker
//
//  Created by Apple on 29/11/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ColorSlider

class ColorPickerViewController: UIViewController {

    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var customSliderContainerView: UIImageView!
    @IBOutlet weak var hexTxtFld: UITextField!
    @IBOutlet weak var rTxtFld: UITextField!
    @IBOutlet weak var gTxtFld: UITextField!
    @IBOutlet weak var bTxtFld: UITextField!
    @IBOutlet weak var aTxtFld: UITextField!
    @IBOutlet weak var previewColorView: UIView!
    @IBOutlet weak var alphaSlider: UISlider!
    @IBOutlet weak var alphaImageView: UIImageView!
     let gradientLayer = CAGradientLayer()
    
    var colorLeft =  UIColor.clear.cgColor
    var colorRight = UIColor.red.cgColor {
        didSet {
            gradientLayer.colors = [colorLeft,colorRight]
        }
    }
    
    
    var selectedColor:UIColor! {
        didSet {
            setSelected(color: selectedColor)
        }
    }
    
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 1.0 {
        didSet {
            previewColorView.alpha = a
            alphaSlider.setValue(Float(a), animated: true)
        }
    }
    var hex:String = ""
    
      let colorSlider = ColorSlider(orientation: .horizontal, previewSide: .bottom)
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        self.collectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addCustomSlider()
        updateViewConstraints()
        setGradientBackground()
        view.layoutIfNeeded()
    }
    
  
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("Changeeee",change)
        print(collectionView.contentSize.height)
       collectionViewHeight.constant = collectionView.contentSize.height + 50
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        
    }
    
    //MARK:- Color pikcer custom slider
    func addCustomSlider() {
        colorSlider.frame = customSliderContainerView.frame
        view.addSubview(colorSlider)

        let top = NSLayoutConstraint(item: colorSlider, attribute: .top, relatedBy: .equal, toItem: customSliderContainerView, attribute: .top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: colorSlider, attribute: .bottom, relatedBy: .equal, toItem: customSliderContainerView, attribute: .bottom, multiplier: 1.0, constant: 0)
        let left = NSLayoutConstraint(item: colorSlider, attribute: .left, relatedBy: .equal, toItem: customSliderContainerView, attribute: .left, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: colorSlider, attribute: .right, relatedBy: .equal, toItem: customSliderContainerView, attribute: .right, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([top,bottom,left,right])
        colorSlider.addTarget(self, action: #selector(changedColor(_:)), for: .valueChanged)
    }
    @IBAction func textFieldValueChanged(_ sender: UITextField) {
        if sender.tag == 0 {
            if sender.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 6 {
                let hex = sender.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                let color = UIColor(hex: hex)
               selectedColor = color
            }
            return
        }
        
        if sender.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" || sender.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 3  {
            return
        }
        guard let floatValue = Float(sender.text!) else {return }
        let value = CGFloat(floatValue)
        switch sender.tag {
        case 0: // Hex
            break
        case 1: // R
            r = value
        case 2: // G
            g = value
        case 3: // B
            b = value
        case 4: // A
            a = value
        default: break
        }
        selectedColor = UIColor(red: r , green: g, blue: b , alpha: a)
    }
    
    @objc func changedColor(_ slider: ColorSlider) {
        let color = slider.color
        let r = color.rgba.red
        let g = color.rgba.green
        let b = color.rgba.blue
        let a = self.a
        selectedColor = UIColor(red:r, green:g, blue:b, alpha: a)
    }
    
    
    //MARK:- Set Gradient View
    func setGradientBackground() {
       
        
       
        gradientLayer.colors = [colorLeft, colorRight]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = alphaImageView.frame
        gradientLayer.frame.origin.x = 0
        gradientLayer.frame.origin.y = 0
     
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        alphaImageView.layer.addSublayer(gradientLayer)
    }
    
    
    //MARK:- Set values in RGBA Text Fields
    private func setRGBA(R:CGFloat, G:CGFloat, B:CGFloat, A:CGFloat) {
        rTxtFld.text = String(format: "%.1f", Float(R))
        gTxtFld.text = String(format: "%.1f", Float(G))
        bTxtFld.text = String(format: "%.1f", Float(B))
        aTxtFld.text = String(format: "%.1f", Float(A))
        let hex =  String(
            format: "%02X%02X%02X",
            Int(r * 0xff),
            Int(g * 0xff),
            Int(b * 0xff)
        )
        hexTxtFld.text = hex
    }
    
    //MARK:- Set selected color
    private func setSelected(color:UIColor) {
            self.r = color.rgba.red
            self.g = color.rgba.green
            self.b = color.rgba.blue
            self.a = color.rgba.alpha
            self.previewColorView.backgroundColor = color
            let alphaColor = color.withAlphaComponent(1.0)
            self.colorRight = alphaColor.cgColor
            self.setRGBA(R: self.r, G: self.g, B: self.b, A: self.a)
    }
    
    //MARK:- Aplha Slider value changed
    @IBAction func alphaSliderValueChanged(_ sender: UISlider) {
        a = CGFloat(sender.value)
        selectedColor = UIColor(red: r , green: g, blue: b , alpha: a)
    }
  
}

//MARK:-Collection view data source and delegates
extension ColorPickerViewController:UICollectionViewDelegate,UICollectionViewDataSource {
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 36
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorPickerCell", for: indexPath) as! UICollectionViewCell
        let R = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let G = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let B = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        let A:CGFloat = 1
        cell.layer.cornerRadius = 5
        let color = UIColor(red: R, green: G, blue: B, alpha: A)
        cell.backgroundColor = color
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        self.selectedColor = cell?.backgroundColor
        self.colorSlider.color = self.selectedColor
        self.a = selectedColor.rgba.alpha
    }
    
    
    
}
    

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        print(red, green, blue, alpha)
        return (red, green , blue, alpha)
    }
        convenience init(hex: String) {
            let scanner = Scanner(string: hex)
            scanner.scanLocation = 0
            
            var rgbValue: UInt64 = 0
            
            scanner.scanHexInt64(&rgbValue)
            
            let r = (rgbValue & 0xff0000) >> 16
            let g = (rgbValue & 0xff00) >> 8
            let b = rgbValue & 0xff
            
            self.init(
                red: CGFloat(r) / 0xff,
                green: CGFloat(g) / 0xff,
                blue: CGFloat(b) / 0xff, alpha: 1
            )
        }
    
}






