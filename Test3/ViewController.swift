//
//  ViewController.swift
//  Test3
//
//  Created by Daniel Zollitsch on 27.09.21.
//

import Cocoa
extension NSBezierPath {
    
    public var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        
        for i in 0 ..< elementCount {
            let type = element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo:
                path.move(to: points[0])
            case .lineTo:
                path.addLine(to: points[0])
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
            case .closePath:
                path.closeSubpath()
            @unknown default:
                continue
            }
        }
        
        return path
    }
}
@objc class buttontest : NSObject{
    
    let button = NSButton(frame: CGRect(x: 100, y: 100, width: 150, height: 50))
    @objc func printSomething() {
        print("Hello")
        
        if(NSApp.currentEvent?.type==NSEvent.EventType.leftMouseDragged){
            self.button.frame.origin.x=CGFloat(NSApp.currentEvent?.locationInWindow.x ?? 0)-75.0
            self.button.frame.origin.y=CGFloat(NSApp.currentEvent?.locationInWindow.y ?? 0)-25.0
        }
        self.button.title="changed"
    
    }
    
    func buttoninit(x: Int, y: Int) -> NSButton{
        self.button.title="Test"
        self.button.frame.origin.x=CGFloat(x)
        self.button.frame.origin.y=CGFloat(y)
        self.button.bezelStyle=NSButton.BezelStyle.rounded
        self.button.target=self;
        self.button.identifier=NSUserInterfaceItemIdentifier.init(rawValue: "TEST");
        self.button.sendAction(on: [NSEvent.EventTypeMask.leftMouseUp,NSEvent.EventTypeMask.leftMouseDragged]);
        self.button.action = #selector(self.printSomething)
        return self.button
    }
}
struct marginT {
    var top: Double
    var bottom: Double
    var left: Double
    var right: Double
}

class timelineTool :NSView{
    var totalTime : Double = 0.0;
    //var timeScale : Double = 0.5;
    //var time : Double = 0.0;
    
