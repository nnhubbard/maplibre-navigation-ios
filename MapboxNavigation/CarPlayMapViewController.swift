import Foundation
import MapLibre
#if canImport(CarPlay)
import CarPlay

@available(iOS 12.0, *)
class CarPlayMapViewController: UIViewController, MLNMapViewDelegate {
    static let defaultAltitude: CLLocationDistance = 16000
    
    /// A very coarse location manager used for distinguishing between daytime and nighttime.
    fileprivate let coarseLocationManager: CLLocationManager = {
        let coarseLocationManager = CLLocationManager()
        coarseLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        return coarseLocationManager
    }()

    var styleManager: StyleManager?
    
    var isOverviewingRoutes: Bool = false
    
    var mapView: NavigationMapView {
        view as! NavigationMapView
    }

    lazy var recenterButton: CPMapButton = {
        let recenterButton = CPMapButton { [weak self] button in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.mapView.setUserTrackingMode(.followWithCourse, animated: true, completionHandler: nil)
            button.isHidden = true
        }
        
        let bundle = Bundle.mapboxNavigation
        recenterButton.image = UIImage(named: "carplay_locate", in: bundle, compatibleWith: traitCollection)
        return recenterButton
    }()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        styleManager = StyleManager(self, dayStyle: DayStyle(demoStyle: ()), nightStyle: NightStyle(demoStyle: ()))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        styleManager = StyleManager(self, dayStyle: DayStyle(demoStyle: ()), nightStyle: NightStyle(demoStyle: ()))
    }
    
    func setCustomMapStyle(with mapStyleURL: URL?) {
        if let mapStyleURL  {
            mapView.styleURL = mapStyleURL
            styleManager = nil
        }
    }

    override func loadView() {
        let mapView = NavigationMapView()
        mapView.delegate = self
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.minimumZoomLevel = 2
        mapView.compassView.isHidden = true
        
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetCamera(animated: false, altitude: CarPlayMapViewController.defaultAltitude)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleManager?.ensureAppropriateStyle()
    }

    public func zoomInButton() -> CPMapButton {
        let zoomInButton = CPMapButton { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.mapView.setZoomLevel(strongSelf.mapView.zoomLevel + 1, animated: true)
            NotificationCenter.default.post(name: Notification.Name("carPlayZoomIn"), object: nil)
        }
        let bundle = Bundle.mapboxNavigation
        zoomInButton.image = UIImage(named: "carplay_plus", in: bundle, compatibleWith: traitCollection)
        return zoomInButton
    }
    
    public func zoomOutButton() -> CPMapButton {
        let zoomInOut = CPMapButton { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.mapView.setZoomLevel(strongSelf.mapView.zoomLevel - 1, animated: true)
            NotificationCenter.default.post(name: Notification.Name("carPlayZoomOut"), object: nil)
        }
        let bundle = Bundle.mapboxNavigation
        zoomInOut.image = UIImage(named: "carplay_minus", in: bundle, compatibleWith: traitCollection)
        return zoomInOut
    }

    // MARK: - MLNMapViewDelegate
    
    func resetCamera(animated: Bool = false, altitude: CLLocationDistance? = nil) {
        let camera = self.mapView.camera
        if let altitude {
            camera.altitude = altitude
        }
        camera.pitch = 40
        self.mapView.setCamera(camera, animated: animated)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        self.mapView.setContentInset(self.mapView.safeAreaInsets, animated: false, completionHandler: nil)
        
        guard self.isOverviewingRoutes else {
            super.viewSafeAreaInsetsDidChange()
            return
        }
        
        guard let routes = mapView.routes,
              let active = routes.first else {
            super.viewSafeAreaInsetsDidChange()
            return
        }
        
        self.mapView.fit(to: active, animated: false)
    }
    
    public func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
        
        let imageAnnotation = annotation as? CarPlayImageAnnotation
        if let image = imageAnnotation?.image, let identifier = imageAnnotation?.identifier {
            
            var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: identifier)

            if annotationImage == nil {
                
                annotationImage = MLNAnnotationImage(image: image, reuseIdentifier:identifier)
                
            }
            
            return annotationImage
            
        }

        return nil

    }
    
}

@available(iOS 12.0, *)
extension CarPlayMapViewController: StyleManagerDelegate {
    func locationFor(styleManager: StyleManager) -> CLLocation? {
        self.mapView.userLocationForCourseTracking ?? self.mapView.userLocation?.location ?? self.coarseLocationManager.location
    }
    
    func styleManager(_ styleManager: StyleManager, didApply style: Style) {
        NotificationCenter.default.post(name: Notification.Name("styleManagerDidApplyStyle"), object: nil, userInfo: ["style": style])
    }
    
    func styleManagerDidRefreshAppearance(_ styleManager: StyleManager) {
        self.mapView.reloadStyle(self)
    }
}
#endif
