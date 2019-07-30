//
//  TextView.swift
//  TextView
//
//  Created by Mohammad Arafat Hossain on 31/07/19.
//  Copyright © 2019 Mohammad Arafat Hossain. All rights reserved.
//


import UIKit

@objc public protocol TextViewDelegate: NSObjectProtocol {
    @objc optional func textViewDidChange(_ textView: TextView)
    @objc optional func textViewDidEndEditing(_ textView: TextView)
    @objc optional func textView(_ textView: TextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
}

@IBDesignable public class TextView: UITextView {
    @IBInspectable open var placeholderColor: UIColor = UIColor.lightGray {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var placeholder: String = "Enter detail" {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var maxAllowedChar: Int = 25 {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var showTextCounter: Bool = true {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var borderColor: UIColor = UIColor.lightGray {
        didSet { setNeedsLayout() }
    }
    
    fileprivate var textLayer: CATextLayer?
    fileprivate var maxAllowedCharCounterLayer: CATextLayer?
    
    public weak var textViewDelegate: TextViewDelegate?
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        delegate = self
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 5
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 1.0
        clipsToBounds = true
        
        if textLayer == nil {
            let temptLayer = CATextLayer()
            temptLayer.contentsScale = UIScreen.main.scale
            
            temptLayer.alignmentMode = CATextLayerAlignmentMode.left
            temptLayer.backgroundColor = UIColor.clear.cgColor
            temptLayer.foregroundColor = placeholderColor.cgColor
            temptLayer.font = font
            temptLayer.fontSize = font?.pointSize ?? 14.0
            
            temptLayer.string = placeholder
            temptLayer.frame = CGRect(origin: CGPoint(x: 5, y: bounds.minY + 8), size: bounds.size)
            layer.insertSublayer(temptLayer, at: 0)
            textLayer = temptLayer
        }
        
        if showTextCounter {
            if maxAllowedCharCounterLayer == nil {
                let tempLayer = CATextLayer()
                tempLayer.contentsScale = UIScreen.main.scale
                tempLayer.alignmentMode = CATextLayerAlignmentMode.right
                tempLayer.backgroundColor = UIColor.clear.cgColor
                tempLayer.foregroundColor = placeholderColor.cgColor
                tempLayer.font = font
                tempLayer.fontSize = font?.pointSize ?? 14.0
                
                let label = UILabel()
                label.text = "\(maxAllowedChar)"
                label.font = font
                label.sizeToFit()
                tempLayer.frame = label.frame
                
                layer.addSublayer(tempLayer)
                maxAllowedCharCounterLayer = tempLayer
            }
            
            if let maxCounterLayer = maxAllowedCharCounterLayer {
                maxCounterLayer.frame.origin = CGPoint(x: bounds.size.width - (maxCounterLayer.bounds.size.width + 5), y: bounds.size.height - maxCounterLayer.bounds.size.height + contentOffset.y)
            }
        }
        delegate?.textViewDidChange?(self)
    }
}

extension TextView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        guard showTextCounter == true else { return }
        
        maxAllowedCharCounterLayer?.string = "\(maxAllowedChar - text.count)"
        textLayer?.isHidden = text.count > 0
        
        if let delegate = textViewDelegate, delegate.responds(to: #selector(TextViewDelegate.textViewDidChange(_:))) {
            delegate.textViewDidChange?(self)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var result: Bool = true
        let oldText = textView.text as NSString
        let newText = oldText.replacingCharacters(in: range, with: text)
        
        if let delegate = textViewDelegate, delegate.responds(to: #selector(TextViewDelegate.textView(_:shouldChangeTextIn:replacementText:))) {
            result = delegate.textView?(self, shouldChangeTextIn: range, replacementText: text) ?? false
        }
        return ((showTextCounter == true) ?
            ((newText.count > maxAllowedChar) ? false : result) :
            result)
    }
}

