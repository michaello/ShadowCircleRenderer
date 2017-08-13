//
//  ViewController.swift
//  ShadowCircleRenderer
//
//  Created by Michal Pyrka on 13/08/2017.
//  Copyright © 2017 Michal Pyrka. All rights reserved.
//

import UIKit
import MapKit

final class ViewController: UIViewController {

    private enum Constants {
        static let minimumKmRangeValue: Float = 1.0
        static let maximumKmRangeValue: Float = 10.0
        static let newYorkCoordinate = CLLocationCoordinate2D(latitude: 40.748817, longitude: -73.985428)
        static let defaultRadius: CLLocationDistance = 1000.0
        static let zoomMultiplier = 1.5
        static let kilometerInMeters = 1000
        static let sliderStackViewHeightConstant: CGFloat = 59.0
        static let sliderMarginConstant: CGFloat = 8.0
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    private let stackView = UIStackView()
    private let sliderStackView = UIStackView()
    private let mapView = MKMapView()
    private let slider = UISlider()
    private let maxRangeLabel = UILabel()
    private var sliderKilometersValue = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
        
    private func setup() {
        setupStackView()
        setupSliderStackView()
        setupMapView()
        setupSlider()
    }
    
    private func setupMapView() {
        let circle = MKCircle(center: Constants.newYorkCoordinate, radius: Constants.defaultRadius)
        mapView.add(circle)
        zoomAtCircle()
        mapView.delegate = self
    }
    
    private func setupStackView() {
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        [mapView, sliderStackView].forEach(stackView.addArrangedSubview)
    }
    
    private func setupSliderStackView() {
        [slider, maxRangeLabel].forEach(sliderStackView.addArrangedSubview)
        sliderStackView.layoutMargins = UIEdgeInsets(top: 0.0, left: Constants.sliderMarginConstant, bottom: 0.0, right: Constants.sliderMarginConstant)
        sliderStackView.isLayoutMarginsRelativeArrangement = true
        NSLayoutConstraint.activate([
            sliderStackView.heightAnchor.constraint(equalToConstant: Constants.sliderStackViewHeightConstant)
        ])
        maxRangeLabel.text = "\(Int(Constants.maximumKmRangeValue)) km"
        sliderStackView.spacing = Constants.sliderMarginConstant
        stackView.axis = .vertical
        stackView.distribution = .fill
    }
    
    private func setupSlider() {
        slider.minimumValue = Constants.minimumKmRangeValue
        slider.maximumValue = Constants.maximumKmRangeValue
        slider.addTarget(self, action: #selector(ViewController.sliderAction(sender:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(ViewController.zoomAtCircle), for: [.touchUpInside, .touchUpOutside])
    }
    
    @objc private func zoomAtCircle() {
        guard let circle = mapView.overlays.first as? MKCircle else { return }
        var selectorRegion = MKCoordinateRegionForMapRect(circle.boundingMapRect)
        selectorRegion.span = MKCoordinateSpan(latitudeDelta: selectorRegion.span.latitudeDelta * Constants.zoomMultiplier, longitudeDelta: selectorRegion.span.longitudeDelta * Constants.zoomMultiplier)
        mapView.setRegion(selectorRegion, animated: true)
    }
    
    @objc private func sliderAction(sender: UISlider) {
        guard Int(sender.value) != sliderKilometersValue else { return }
        sliderKilometersValue = Int(sender.value) * Constants.kilometerInMeters
        let circle = MKCircle(center: Constants.newYorkCoordinate, radius: CLLocationDistance(sliderKilometersValue))
        mapView.removeOverlays(mapView.overlays)
        mapView.add(circle)
    }
}

extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let circleOverlay = overlay as? MKCircle else { fatalError("This demo supports MKCircle only.") }
        
        return ShadowCircleRenderer(circle: circleOverlay)
    }
}
