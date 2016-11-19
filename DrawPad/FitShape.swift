//
//  ShapeFitting.swift
//  DrawPad
//
//  Created by ZHEN CHENG WANG on 11/1/16.

/* Contains Geometry related Operations*/
import UIKit
import Foundation

struct Shape{
    var vertices:[CGPoint] = []
    var label: ShapeLabel = ShapeLabel.Default
}

enum ShapeLabel:String{
    case Default = "Default"
    case Rectangle = "Rectangle"
    case Triangle = "Triangle"
    case Circle = "Circle"
    case Wave = "Wave"
    case Line = "Line"
}
    

func getDist(a: CGPoint, b: CGPoint) -> CGFloat{
    let xDiffSq = (a.x - b.x)*(a.x - b.x)
    let yDiffSq = (a.y - b.y)*(a.y - b.y)
    return sqrt(xDiffSq + yDiffSq)
}

func scale(times:CGFloat, vect:CGPoint) ->CGPoint{
    return CGPoint(x: vect.x*times, y: vect.y*times)
}

func sum(vect1:CGPoint, vect2:CGPoint) -> CGPoint{
    return CGPoint(x: vect1.x+vect2.x, y: vect1.y+vect2.y)
}

func diff(pt1:CGPoint, pt2:CGPoint) -> CGPoint{
    return CGPoint(x: pt1.x-pt2.x, y: pt1.y-pt2.y)
}

func dot(vect1:CGPoint, vect2:CGPoint) -> CGFloat{
    return vect1.x*vect2.x + vect1.y*vect2.y;
}

func cross(vect1:CGPoint, vect2:CGPoint) -> CGFloat{
    return vect1.x*vect2.y - vect1.y-vect2.x
}

func getDistPt2Seg(start: CGPoint, end: CGPoint, pt: CGPoint) -> CGFloat{
    let lenSquared = (start.x-end.x)*(start.x-end.x) + (start.y-end.y)*(start.y-end.y)
    if lenSquared==0{
        return getDist(start, pt)
    }
    
    let t = max(0, min(1, dot(diff(pt,start), diff(end,start))/lenSquared))
    let projection = sum(start, scale(t, diff(end, start)))
    return getDist(pt, projection)
}

func getTriArea(a: CGPoint, b: CGPoint, c: CGPoint) -> CGFloat{
    
    let pos = a.x*b.y + b.x*c.y + c.x*a.y
    let neg = a.x*c.y + c.x*b.y + b.x*a.y
    
    return (1/2)*abs(pos - neg)
}

func Visvalingam_Whyatt(strokeOriginList : [CGPoint], nodeCt : Int) -> [CGPoint]{
    var strokeList : [CGPoint] = strokeOriginList
    var numRemove : Int = strokeList.count - nodeCt
    for i in 1...numRemove{
        var minIndex = 1
        var minArea = getTriArea(strokeList[0], strokeList[1], strokeList[2])
        for e in 2...strokeList.count-2{
            var currArea = getTriArea(strokeList[e-1], strokeList[e], strokeList[e+1])
            if currArea<minArea{
                minIndex = e
                minArea = currArea
            }
        }
        strokeList.removeAtIndex(minIndex)
    }
    return strokeList
}

func fitRectangle(t0:CGPoint, t1:CGPoint, t2:CGPoint, t3:CGPoint)->[CGPoint]{
    /* Example: sort CGPoint on x coordinates */
    //        var pts = [t0, t1, t2, t3]
    //        pts.sort{$0.0.x > $0.1.x
    var xvals = [t0.x, t1.x, t2.x, t3.x]
    var yvals = [t0.y, t1.y, t2.y, t3.y]
    xvals.sort{return $0<$1}
    yvals.sort{return $0<$1}
    
    let yupper = (yvals[0]+yvals[1])/2
    let ydown  = (yvals[2]+yvals[3])/2
    let xleft  = (xvals[0]+xvals[1])/2
    let xright = (xvals[2]+xvals[3])/2
    
    let tr0 = CGPoint(x:xleft, y:yupper)
    let tr1 = CGPoint(x:xright, y:yupper)
    let tr2 = CGPoint(x:xright, y:ydown)
    let tr3 = CGPoint(x:xleft, y:ydown)
    
    return [tr0, tr1, tr2, tr3]
}

