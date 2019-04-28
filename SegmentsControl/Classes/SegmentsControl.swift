//
//  SegmentControl.swift
//  58Spot
//
//  Created by MayerF on 2018/7/2.
//  Copyright © 2018 AFRO. All rights reserved.
//
//  TODO: 1.下划线动画样式
//
//

import UIKit
import Foundation

public typealias kClosureIndexBlock = (Int) -> ()

//MARK: - 分块样式
public enum SegmentStyle {
    /// 均分宽度。根据title个数均分宽度
    case average
    /// 动态宽度。根据字体内容
    case dynamic
    /// 相等宽度。指定每个segment相同宽度
    case equal
}

//MARK: - 内容排列 此种情况只用于 SegmentStyle.dynamic 和 equal 情况。尤其是title所有宽度小于当前控件宽度的时候。是居于哪排列
public enum ContentAlign {
    /// segment靠左排列
    case left
    /// segment优先居中排列
    case center
    /// segment靠右排列
    case right
}

//MARK: - 下划线样式
public enum UnderlineStyle {
    /// 固定宽度
    case fixed
    /// 动态宽度。和字体内容等宽
    case dynamic
}

public class SegmentControl: UIScrollView {
    
    fileprivate let underlineLayer = CALayer()
    fileprivate var titleArray: [String]
    /// 分块所占区域。 目的点击区域
    fileprivate var rectArray: [CGRect] = []
    /// 文本具体区域。目的绘制区域
    fileprivate var titleRectArray: [CGRect] = []
    /// 文本size。根据字体严格宽高
    fileprivate var titleSizeArray: [CGSize] = []
    /// 文本图层集合
    fileprivate var textLayerArray: [CATextLayer] = []
    /// 下划线区域
    fileprivate var underlineRect = CGRect.zero
    /// 当前被选中的segment索引
    fileprivate var selectedIndex = 0
    /// 上一个被选中的索引
    fileprivate var lastSelectedIndex = 0
    
    /// 点击segment回调
    public var selectedBlock: kClosureIndexBlock?
    
