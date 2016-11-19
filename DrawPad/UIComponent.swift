//
//  UIComponents.swift
//  DrawPad
//
//  Created by ZHEN CHENG WANG on 11/4/16.


import Foundation
import UIKit

/* component that passed to preview mode for rendering: label, dimension */
class UIComponent{
    var label: UItype = UItype.Default
    // color 
    // position
    // dimension
    
    
    
    init(myType:UItype){
        self.label = myType
    }
    // the parameters preview mode need
    func setLabel(components:[ShapeLabel])->UItype{
        switch components[0]{
            case .Triangle:
                label = UItype.Menu // position/ h,w, center of triangle
            case .Wave:
                label = UItype.TextArea // postion/ height width
            case .Circle:
                label = UItype.CheckBox // circle params
            default:
                label = UItype.Button // position/ h,w
        }
        return label
    }
}



enum UItype{
    case Default
    case Button
    case Menu
    case TextArea
    case CheckBox
    case Panel    
}