func fitTriangle(t0:CGPoint, t1:CGPoint, t2:CGPoint) -> [CGPoint]{
    let dist1 = getDist(t0, t1)
    let dist2 = getDist(t1, t2)
    let dist3 = getDist(t2, t0)
    
    let edgeLen = (dist1 + dist2 + dist3)/3
    
    var avgx = (t0.x + t1.x + t2.x)/3
    var avgy = (t0.y + t1.y + t2.y)/3
    
    let R = edgeLen/sqrt(3)
    let r = R/2
    
    let yupper = avgy - r;
    let ydown = avgy + R;
    
    let xleft = avgx - edgeLen/2
    let xright = avgx + edgeLen/2
    let xmid = avgx;
    
    let leftUp = CGPoint(x:xleft, y:yupper)
    let rightUp = CGPoint(x:xright, y:yupper)
    let midDown = CGPoint(x:xmid, y:ydown)
    
    return [leftUp, rightUp, midDown]
}


func fitCircle( data: inout [CGPoint]) -> (x : CGFloat, y: CGFloat, r:CGFloat) {
    struct Circle {
        var x : CGFloat = 0
        var y : CGFloat = 0
        var r : CGFloat = 0
        var s: CGFloat = 0, i = 0, j = 0
    }
    var circleIni = Circle()
    for point in data {
        circleIni.x += point.x
        circleIni.y += point.y
    }
    circleIni.x /= CGFloat(data.count)
    circleIni.y /= CGFloat(data.count)
    for point in data {
        circleIni.r += sqrt(pow(point.x-circleIni.x,2)+pow(point.y-circleIni.y,2))
    }
    circleIni.r /= CGFloat(data.count)
    
    var LambdaIni : CGFloat = 0.001
    var code,i,iter,inner : Int
    var IterMAX = 99
    var lambda,dx,dy,ri,u,v,Mu,Mv,Muu,Mvv,Muv,Mr,UUl,VVl,Nl,F1,F2,F3,dX,dY,dR,G11,G22,G33,G12,G13,G23,D1,D2,D3 : CGFloat
    var factorUp : CGFloat = 10, factorDown : CGFloat = 0.04, ParLimit : CGFloat = 1e6, epsilon : CGFloat = 3e-8
    var Old = Circle(), New = Circle()
    
    func Sigma() -> CGFloat {
        var sum : CGFloat = 0, dx : CGFloat, dy : CGFloat
        for i in 0..<data.count {
            dx = data[i].x - New.x
            dy = data[i].y - New.y
            sum += pow(sqrt(dx*dx+dy*dy) - New.r,2)
        }
        return sqrt(sum/CGFloat(data.count))
    }
    New = circleIni
    New.s = Sigma()
    lambda = LambdaIni
    iter = 0; inner = 0; code = 0
    
    var NextIteration = true
    Mu = 0; Mv = 0; Muu = 0; Mvv = 0; Muv = 0; Mr = 0; F1 = 0; F2 = 0; F3 = 0;
    
    while true {
        if (NextIteration) {
            NextIteration = false;
            Old = New
            iter += 1
            if (iter > IterMAX) {
                code = 1
                break
            }
            
            
            for i in 0..<data.count {
                dx = data[i].x - Old.x
                dy = data[i].y - Old.y
                ri = sqrt(dx*dx + dy*dy)
                u = dx / ri
                v = dy / ri
                Mu += u
                Mv += v
                Muu += u*u
                Mvv += v*v
                Muv += u*v
                Mr += ri
            }
            Mu /= CGFloat(data.count)
            Mv /= CGFloat(data.count)
            Muu /= CGFloat(data.count)
            Mvv /= CGFloat(data.count)
            Muv /= CGFloat(data.count)
            Mr /= CGFloat(data.count)
            
            F1 = Old.x + Old.r*Mu - circleIni.x
            F2 = Old.y + Old.r*Mv - circleIni.y
            F3 = Old.r - Mr
            
        }

        UUl = Muu + lambda
        VVl = Mvv + lambda
        Nl = lambda + 1
        
        G11 = sqrt(UUl)
        G12 = Muv / G11
        G13 = Mu / G11
        G22 = sqrt(VVl - G12 * G12)
        G23 = (Mv - G12*G13)/G22
        G33 = sqrt(Nl - G13*G13 - G23*G23)
        
        D1 = F1/G11
        D2 = (F2 - G12*D1)/G22
        D3 = (F3 - G13*D1 - G23*D2)/G33
        
        dR = D3/G33
        dY = (D2 - G23*dR)/G22
        dX = (D1 - G12*dY - G13*dR)/G11
        
        if ((abs(dR)+abs(dX)+abs(dY))/(1+Old.r) < epsilon) {
            break
        }
        
        New.x = Old.x - dX
        New.y = Old.y - dY
        
        if (abs(New.x)>ParLimit || abs(New.y)>ParLimit) {
            code = 3
            break
        }
        
        New.r = Old.r - dR;
        
        if (New.r <= 0)
        {
            lambda *= factorUp;
            inner += 1
            if (inner > IterMAX) {
                code = 2;
                break
            }
            continue
        }
        
        New.s = Sigma()
        
        if (New.s < Old.s) {
            lambda *= factorDown
            NextIteration = true
            continue
        }
        else {
            inner += 1
            if (inner > IterMAX) {
                code = 2
                break
            }
            lambda *= factorUp
            continue
        }
        
    }
    Old.i = iter
    Old.j = inner

    return (Old.x,Old.y,Old.r)
}