    /// 分段样式 均分/动态/等宽
    public var segmentStyle: SegmentStyle = .dynamic {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 内容对齐方式 靠左/居中/靠右
    public var contentAlign: ContentAlign = .left {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 下划线样式 固定/动态
    public var underlineStyle: UnderlineStyle = .fixed {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 文本字体
    public var textFont = UIFont.systemFont(ofSize: 16) {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 文本颜色
    public var textColor = UIColor.black {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 选中的文本颜色
    public var selectedTextColor = UIColor.blue {
        didSet {
            underlineColor = selectedTextColor
            setNeedsDisplay()
        }
    }
    /// 下划线颜色。如果单独配置下划线颜色，注意要放在设置选中文本颜色后面设置。否则会覆盖
    public var underlineColor = UIColor.blue {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 文本间距。用于 SegmentStyle.dynamic 样式
    public var textSpacing = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 下划线宽度。默认20
    public var underlineWidth = 20.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 下划线高度。默认2
    public var underlineHeight = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    /// segment固定宽度
    public var segmentEqualWidth: Double? {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 是否隐藏下划线
    public var isHiddenUnderline = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    //MARK: - init
    public init(titles: [String]) {
        titleArray = titles
        super.init(frame: CGRect())
        
        initCommon()
    }
    fileprivate func initCommon() {
        self.backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        layer.addSublayer(underlineLayer)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private method
extension SegmentControl {
    /// 绘制方法
    override public func draw(_ rect: CGRect) {
        calculate()
        
        for subLayer in textLayerArray {
            subLayer.removeFromSuperlayer()
        }
        textLayerArray = []
        
        for (index, title) in titleArray.enumerated() {
            let rect = titleRectArray[index]
            
            let textLayer = CATextLayer()
            textLayer.frame = rect
            textLayer.string = title
            textLayer.font = textFont
            textLayer.alignmentMode = kCAAlignmentCenter
            textLayer.contentsScale = UIScreen.main.scale;
            textLayer.fontSize = textFont.pointSize
            textLayer.foregroundColor = textColor.cgColor
            
            layer.addSublayer(textLayer)
            textLayerArray.append(textLayer)
        }
        
        // 默认选中第一个
        let textLayer = textLayerArray[selectedIndex]
        textLayer.foregroundColor = selectedTextColor.cgColor
        
        underlineLayer.frame = underlineRect
        underlineLayer.backgroundColor = underlineColor.cgColor
        underlineLayer.isHidden = isHiddenUnderline
    }
    
    /// 计算
    fileprivate func calculate() {
        clearOldData()
        let count = titleArray.count
        
        switch segmentStyle {
        case .average:
            let _ = cacheTitleSize()
            
            let segmentWidth = Double(frame.width) / Double(count)
            let segmentHeight = Double(frame.height)
            
            for index in 0..<count {
                let size = titleSizeArray[index]
                
                let segmentX = Double(index) * segmentWidth
                let segmentY = (segmentHeight - Double(size.height)) / 2
                let rect = CGRect(x: segmentX, y: 0, width: segmentWidth, height: segmentHeight)
                let titleRect = CGRect(x: segmentX, y: segmentY, width: segmentWidth, height: Double(size.height))
                rectArray.append(rect)
                titleRectArray.append(titleRect)
            }
            
        case .equal:
            guard let _ = segmentEqualWidth else {
                assert(false, "请设置'segmentEqualWidth'属性")
                return
            }
            
            let _ = cacheTitleSize()
            let contentWidth = segmentEqualWidth! * Double(count) + (textSpacing * Double(count - 1))
            updateContentSize(contentWidth: contentWidth)
            
            var segmentsWidth = 0.0
            for index in 0..<count {
                let size = titleSizeArray[index]
                let segmentX = segmentPointX(contentWidth: contentWidth, titleWidth: segmentEqualWidth!, segmentsWidth: &segmentsWidth, index: index)
                let segmentY = (Double(frame.height) - Double(size.height)) / 2
                let rect = CGRect(x: segmentX, y: 0, width: segmentEqualWidth!, height: Double(frame.height))
                let titleRect = CGRect(x: segmentX, y: segmentY, width: segmentEqualWidth!, height: Double(size.height))
                rectArray.append(rect)
                titleRectArray.append(titleRect)
            }
            
        case .dynamic:
            let contentWidth = cacheTitleSize()
            updateContentSize(contentWidth: contentWidth)
            
            var segmentsWidth = 0.0
            
            for (index, _) in titleArray.enumerated() {
                let size = titleSizeArray[index]
                let segmentX = segmentPointX(contentWidth: contentWidth, titleWidth: Double(size.width), segmentsWidth: &segmentsWidth, index: index)
                
                let segmentY = (Double(frame.height) - Double(size.height)) / 2
                let rect = CGRect(x: segmentX, y: 0, width: Double(size.width), height: Double(frame.height))
                let titleRect = CGRect(x: segmentX, y: segmentY, width: Double(size.width), height: Double(size.height))
                rectArray.append(rect)
                titleRectArray.append(titleRect)
            }
        }
        
        calculateUnderlineRect()
    }
    
    /// 缓存segment宽度
    ///
    /// - Returns: 返回一个内容总宽度
    fileprivate func cacheTitleSize() -> Double {
        var contentWidth = 0.0
        for title in titleArray {
            let size = title.boundingSize(size: CGSize(width: frame.width, height: frame.height), font: textFont)
            titleSizeArray.append(size)
            contentWidth += Double(size.width)
        }
        
        // 用于 dynamic 模式
        contentWidth += Double((titleArray.count - 1)) * textSpacing
        
        return contentWidth
    }
    
    /// 计算分块的 x 点坐标
    ///
    /// - Parameters:
    ///   - contentWidth: 内容宽度。包括总segment + 总的文本间距
    ///   - titleWidth: 文本所占宽度
    ///   - segmentsWidth: 已经遍历过的文本宽度之和
    /// - Returns: 当前文本的x坐标
    fileprivate func segmentPointX(contentWidth: Double, titleWidth: Double, segmentsWidth: inout Double, index: Int) -> Double {
        var segmentX = 0.0
        
        // 如果内容宽度大于当前视图宽度，则从左侧开始排列
        if contentWidth > Double(frame.width) {
            segmentX = Double(index) * textSpacing + segmentsWidth
            segmentsWidth += titleWidth
            return segmentX
        }
        
        switch contentAlign {
        case .left:
            segmentX = Double(index) * textSpacing + segmentsWidth
            
        case .center:
            segmentX = Double(index) * textSpacing + segmentsWidth + (Double(frame.width) - contentWidth) / 2
            
        case .right:
            segmentX = Double(index) * textSpacing + segmentsWidth + (Double(frame.width) - contentWidth)
            
        }
        
        segmentsWidth += titleWidth
        return segmentX
    }
    
    /// 计算下划线区域
    fileprivate func calculateUnderlineRect() {
        switch underlineStyle {
        case .fixed:
            var underlineW = underlineWidth
            let segmentRect = rectArray[selectedIndex]
            if Double(segmentRect.width) < underlineWidth {
                underlineW = Double(segmentRect.width)
            }
            let underlineX = (Double(segmentRect.width) - underlineW) / 2 + Double(segmentRect.origin.x)
            let underlineY = Double(frame.height) - underlineHeight
            underlineRect = CGRect(x: underlineX, y: underlineY, width: underlineW, height: underlineHeight)
            
        case .dynamic:
            let segmentRect = rectArray[selectedIndex]
            let underlineW = Double(segmentRect.width)
            let underlineX = Double(segmentRect.origin.x)
            let underlineY = Double(frame.height) - underlineHeight
            underlineRect = CGRect(x: underlineX, y: underlineY, width: underlineW, height: underlineHeight)
            
        }
    }
    
    /// 更新contentsize
    fileprivate func updateContentSize(contentWidth: Double) {
        if contentWidth > Double(frame.width) {
            contentSize = CGSize(width: contentWidth, height: Double(frame.height))
        } else {
            contentSize = CGSize(width: Double(frame.width), height: Double(frame.height))
        }
    }
    
    /// 清空旧数据
    fileprivate func clearOldData() {
        rectArray = []
        titleRectArray = []
        titleSizeArray = []
    }
    
}

//MARK: - 对外接口
extension SegmentControl {
    /// 切换索引
    public func switchIndex(_ index: Int) {
        lastSelectedIndex = selectedIndex
        selectedIndex = index
        updateAppear()
    }
    
    public func updateTitles(_ titles: [String]) {
        titleArray = titles
        setNeedsDisplay()
    }
    
}

//MARK: - 点击后的逻辑处理
extension SegmentControl {
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch == nil { return}
        
        let touchPoint = touch!.location(in: self)
        for (index, rect) in rectArray.enumerated() {
            if rect.contains(touchPoint) {
                // 存储上一个选中
                lastSelectedIndex = selectedIndex
                // 更新最新选中
                selectedIndex = index
                updateAppear()
                
                autoScrollSegmentToCenter(touchedIndex: selectedIndex)
                
                if let block = selectedBlock {
                    block(selectedIndex)
                }
                break
            }
        }
    }
    
    /// 更新外观
    /// 考虑更新外观，没必要再进行整体计算。所以不再走 draw() 绘制方法
    fileprivate func updateAppear() {
        // 1.重置上一个选中的layer
        let lastTextLayer = textLayerArray[lastSelectedIndex]
        lastTextLayer.foregroundColor = textColor.cgColor
        
        // 2.更新当前选中layer的外观
        let textLayer = textLayerArray[selectedIndex]
        textLayer.foregroundColor = selectedTextColor.cgColor
        
        // 3.计算下划线区域,且更新下划线布局
        calculateUnderlineRect()
        underlineLayer.frame = underlineRect
        underlineLayer.isHidden = isHiddenUnderline
    }
    
    /// 自动滚动分段至中心
    ///
    /// - Parameter touchedRect: 点击的segment区域
    fileprivate func autoScrollSegmentToCenter(touchedIndex: Int) {
        if segmentStyle == .average { return }
        
        let segmentLayer = textLayerArray[touchedIndex]
        // 最大偏移量
        let maxOffsetX = contentSize.width - frame.width
        // 分段中心点
        let segmentCenterX = Double(segmentLayer.position.x)
        // 当前视图中心点
        let baseCenterX = Double(frame.width)/2
        
        if segmentCenterX > baseCenterX {
            // 理论滚动到中心所需要的偏移量
            var offsetX = segmentCenterX - baseCenterX
            // 实际偏移量
            offsetX = offsetX > Double(maxOffsetX) ? Double(maxOffsetX) : offsetX
            setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            
        } else {
            setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }

    }
    
}

//MARK: - 计算字符串size
extension String {
    func boundingSize(size: CGSize, font: UIFont) -> CGSize {
        let attributes = [NSAttributedStringKey.font: font]
        return (self as NSString).boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
    }
}
