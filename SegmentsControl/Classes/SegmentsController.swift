//
//  SegmentsController.swift
//  Pods-SegmentsControl_Example
//
//  Created by MayerF on 2019/8/5.
//

import UIKit

private let kIPhoneX_series: (() -> Bool) = { () -> Bool in
    return (UIScreen.main.bounds.height == 812) || (UIScreen.main.bounds.height == 896)
}

private let kNavBarAndStatusBarHeight:(() -> Float) = { () -> Float in
    let height:Float = kIPhoneX_series() ? 88.0 : 64.0
    return height
}

@objcMembers
open class SegmentsController: UIViewController {

    fileprivate let scrollView = UIScrollView()
    public lazy var segmentControl: SegmentsControl = {
        let control = SegmentsControl(titles: titleArray!)
        return control
    }()
    
    fileprivate var titleArray: [String]?
    fileprivate var childArray: [UIViewController] = []
    fileprivate var selectedIndex = 0
    fileprivate var viewIndex = 0
    fileprivate var selectedClickBlock: kClosureIndexBlock?
    
    public var segmentHeight = 35.0
    public var isScroll = true {
        didSet {
            scrollView.isScrollEnabled = isScroll
        }
    }
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        initCommon()
    }
    
    fileprivate func initCommon() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.alwaysBounceVertical = false
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.bounces = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        // 处理scrollview手势和全屏侧边栏手势冲突
        let gestures = navigationController?.view.gestureRecognizers
        if let _ = gestures {
            for gesture in gestures! {
                if gesture .isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                    scrollView.panGestureRecognizer.require(toFail: gesture)
                }
            }
        }
    }
    
    override open func viewDidLayoutSubviews() {
        var scrollViewOffsetY: Double = 0
        if let _ = titleArray {
            segmentControl.frame = CGRect(x: Double(segmentControl.frame.minX), y: Double(segmentControl.frame.minY), width: Double(view.frame.width), height: segmentHeight)
            scrollViewOffsetY = Double(segmentControl.frame.maxY)
        }
        scrollView.frame = CGRect(x: 0, y: scrollViewOffsetY, width: Double(view.frame.width), height: Double(view.frame.height) - scrollViewOffsetY)
        scrollView.contentSize = CGSize(width: Double(childArray.count) * Double(view.frame.width), height: Double(scrollView.frame.height))
    }
    
    /// 增加视图
    private func addView(index: Int) {
        guard index >= 0 else { return}
        guard index < childArray.count else { return}
        let addedVC = childArray[index]
        if !scrollView.subviews.contains(addedVC.view) {
            let x = Double(index) * Double(view.frame.width)
            addedVC.view.frame = CGRect(x: x, y: 0, width: Double(view.frame.width), height: Double(scrollView.frame.height))
            scrollView.addSubview(addedVC.view)
        }
    }
    
    /// 保留当前显示的视图
    private func saveCurView() {
        let curVC = childArray[selectedIndex]
        for view in scrollView.subviews {
            if view != curVC.view {
                view.removeFromSuperview()
            }
        }
    }
    
    /// 预加载
    private func preAddView() {
        let count = childArray.count
        if count < 3 {
            for index in 0..<count {
                addView(index: index)
            }
            
        } else { // 加载当前页和左右页面
            var leftIndex = selectedIndex - 1
            var rightIndex = selectedIndex + 1
            leftIndex = leftIndex < 0 ? 0 : leftIndex
            rightIndex = rightIndex > count - 1 ? count - 1 : rightIndex
            
            if leftIndex != selectedIndex {
                addView(index: leftIndex)
            }
            
            addView(index: selectedIndex)
            
            if rightIndex != selectedIndex {
                addView(index: rightIndex)
            }
        }
    }
    
}


//MARK: - public api
public extension SegmentsController {
    /// 添加控制器
    func addChildControllers(_ controllers: [UIViewController], titles: [String]?, selectedBlock: kClosureIndexBlock?) {
        guard controllers.count > 0 else { return}
        
        if let _ = titles {
            guard controllers.count == titles!.count else {
                assert(controllers.count == titles!.count, "控制器个数和标题个数不匹配")
                return
            }
        }
        
        childArray = controllers
        titleArray = titles
        selectedClickBlock = selectedBlock
        
        // 添加子控制器
        for controller in controllers {
            addChildViewController(controller)
        }
        addView(index: 0)
        
        if let _ = titles {
            view.addSubview(segmentControl)
            segmentControl.selectedBlock = { [unowned self] (index) in
                self.swtichView(index: index)
            }
            
            var offsetY = 0.0
            if navigationController != nil && !navigationController!.isNavigationBarHidden && navigationController!.navigationBar.isTranslucent {
                offsetY = Double(kNavBarAndStatusBarHeight())
            }
            segmentControl.frame = CGRect(x: 0, y: offsetY, width: Double(view.frame.width), height: segmentHeight)
        }
    }
    
    /// 内部切换视图，避免循环问题
    private func swtichView(index: Int) {
        guard index >= 0 else { return}
        guard index < childArray.count else { return}
        let offsetX = Double(index) * Double(self.view.frame.width);
        self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        
        preAddView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.saveCurView()
        }
    }
    
    /// 外部切换视图
    func switchController(index: Int) {
        guard index >= 0 else { return}
        guard index < childArray.count else { return}
        selectedIndex = index
        let offsetX = Double(index) * Double(self.view.frame.width);
        self.scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
        if let _ = titleArray {
            segmentControl.switchIndex(index)
        }
        
        preAddView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.saveCurView()
        }
    }
    
}

//MARK: - UIScrollViewDelegate
extension SegmentsController: UIScrollViewDelegate {
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        preAddView()
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = Double(view.frame.width)
        let offset = width * Double(selectedIndex)
        let currentX = Double(scrollView.contentOffset.x)
        
        if offset > currentX { //右滑
            if (offset - currentX) >= width/2 {
                selectedIndex -= 1
                selectedIndex = selectedIndex < 0 ? 0 : selectedIndex
                preAddView()
            }
            
        } else { //左滑
            if currentX - offset >= width/2 {
                selectedIndex += 1
                selectedIndex = selectedIndex > childArray.count - 1 ? childArray.count - 1 : selectedIndex
                preAddView()
            }
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        saveCurView()
        if let _ = titleArray {
            segmentControl.switchIndex(selectedIndex)
        }
    
        if let block = selectedClickBlock {
            block(selectedIndex)
        }
    }
}
