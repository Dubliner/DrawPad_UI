//
//  ViewController.swift
//  DrawPad


import UIKit


class ViewController: UIViewController {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    
    var lastPoint = CGPoint.zeroPoint
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var brushWidth: CGFloat = 1.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    /* Contour list: each one is a list of points */
    var contourList: [[CGPoint]] = []
    /* Shape list: recgonized basic shapes (see FitShape.swift)*/
    var shapeList: [Shape] = []
    /* Label list: each one is a label of given stroke */
    var labelList: [ShapeLabel] = []
    /* UI component list: */
    var UIList: [UIComponent] = []
    
    let colors: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func reset(sender: AnyObject) {
        mainImageView.image = nil
    }
    
    @IBAction func share(sender: AnyObject) {
        UIGraphicsBeginImageContext(mainImageView.bounds.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0,
            width: mainImageView.frame.size.width, height: mainImageView.frame.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        presentViewController(activity, animated: true, completion: nil)
    }
    
    @IBAction func pencilPressed(sender: AnyObject) {
        
        var index = sender.tag ?? 0
        if index < 0 || index >= colors.count {
            index = 0
        }
        
        (red, green, blue) = colors[index]
        
        if index == colors.count - 1 {
            opacity = 1.0
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        swiped = false
        if let touch = touches.first as? UITouch {
            lastPoint = touch.locationInView(self.view)
            contourList.append([CGPoint]())
            contourList[contourList.count-1].append(lastPoint)
        }
    }
    
    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        // 1
        //mainImageView (which holds the “drawing so far”) and tempImageView (which holds the “line you’re currently drawing”). Draw into tempImageView, so need to set up a drawing context with the image currently in the tempImageView (which should be empty the first time).
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2 line segment
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        // 3 parameters: color opacity
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        // 4 actually draw the line
        CGContextStrokePath(context)
        
        // 5 do rendering
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        // 6
        swiped = true
        if let touch = touches.first as? UITouch {
            let currentPoint = touch.locationInView(view)
            drawLineFrom(lastPoint, toPoint: currentPoint)
            
            // 7
            lastPoint = currentPoint
            
            // 8
            // contourList.last will return immutable
            contourList[contourList.count-1].append(currentPoint)
            
        }
    }
    
//    func getDist(a: CGPoint, b: CGPoint) -> CGFloat{
//        let xDiffSq = (a.x - b.x)*(a.x - b.x)
//        let yDiffSq = (a.y - b.y)*(a.y - b.y)
//        return sqrt(xDiffSq + yDiffSq)
//    }
    
//    func getTriArea(a: CGPoint, b: CGPoint, c: CGPoint) -> CGFloat{
//
//        let pos = a.x*b.y + b.x*c.y + c.x*a.y
//        let neg = a.x*c.y + c.x*b.y + b.x*a.y
//
//        return (1/2)*abs(pos - neg)
//    }
//    
//    func Visvalingam_Whyatt(strokeOriginList : [CGPoint], nodeCt : Int) -> [CGPoint]{
//        var strokeList : [CGPoint] = strokeOriginList
//        var numRemove : Int = strokeList.count - nodeCt
//        for i in 1...numRemove{
//            var minIndex = 1
//            var minArea = getTriArea(strokeList[0], b:strokeList[1], c:strokeList[2])
//            for e in 2...strokeList.count-2{
//                var currArea = getTriArea(strokeList[e-1], b: strokeList[e], c: strokeList[e+1])
//                if currArea<minArea{
//                    minIndex = e
//                    minArea = currArea
//                }
//            }
//            strokeList.removeAtIndex(minIndex)
//        }
//        return strokeList
//    }
    
//    func fitRectangle(t0:CGPoint, t1:CGPoint, t2:CGPoint, t3:CGPoint)->[CGPoint]{
///* Example: sort CGPoint on x coordinates */
////        var pts = [t0, t1, t2, t3]
////        pts.sort{$0.0.x > $0.1.x
//        var xvals = [t0.x, t1.x, t2.x, t3.x]
//        var yvals = [t0.y, t1.y, t2.y, t3.y]
//        xvals.sort{return $0<$1}
//        yvals.sort{return $0<$1}
//        
//        let yupper = (yvals[0]+yvals[1])/2
//        let ydown  = (yvals[2]+yvals[3])/2
//        let xleft  = (xvals[0]+xvals[1])/2
//        let xright = (xvals[2]+xvals[3])/2
//        
//        let tr0 = CGPoint(x:xleft, y:yupper)
//        let tr1 = CGPoint(x:xright, y:yupper)
//        let tr2 = CGPoint(x:xright, y:ydown)
//        let tr3 = CGPoint(x:xleft, y:ydown)
//        
//        drawLineFrom(tr0, toPoint: tr1)
//        drawLineFrom(tr1, toPoint: tr2)
//        drawLineFrom(tr2, toPoint: tr3)
//        drawLineFrom(tr3, toPoint: tr0)
//        
//        
//        return [tr0, tr1, tr2, tr3]
//    }
    
//    func fitTriangle(t0:CGPoint, t1:CGPoint, t2:CGPoint) -> [CGPoint]{
//        let dist1 = getDist(t0, b:t1)
//        let dist2 = getDist(t1, b:t2)
//        let dist3 = getDist(t2, b:t0)
//        
//        let edgeLen = (dist1 + dist2 + dist3)/3
//        
//        var avgx = (t0.x + t1.x + t2.x)/3
//        var avgy = (t0.y + t1.y + t2.y)/3
//        
//        let R = edgeLen/sqrt(3)
//        let r = R/2
//        
//        let yupper = avgy - r;
//        let ydown = avgy + R;
//        
//        let xleft = avgx - edgeLen/2
//        let xright = avgx + edgeLen/2
//        let xmid = avgx;
//        
//        let leftUp = CGPoint(x:xleft, y:yupper)
//        let rightUp = CGPoint(x:xright, y:yupper)
//        let midDown = CGPoint(x:xmid, y:ydown)
//        
//        drawLineFrom(leftUp, toPoint: rightUp)
//        drawLineFrom(rightUp, toPoint: midDown)
//        drawLineFrom(midDown, toPoint: leftUp)
//        
//        return [leftUp, rightUp, midDown]
//    }
//    
//    func circlefit( data: inout [CGPoint]) -> (x : CGFloat, y: CGFloat, r:CGFloat) {
//        struct Circle {
//            var x : CGFloat = 0
//            var y : CGFloat = 0
//            var r : CGFloat = 0
//            var s: CGFloat = 0, i = 0, j = 0
//        }
//        var circleIni = Circle()
//        for point in data {
//            circleIni.x += point.x
//            circleIni.y += point.y
//        }
//        circleIni.x /= CGFloat(data.count)
//        circleIni.y /= CGFloat(data.count)
//        for point in data {
//            circleIni.r += sqrt(pow(point.x-circleIni.x,2)+pow(point.y-circleIni.y,2))
//        }
//        circleIni.r /= CGFloat(data.count)
//        
//        var LambdaIni : CGFloat = 0.001
//        var code,i,iter,inner : Int
//        var IterMAX = 99
//        var lambda,dx,dy,ri,u,v,Mu,Mv,Muu,Mvv,Muv,Mr,UUl,VVl,Nl,F1,F2,F3,dX,dY,dR,G11,G22,G33,G12,G13,G23,D1,D2,D3 : CGFloat
//        var factorUp : CGFloat = 10, factorDown : CGFloat = 0.04, ParLimit : CGFloat = 1e6, epsilon : CGFloat = 3e-8
//        var Old = Circle(), New = Circle()
//        
//        func Sigma() -> CGFloat {
//            var sum : CGFloat = 0, dx : CGFloat, dy : CGFloat
//            for i in 0..<data.count {
//                dx = data[i].x - New.x
//                dy = data[i].y - New.y
//                sum += pow(sqrt(dx*dx+dy*dy) - New.r,2)
//            }
//            return sqrt(sum/CGFloat(data.count))
//        }
//        New = circleIni
//        New.s = Sigma()
//        lambda = LambdaIni
//        iter = 0; inner = 0; code = 0
//        
//        var NextIteration = true
//        Mu = 0; Mv = 0; Muu = 0; Mvv = 0; Muv = 0; Mr = 0; F1 = 0; F2 = 0; F3 = 0;
//        
//        while true {
//            if (NextIteration) {
//                NextIteration = false;
//                Old = New
//                iter += 1
//                if (iter > IterMAX) {
//                    code = 1
//                    break
//                }
//                
//                
//                for i in 0..<data.count {
//                    dx = data[i].x - Old.x
//                    dy = data[i].y - Old.y
//                    ri = sqrt(dx*dx + dy*dy)
//                    u = dx / ri
//                    v = dy / ri
//                    Mu += u
//                    Mv += v
//                    Muu += u*u
//                    Mvv += v*v
//                    Muv += u*v
//                    Mr += ri
//                }
//                Mu /= CGFloat(data.count)
//                Mv /= CGFloat(data.count)
//                Muu /= CGFloat(data.count)
//                Mvv /= CGFloat(data.count)
//                Muv /= CGFloat(data.count)
//                Mr /= CGFloat(data.count)
//                
//                F1 = Old.x + Old.r*Mu - circleIni.x
//                F2 = Old.y + Old.r*Mv - circleIni.y
//                F3 = Old.r - Mr
//                
//                //Old.g???
//                //try_again()
//                
//            }
//            //func try_again() {
//            UUl = Muu + lambda
//            VVl = Mvv + lambda
//            Nl = lambda + 1
//            
//            G11 = sqrt(UUl)
//            G12 = Muv / G11
//            G13 = Mu / G11
//            G22 = sqrt(VVl - G12 * G12)
//            G23 = (Mv - G12*G13)/G22
//            G33 = sqrt(Nl - G13*G13 - G23*G23)
//            
//            D1 = F1/G11
//            D2 = (F2 - G12*D1)/G22
//            D3 = (F3 - G13*D1 - G23*D2)/G33
//            
//            dR = D3/G33
//            dY = (D2 - G23*dR)/G22
//            dX = (D1 - G12*dY - G13*dR)/G11
//            
//            if ((abs(dR)+abs(dX)+abs(dY))/(1+Old.r) < epsilon) {
//                break
//            }
//            
//            New.x = Old.x - dX
//            New.y = Old.y - dY
//            
//            if (abs(New.x)>ParLimit || abs(New.y)>ParLimit) {
//                code = 3
//                break
//            }
//            
//            New.r = Old.r - dR;
//            
//            if (New.r <= 0)
//            {
//                lambda *= factorUp;
//                inner += 1
//                if (inner > IterMAX) {
//                    code = 2;
//                    break
//                }
//                continue
//            }
//            
//            New.s = Sigma()
//            
//            if (New.s < Old.s) {
//                lambda *= factorDown
//                NextIteration = true
//                continue
//            }
//            else {
//                inner += 1
//                if (inner > IterMAX) {
//                    code = 2
//                    break
//                }
//                lambda *= factorUp
//                continue
//            }
//            
//        }
//        Old.i = iter
//        Old.j = inner
//        //circle = Old
////        drawCircle(x: Old.x,y: Old.y,r: Old.r)
//        
//        
//        return (Old.x,Old.y,Old.r)
//    }
    func drawRect(tr0:CGPoint, tr1:CGPoint, tr2:CGPoint, tr3:CGPoint){
        drawLineFrom(tr0, toPoint: tr1)
        drawLineFrom(tr1, toPoint: tr2)
        drawLineFrom(tr2, toPoint: tr3)
        drawLineFrom(tr3, toPoint: tr0)
    }
    
    func drawTri(leftUp:CGPoint, rightUp:CGPoint, midDown:CGPoint){
        drawLineFrom(leftUp, toPoint: rightUp)
        drawLineFrom(rightUp, toPoint: midDown)
        drawLineFrom(midDown, toPoint: leftUp)
    }
    
    func drawCircle(xcoord: CGFloat, ycoord:CGFloat, r: CGFloat) {
        // 1
        //mainImageView (which holds the “drawing so far”) and tempImageView (which holds the “line you’re currently drawing”). Draw into tempImageView, so need to set up a drawing context with the image currently in the tempImageView (which should be empty the first time).
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        // 2 line segment
        CGContextAddArc(context, xcoord, ycoord, r, CGFloat(0.0), CGFloat(M_PI * 2.0), 1)
        
        // 3 parameters: color opacity
        CGContextSetLineCap(context, kCGLineCapRound)
        CGContextSetLineWidth(context, brushWidth)
        CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        // 4 actually draw the line
        CGContextStrokePath(context)
        
        // 5 do rendering
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
    }
    
    /* append Menu or Textarea to UIList */
    /* return (0:text/1:menu/2:nothing) */
    func MenuOrText(outerShape:Shape, innerShape:Shape)->Int{

        if(contains(outerShape, innerShape)){
            if(innerShape.label==ShapeLabel.Wave){
                UIList.append(UIComponent(myType: UItype.TextArea))
                println("TextArea Found")
                return 0
            }
            if(innerShape.label==ShapeLabel.Triangle){
                UIList.append(UIComponent(myType: UItype.Menu))
                println("Menu Found")
                return 1
            }
        }
        return 2
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        if !swiped {
            contourList[contourList.count-1].append(lastPoint)
            
            // draw a single point
            drawLineFrom(lastPoint, toPoint: lastPoint)
        }
        
        /* 3 Fittings: Rectangle, Triangle, Circle */
        let fivePts :[CGPoint] = Visvalingam_Whyatt(contourList[contourList.count-1], 5)
        let fourPts :[CGPoint] = Visvalingam_Whyatt(contourList[contourList.count-1], 4)
        
        /* Rectangle Vertices: */
        var rectPts:[CGPoint] = fitRectangle(fivePts[0], fivePts[1], fivePts[2], fivePts[3])
        /* Triangle Vertices: */
        var triPts:[CGPoint] = fitTriangle(fourPts[0], fourPts[1], fourPts[2])
        /* Circle Parameters: x, y, r */
        var pointList = contourList[contourList.count-1]
        var circleParams:(CGFloat,CGFloat,CGFloat) = fitCircle(pointList)        
        
        var contour = contourList[contourList.count-1]
        var currLabel:ShapeLabel = fit(contour, triPts, rectPts, circleParams.2, circleParams.0, circleParams.1)
        /* Draw shape & append to shapeList: */
        var currShape:Shape = Shape(vertices:[],label:ShapeLabel.Default)
        var nodes:[CGPoint] = []
        switch currLabel{
            case .Triangle:
                drawTri(triPts[0], rightUp: triPts[1], midDown: triPts[2])
                nodes = [triPts[0], triPts[1], triPts[2]]
                currShape = Shape(vertices:nodes, label:currLabel)
            case .Rectangle:
                drawRect(rectPts[0], tr1: rectPts[1], tr2: rectPts[2], tr3: rectPts[3])
                nodes = [rectPts[0], rectPts[1], rectPts[2], rectPts[3]]
                currShape = Shape(vertices:nodes, label:currLabel)
            case .Circle:
                drawCircle(circleParams.0, ycoord: circleParams.1, r: circleParams.2)
                var center:CGPoint = CGPoint(x:circleParams.0, y:circleParams.1)
                var radius:CGPoint = CGPoint(x:circleParams.2, y:0)
                nodes = [center, radius]
                currShape = Shape(vertices:nodes, label:currLabel)
            case .Line:
                var lineY:CGFloat = (contour[0].y + contour[contour.count-1].y)/2
                var startPoint:CGPoint = CGPoint(x:contour[0].x, y:lineY)
                var endPoint:CGPoint = CGPoint(x:contour[contour.count-1].x, y:lineY)
                nodes = [startPoint, endPoint]
                currShape = Shape(vertices:nodes, label:currLabel)
                drawLineFrom(startPoint, toPoint: endPoint)
            default:
//                drawLineFrom(contour[0], toPoint: contour[contour.count-1])
                nodes = contour
                currShape = Shape(vertices:nodes, label:currLabel)
        }

        
        /* Recognition for Menu or TextArea */
        if(labelList.count>=1){
            var prevLabel:ShapeLabel = labelList[labelList.count-1]
            var prevShape = shapeList[shapeList.count-1]
            
            var prevRect:Bool = prevLabel==ShapeLabel.Rectangle
            var currRect:Bool = currLabel==ShapeLabel.Rectangle
            var ret = 2
//            println(currLabel.rawValue)
            
            /* Recognition for TextArea and Menu */
            if(!(prevLabel==currLabel)){
                if(prevRect){ // only rectangle can contain components
//                    println(prevShape.vertices.count)
//                    println(currShape.vertices.count)
                    var tmp = MenuOrText(prevShape, innerShape:currShape)
                    if(tmp==1 || tmp==0){
                        ret = tmp
                    }
                }
                if(currRect){
                    var tmp = MenuOrText(currShape, innerShape:prevShape)
                    if(tmp==1 || tmp==0){
                        ret = tmp
                    }
                }
//                println(ret)
            }
            
            /* Recognition for CheckBox */
//            var prevCircle:Bool = prevLabel==ShapeLabel.Circle
//            var prevLine:Bool = prevLabel==ShapeLabel.Line
//            var currCircle:Bool = currLabel==ShapeLabel.Circle
//            var currLine:Bool = currLabel==ShapeLabel.Line
//            if(intersect(prevShape.vertices, currShape.vertices)){
//                if( (prevCircle && currLine) || (prevLine && currCircle) ){
//                    UIList.append(UIComponent(myType: UItype.CheckBox))
//                    println("CheckBox Found")
//                }
//            }
            
        }
        

        
        
        shapeList.append(currShape)
        labelList.append(currLabel)
        
        
        /* Do analysis on the labels to get shape */
        
        
//        for strokeInd in 0...contourList.count-1{
//            let strokePtList : [CGPoint] = contourList[strokeInd]
//            for strokePtInd in 0...strokePtList.count-1{
//                println(strokePtList[strokePtInd].x)
//                println(strokePtList[strokePtInd].y)
//            }
//        }
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: 1.0)
        tempImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: kCGBlendModeNormal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let settingsViewController = segue.destinationViewController as! SettingsViewController
        settingsViewController.delegate = self
        settingsViewController.brush = brushWidth
        settingsViewController.opacity = opacity
        settingsViewController.red = red
        settingsViewController.green = green
        settingsViewController.blue = blue
    }
    
}

extension ViewController: SettingsViewControllerDelegate {
    func settingsViewControllerFinished(settingsViewController: SettingsViewController) {
        self.brushWidth = settingsViewController.brush
        self.opacity = settingsViewController.opacity
        self.red = settingsViewController.red
        self.green = settingsViewController.green
        self.blue = settingsViewController.blue
    }
}

