//
//  ShapeStructure.swift
//  DrawPad
//
//  Created by ZHEN CHENG WANG on 11/2/16.
/* The relationship between polygons */

import Foundation
import UIKit

/* Return true if rectangle contains shape */
func contains(outer:Shape, inner:Shape) -> Bool{ // make function call general
    var rect:[CGPoint] = outer.vertices
    var shape:[CGPoint] = inner.vertices
    
    var xvals = [rect[0].x, rect[1].x, rect[2].x, rect[3].x]
    xvals.sort{return $0<$1}
    var yvals = [rect[0].y, rect[1].y, rect[2].y, rect[3].y]
    yvals.sort{return $0<$1}
    
    var xmin = xvals[0]
    var xmax = xvals[3]
    var ymin = yvals[0]
    var ymax = yvals[3]
    
    for i in 0...shape.count-1{
        var xcurr = shape[i].x
        var ycurr = shape[i].y
        
        if(xcurr<xmin || xcurr>xmax || ycurr<ymin || ycurr>ymax){
            return false
        }
    }
    
    return true
}

func segIntersect(p:CGPoint, r:CGPoint, q:CGPoint, s:CGPoint)->Bool{
    var t = cross(diff(q,p),s)/cross(r,s)
    var u = cross(diff(p,q),r)/cross(s,r)
    
    var tmp1 = cross(r,s)==0
    var tmp2 = cross(diff(q,p), r) != 0
    
    // colinear
    if(tmp1 && !tmp2){
        var t0 = dot(diff(q,p),r)/dot(r,r)
        var t1 = t0 + dot(s,r)/dot(r,r)
        var t0inRange = 0<=t0 && t0<=1
        var t1inRange = 0<=t1 && t1<=1
        if(t0inRange || t1inRange){
            return true
        }
        else{
            return false
        }
    }
    
    // parallel
    if(tmp1 && tmp2){
        return false
    }
    
    var tinRange = 0<=t && t<=1
    var uinRange = 0<=u && u<=1
    
    if(!tmp1 && tinRange && uinRange){
        return true
    }
    
    return false
}

/* Return true if two polygon intersected with each other */
func intersect(contour1:[CGPoint], contour2:[CGPoint]) -> Bool{
    
    for i in 0...contour1.count-2{
        for j in 0...contour2.count-2{
            var p:CGPoint = contour1[i]
            var r:CGPoint = diff(contour1[i+1], contour1[i])
            var q:CGPoint = contour2[j]
            var s:CGPoint = diff(contour2[j+1], contour2[j])
            if(segIntersect(p,r,q,s)){
                return true
            }
        }
    }
    
    return false
}