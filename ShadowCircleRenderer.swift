//
//  ShadowCircleRenderer.swift
//  ShadowCircleRenderer
//
//  Created by Michal Pyrka on 13/08/2017.
//  Copyright © 2017 Michal Pyrka. All rights reserved.
//

import MapKit

final class ShadowCircleRenderer: MKCircleRenderer {
    
    private enum Constants {
        static let strokeColor = UIColor(red: 25.0/255.0, green: 120.0/255.0, blue: 224.0/255.0, alpha: 1.0)
        static let fillColor = UIColor(red: 25.0/255.0, green: 120.0/255.0, blue: 224.0/255.0, alpha: 0.1)
        static let shadowColor = UIColor(red: 25.0/255.0, green: 120.0/255.0, blue: 224.0/255.0, alpha: 0.6)
        static let lineWidth: CGFloat = 24.0
        static let innerShadowBlur: CGFloat = 360.0
    }
    
    private var multiplier: CGFloat {
        return CGFloat(circle.radius / 100.0)
    }
    
    override init(circle: MKCircle) {
        super.init(circle: circle)
        
        strokeColor = Constants.strokeColor
        fillColor = Constants.fillColor
        lineWidth = Constants.lineWidth
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let mapPoint = MKMapPointForCoordinate(overlay.coordinate)
        let mapPointsPerMeter = circle.radius * MKMapPointsPerMeterAtLatitude(overlay.coordinate.latitude)
        let mapRectCircle = MKMapRect(origin: mapPoint, size: MKMapSize(width: mapPointsPerMeter * 2.0, height: mapPointsPerMeter * 2.0))

        context.setFillColor(Constants.fillColor.cgColor)
        context.setStrokeColor(Constants.strokeColor.cgColor)
        context.setLineWidth(CGFloat(Constants.lineWidth * multiplier))
        context.addArc(center: rect(for: mapRectCircle).origin, radius: CGFloat(mapPointsPerMeter), startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
        context.drawPath(using: .fillStroke)
        setupInnerShadow(in: rect(for: mapRectCircle), context: context)
    }
    
    private func setupInnerShadow(in frame: CGRect, context: CGContext, color: UIColor = Constants.shadowColor) {
        let innerShadowFrame = frame.offsetBy(dx: -frame.size.width / 2.0, dy: -frame.size.height / 2.0)
        let innerShadowPath = UIBezierPath(ovalIn: innerShadowFrame).cgPath
        let opaqueCgColor = opaqueColorWithAlpha(from: color).opaque.cgColor

        context.addPath(innerShadowPath)
        context.setAlpha(opaqueColorWithAlpha(from: color).alpha)
        context.clip()
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        context.setShadow(offset: .zero, blur: Constants.innerShadowBlur * multiplier, color: opaqueCgColor)
        context.setBlendMode(.sourceOut)
        context.setFillColor(opaqueCgColor)
        context.addPath(innerShadowPath)
        context.fillPath()
        context.endTransparencyLayer()
    }
    
    private func opaqueColorWithAlpha(from color: UIColor) -> (alpha: CGFloat, opaque: UIColor) {
        let alpha = color.cgColor.components?.last ?? 1.0
        let components = color.cgColor.components ?? []
        let opaqueColor = UIColor(red: components[safe: 0] ?? 0.0, green: components[safe: 1] ?? 0.0, blue: components[safe: 2] ?? 0.0, alpha: 1.0)
        
        return (alpha, opaqueColor)
    }
}

private extension Collection {
    
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