    struct DynamicVar {
        var current: Double = 0{
            didSet{
                if(setdisplay){
                parentclass.setNeedsDisplay(parentclass.frame);
                }
            }
        };
        var min: Double = 0;
        var max: Double = 50000;
        var parentclass: timelineTool;
        var displayfactor:Double = 0.5; //Units per Pixel
        let setdisplay: Bool;
        init(parent: timelineTool, display: Bool, min: Double, max: Double){
            parentclass=parent;
            setdisplay=display;
            self.min=min;
            self.max=max;
        }
        func inrange()->Int{
            if(self.current>self.max){
                return 1;
            }else
            if(self.current<self.min){
                return -1;
            }else{
                return 0;
            }
            
        }
    }
    var time:DynamicVar?
    var timefactor:DynamicVar?
    class TimeAndScrollValueAnimationLayer: CALayer {
        enum AnimationType {
            case Spring
        }
        enum AnimationTarget: String {
            case Time = "currenttime"
            case Timefactor = "timefactor"
        }
        var animation = CAKeyframeAnimation(keyPath: "currenttime")
        var parentclass:timelineTool?;
        @objc dynamic var currenttime: Double = 0.0{
            didSet {
                parentclass?.time?.current=currenttime;
            }
        };
        @objc dynamic var timefactor: Double = 1.0{
            didSet {
                parentclass?.timefactor?.current=timefactor;
            }
        };
        override init(layer: Any) {
            if let layer = layer as? TimeAndScrollValueAnimationLayer {
                parentclass=layer.parentclass;
                currenttime=layer.currenttime;
                timefactor=layer.timefactor;
            }
            super.init(layer: layer)
        }
        
        
        init(parent: timelineTool){
            parentclass=parent;
            super.init();
            frame=CGRect(x: 0, y: 0, width: 1, height: 1);
        }
        override class func needsDisplay(forKey key: String) -> Bool {
            if key == #keyPath(currenttime) {
                return true
            }
            if key == #keyPath(timefactor) {
                return true
            }
            return super.needsDisplay(forKey: key)
        }
        func stopanimation(target: AnimationTarget){
            removeAnimation(forKey: target.rawValue)
        }
        func animate(type: AnimationType, from: CGFloat, to: CGFloat, duration: CGFloat, target: AnimationTarget){
            
            switch type {
            case AnimationType.Spring:
                
                var springvalues: [CGFloat] = [];
                var timevalues: [NSNumber] = [];
                var amplitude = from-to;
                for n in stride(from: 0, to: 1.0, by: 0.1) {
                    timevalues.append(NSNumber(value: n));
                    springvalues.append(amplitude*cos(1/(2*0.2)*CGFloat.pi*n)*exp((-0.1*1/(2*0.1)*CGFloat.pi*n))+to);
                }
                timevalues.append(0.99);
                springvalues.append(to);
                animation.keyPath=target.rawValue
                animation.keyTimes = timevalues;
                animation.values = springvalues
                animation.calculationMode = CAAnimationCalculationMode.cubic
                animation.duration = duration;
          
                add(animation, forKey: target.rawValue)
            }
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    override var isFlipped: Bool { true };
    var timeruler=timeRulerC();
    var infocolumn=infoColumnC();
    class infoColumnC :CALayer{
        
    }
    class timeRulerC :CALayer{
        let possiblesubdivisions=[5,10,25,50,100,250,500,1000,2500,5000,10000,30000,60000];
        var subdivisions=5.0;
        var parentclass:timelineTool?;
        @objc dynamic var time : Double = 0.0{
            didSet { needsDisplay();
            }
        };
        var margin : marginT = marginT(top: 10.0, bottom: 0.0, left: 10, right: 10);
        
       
      
        
        override init() {
            super.init();
            
            backgroundColor=NSColor.blue.cgColor;
        }
    
        init(parent: timelineTool){
            
            parentclass=parent;
            super.init();
            allowsEdgeAntialiasing=true;
            //frame = NSRect(x: 0, y: 0, width: 300, height: 300);
            backgroundColor=NSColor.blue.cgColor;
            
        }
        override init(layer: Any) {
            super.init(layer: layer)
        }
       
        var unit_numbers_text_layer=CATextLayer();
        var layer_sub_unit_scale = CAShapeLayer()
        override func draw(in ctx: CGContext) {
            super.draw(in: ctx);
            var i:Int=0;
            //var subdivisions=5.0;
            if(parentclass!.timefactor!.current>=parentclass!.timefactor!.min || parentclass!.timefactor!.current<parentclass!.timefactor!.max || parentclass?.zoomphase != HInputState.Animated){
            subdivisions=5.0;
            while(subdivisions*parentclass!.timefactor!.current/parentclass!.time!.displayfactor<10){
                i+=1;
                
                subdivisions=Double(possiblesubdivisions[i]);
                if(i>=possiblesubdivisions.count-1){
                    break;
                }
            }}
            unit_numbers_text_layer.contentsScale=NSScreen.main?.backingScaleFactor ?? 1;
            unit_numbers_text_layer.frame=CGRect(x: 0, y: 0, width: 50, height: 13)
            unit_numbers_text_layer.fontSize=12.0;
            //unit_numbers_text_layer.backgroundColor=NSColor.green.cgColor;
            unit_numbers_text_layer.opacity=1;
            unit_numbers_text_layer.alignmentMode=CATextLayerAlignmentMode.center
            unit_numbers_text_layer.anchorPoint=NSPoint(x:0.5,y:0.5);
            unit_numbers_text_layer.string=String(format:"%.2f",parentclass!.time!.current);
            var offset: Double = 0;
           
            var starttime: Double=parentclass!.time!.current;
            var endpixel: Double=frame.width;
         
            if(parentclass!.time!.current<parentclass!.time!.min){
                offset=(parentclass!.time!.min-parentclass!.time!.current)*parentclass!.timefactor!.current/parentclass!.time!.displayfactor;
                starttime=0;
            }
         
         
            if(parentclass!.time!.current+(frame.width*parentclass!.time!.displayfactor/parentclass!.timefactor!.current)>parentclass!.time!.max){
                endpixel=((parentclass!.time!.max-starttime)*parentclass!.timefactor!.current/parentclass!.time!.displayfactor)+margin.right+offset;
            }
            let startpixel=offset+subdivisions*parentclass!.timefactor!.current/parentclass!.time!.displayfactor-(parentclass!.timefactor!.current*starttime/parentclass!.time!.displayfactor).truncatingRemainder(dividingBy: subdivisions*parentclass!.timefactor!.current/parentclass!.time!.displayfactor);
            
            var pathv = CGMutablePath();
            stride(from: startpixel, to: endpixel, by: subdivisions*parentclass!.timefactor!.current/parentclass!.time!.displayfactor).forEach {
                point in
                pathv.move(to: CGPoint(x: point, y: 30));
                pathv.addLine(to: CGPoint(x: point, y:15));
                //print(point);
            }
            
            layer_sub_unit_scale.strokeColor=NSColor.white.cgColor;
            layer_sub_unit_scale.path=pathv;
            addSublayer(layer_sub_unit_scale);
            // print(parentclass?.currentTime)
            addSublayer(unit_numbers_text_layer);
          
            
        }
        override func display() {
            super.display();
    
        }
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    /*override init(frame frameRect: NSRect) {
     super.init(frame:frameRect);
     }
     
     */    var p1: NSPoint = .zero {
         didSet { needsDisplay = true
         }
     }
    
    @objc func update() {
      
    }
    var p2: NSPoint = NSPoint(x: 100, y: 100) {
        didSet { needsDisplay = true }
    }
    
    // Returns the rect using the two points
    var rect: NSRect {
        NSRect(x: p1.x, y: p1.y,
               width: p2.x - p1.x, height: p2.y - p1.y)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    var timeandscrollanimationlayer:TimeAndScrollValueAnimationLayer?;
    var newlayer=CALayer();
    override var wantsUpdateLayer: Bool { true };
    init(frame frameRect: NSRect, totalTime timev: Double) {
        
        super.init(frame:frameRect);
        time=DynamicVar(parent: self, display: true, min: 0, max: 50000);
        timefactor=DynamicVar(parent: self, display: true, min: 0.1, max: 2);
        timefactor?.current=1.0;
        timeruler=timeRulerC(parent: self);
        wantsLayer=true;
        timeandscrollanimationlayer=TimeAndScrollValueAnimationLayer(parent: self);
        layer?.backgroundColor=NSColor.green.cgColor;
        infocolumn.frame=NSRect(x: 0, y: 0, width: 150, height: frame.height)
        timeruler.frame=NSRect(x: infocolumn.frame.width, y: 0, width: frame.width-infocolumn.frame.width, height: 30);
        let ta = NSTrackingArea(rect: CGRect.zero, options: [.activeAlways, .inVisibleRect, .mouseMoved], owner: self, userInfo: nil)
        addTrackingArea(ta)
        totalTime=timev;
        
        let timer = Timer.init(timeInterval: (60.0/60.0), target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common);
        layer?.addSublayer(newlayer);
        layer?.addSublayer(timeruler);
        layer?.addSublayer(timeandscrollanimationlayer ?? TimeAndScrollValueAnimationLayer(parent: self));
        layerContentsRedrawPolicy = NSView.LayerContentsRedrawPolicy.onSetNeedsDisplay;
        
    }
    func testdraw (){
        
        
        let path = CGMutablePath();
        
        path.addRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        // path.appendRect(NSRect(x: 0, y: 0, width: 200, height: 200))
        shadow = NSShadow();
        
        newlayer.shadowRadius = 5
        newlayer.shadowOpacity = 1
        newlayer.shadowColor = NSColor.white.cgColor
        newlayer.shadowPath=path;
        
        //layer?.shadowPath = path;
        // wantsLayer=true;
        
        /*layer?.shadowRadius = 5
         layer?.shadowOpacity = 1
         layer?.shadowColor = NSColor.white.cgColor*/
        
        
    }
    override func updateLayer() {
        super.updateLayer();
        timeruler.setNeedsDisplay();
        
        print("layer updated");
        testdraw();
        // setNeedsDisplay(frame);
    }
    /* override func draw(_ dirtyRect: NSRect) {
     super.draw(dirtyRect);
     print("drawn");
     
     testdraw();
     }*/
    enum HInputState{
        case None
        case Begin
        case Ended
        case Animated
    }

    var scrollphase: HInputState = HInputState.None;
    var zoomphase: HInputState = HInputState.None;
    override func scrollWheel(with event: NSEvent) {
        if(event.phase==NSEvent.Phase.began){
            scrollphase=HInputState.Begin;
        }
        if(event.phase==NSEvent.Phase.ended){
            scrollphase=HInputState.Ended;
        }
        time!.current-=rubberBandfactor(value: time!.current, min: time!.min, max: time!.max, stiffness: (1/100)*timefactor!.current)*Double(event.scrollingDeltaX*0.2)/timefactor!.current;
        //print(rubberBandfactor(value: time!.current, min: time!.min, max: time!.max, stiffness: (100)*timefactor!.current));
        //print(event);
        if(event.phase != []){
            self.timeandscrollanimationlayer?.stopanimation(target: TimeAndScrollValueAnimationLayer.AnimationTarget.Time);
        }
     
        if(scrollphase==HInputState.Ended){
            if(time!.current<time!.min){
                self.timeandscrollanimationlayer?.animate(type: TimeAndScrollValueAnimationLayer.AnimationType.Spring, from: time!.current, to: time!.min, duration: 2, target: TimeAndScrollValueAnimationLayer.AnimationTarget.Time);
                scrollphase=HInputState.Animated;
            }else if(time!.current>time!.max){
                self.timeandscrollanimationlayer?.animate(type: TimeAndScrollValueAnimationLayer.AnimationType.Spring, from: time!.current, to: time!.max, duration: 2, target: TimeAndScrollValueAnimationLayer.AnimationTarget.Time);
                scrollphase=HInputState.Animated;
            }
        }
    }
    override func mouseMoved(with event: NSEvent) {
        //print(event);
        NSCursor.pointingHand.set()
    }
    override func magnify(with event: NSEvent) {
        print(event);
        if(event.phase==NSEvent.Phase.began){
            zoomphase=HInputState.Begin;
        }
        if(event.phase==NSEvent.Phase.ended){
            zoomphase=HInputState.Ended;
        }
        
        timefactor!.current+=rubberBandfactor(value: timefactor!.current, min: timefactor!.min, max: timefactor!.max, stiffness: 1/30)*Double(event.magnification)*timefactor!.current;
        print(rubberBandfactor(value: timefactor!.current, min: timefactor!.min, max: timefactor!.max, stiffness: 1/30)*Double(event.magnification)*timefactor!.current);
        print(timefactor!.current);
        print(timefactor!.min);
        print(timefactor!.max);
        self.timeandscrollanimationlayer?.stopanimation(target: TimeAndScrollValueAnimationLayer.AnimationTarget.Timefactor);
        if(event.phase==NSEvent.Phase.ended){
            switch (timefactor!.inrange()){
            case -1:
                zoomphase=HInputState.Animated;
                self.timeandscrollanimationlayer?.animate(type: TimeAndScrollValueAnimationLayer.AnimationType.Spring, from: timefactor!.current, to: timefactor!.min, duration: 1, target: TimeAndScrollValueAnimationLayer.AnimationTarget.Timefactor);
        
            case 1:
                zoomphase=HInputState.Animated
                self.timeandscrollanimationlayer?.animate(type: TimeAndScrollValueAnimationLayer.AnimationType.Spring, from: timefactor!.current, to: timefactor!.max, duration: 1, target: TimeAndScrollValueAnimationLayer.AnimationTarget.Timefactor);
             
 
            default:
                1==1
            }
        }
        setNeedsDisplay(frame);
    }
    func rubberBandfactor(value: CGFloat, min: CGFloat, max: CGFloat, stiffness: CGFloat) -> CGFloat {
        if value >= min && value <= max {
            // While we're within range we don't rubber band the value.
            return 1;
        }
  
        // Accepts values from [0...+inf and ensures that f(x) < bandLength for all values.
        let band: (CGFloat) -> CGFloat = { minmax in
            var range=max-min;
            var percentage:Double=0.0;
            if(minmax==0){
                if(min==0.0){
                    percentage=(value/(min+1));
                }else{
                    percentage=(value/min)};
            }
            if(minmax==1){
                if(min==0.0){
                    percentage=(value/(max+1))
                    
                }else{
                    percentage=(value/max)
                }
            }
            print("percent");
            print(percentage);
            return (exp(-(stiffness*100)*abs(percentage)));
        }
        if (value > max) {
            return band(1);
            
        } else if (value < min) {
      
            return band(0);
           
        }
        
        return value;
    }
}










var test=timelineTool(frame: NSRect(x: 200, y: 200, width: 600, height: 400),totalTime: 1.01)
class ViewController: NSViewController {
    
    var animated = false;
   
    /*   @objc func startscroll() {
     print("Scroll Started")
     print(NSApp.currentEvent)
     var val = scrollView.contentView.frame.height
     var val2 = scrollView.documentView?.frame.height ?? 0;
     //   if(scrollView.contentView.bounds.origin.y>0 && scrollView.contentView.bounds.origin.y<=(val2-val)-1 ){
     
     /* NSAnimationContext.runAnimationGroup({ context in
      context.duration = 0.00
      scrollView.contentView.animator().setBoundsOrigin(NSMakePoint(0, scrollView.contentView.bounds.origin.y))
      }) {
      
      }*/
     scrollView.contentView.setBoundsOrigin(NSMakePoint(0, scrollView.contentView.bounds.origin.y))
     //scrollView.contentView.layer?.removeAllAnimations()
     // }
     
     
     //
     
     
     
     }
     @objc func endscroll() {
     print("end")
     
     print(NSApp.currentEvent ?? 0)
     var val = scrollView.contentView.frame.height
     var val2 = scrollView.documentView?.frame.height ?? 0;
     
     
     if(scrollView.contentView.bounds.origin.y>0 && scrollView.contentView.bounds.origin.y<=(val2-val)-1 ){
     
     var offset = scrollView.contentView.bounds.origin.y
     offset = round(offset / 60) * 60;
     NSAnimationContext.runAnimationGroup({ context in
     context.duration = 1
     scrollView.contentView.animator().setBoundsOrigin(NSMakePoint(0, offset))
     }) {
     
     }}
     }*/
    var buttonvar: [buttontest] = []
    private lazy var redBox = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.addSubview(test)
        //  test.testdraw();
        let button2 = NSButton(frame: CGRect(x: 100, y: 100, width: 150, height: 50))
        
        view.addSubview(button2)
        view.addSubview(redBox)
        redBox.wantsLayer = true
        redBox.layer?.backgroundColor = NSColor.red.cgColor
        let shadow=NSShadow();
        shadow.shadowColor=NSColor.green
        shadow.shadowOffset=NSMakeSize(0, 0)
        //shadow.shadowOpacity=1.0
        //shadow.shadowRadius=10
        shadow.shadowBlurRadius=10
        
        
        redBox.shadow = shadow
        //button.init("Test12",self,Selector(printSomething())
        
        buttonvar.append(buttontest());
        buttonvar.append(buttontest());
        
        self.view.addSubview(buttonvar[0].buttoninit(x:100,y:100))
        self.view.addSubview(buttonvar[1].buttoninit(x:300,y:300))
        let slider = NSSlider(frame: CGRect(x: 10, y: 10, width: 100, height: 200))
        slider.minValue=0;
        slider.maxValue=255;
        slider.sliderType=NSSlider.SliderType.linear;
        //slider.action=#selector(startscroll)
        slider.target=self;
        slider.floatValue=50.5
        self.view.addSubview(slider)
        //self.view.addSubview(buttontest().buttoninit())
        // Do any additional setup after loading the view.
        
        
        
        //scrollView.allowsMagnification = true
        //self.view.addSubview(scrollView.initialize())
        
        
        
        
        
        
        
    }
    override func loadView() {
        self.view = NSView(frame: NSRect(x: 0, y: 0, width: NSScreen.main?.frame.width ?? 100, height: NSScreen.main?.frame.height ?? 100))
    }
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
}