/* Polygon Fitter: */
func fitPolygon(polygon:[CGPoint], contour:[CGPoint]) -> CGFloat{
    var diff:CGFloat = 0
    for i in 0...contour.count-1 {
        var currPt = contour[i]
        var minDiff = getDistPt2Seg(polygon[0], polygon[1], currPt)
        for j in 1...polygon.count-1 {
            var currDiff:CGFloat = 0
            if j==polygon.count-1{
                currDiff = getDistPt2Seg(polygon[j], polygon[0], currPt)
            }
            else{
                currDiff = getDistPt2Seg(polygon[j], polygon[j+1], currPt)
            }
            if currDiff < minDiff{
                minDiff = currDiff
            }
        }
        diff = diff + minDiff
    }
    return diff
}

/* Line Fitter: */
/* 0:wave, 1:straight line */
func fitLine(contour:[CGPoint]) -> ShapeLabel{
    var start = contour[0]
    var end = contour[contour.count-1]
    
    var diff:CGFloat = 0
    for i in 0...contour.count-1{
        diff = diff + getDistPt2Seg(start, end, contour[i])
    }
    
    if diff>getDist(start, end)*2{
        return ShapeLabel.Wave
    }
    else{
        return ShapeLabel.Line
    }
}

/* Circle Fitter: */
func fitCircle(contour:[CGPoint], r:CGFloat, xcoord:CGFloat, ycoord:CGFloat) -> CGFloat{
    var diff:CGFloat = 0
    var center = CGPoint(x:xcoord, y:ycoord)
    for i in 0...contour.count-1{
        diff = diff + abs(getDist(contour[i], center) - r)
    }
    return diff
}

/* The fitting function: */
/* 0:rectangle, 1:triangle, 2:circle, 3:wave, 4:straight line */
func fit(contour:[CGPoint], triFit:[CGPoint], rectFit:[CGPoint], r:CGFloat, x:CGFloat, y:CGFloat) -> ShapeLabel{
    var head2tail = getDist(contour[0], contour[contour.count-1])
    var circum:CGFloat = 0
    for i in 0...contour.count-2{
        circum = circum + getDist(contour[i], contour[i+1])
    }
    
    // circum and head2tail close enough, try fit line
    if(circum < head2tail*3){
        return fitLine(contour)
    }
    
    // try fit rectangle, triangle or circle
    var rectDiff = fitPolygon(rectFit, contour)
    var triDiff = fitPolygon(triFit, contour)
    var circDiff = fitCircle(contour, r, x, y)
    
    var minDiff = min(rectDiff, min(triDiff, circDiff))
    if(rectDiff==minDiff){
        return ShapeLabel.Rectangle
    }
    else if(triDiff==minDiff){
        return ShapeLabel.Triangle
    }
    else{
        return ShapeLabel.Circle
    }
}

