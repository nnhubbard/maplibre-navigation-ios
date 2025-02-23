import Foundation
import MapboxCoreNavigation
import MapboxDirections
import MapLibre
#if canImport(CarPlay)
import CarPlay

/**
 `CarPlayNavigationViewController` is a fully-featured turn-by-turn navigation UI for CarPlay.
 
 - seealso: NavigationViewController
 */
@available(iOS 12.0, *)
@objc(MBCarPlayNavigationViewController)
public class CarPlayNavigationViewController: UIViewController, MLNMapViewDelegate {
    /**
     The view controller’s delegate.
     */
    @objc public weak var carPlayNavigationDelegate: CarPlayNavigationDelegate?
    
    /**
     Provides access to various speech synthesizer options.
     
     See `RouteVoiceController` for more information.
     */
    public var voiceController: RouteVoiceController?
    
    @objc public var drivingSide: DrivingSide = .right
    
    public private(set) var mapView = NavigationMapView()

    var routeController: RouteController
    let shieldHeight: CGFloat = 16
    var mapViewLeftSafeAreaBalancingConstraint: NSLayoutConstraint?
    var mapViewRightSafeAreaBalancingConstraint: NSLayoutConstraint?
    
    var carSession: CPNavigationSession!
    var mapTemplate: CPMapTemplate
    var carFeedbackTemplate: CPGridTemplate?
    var carInterfaceController: CPInterfaceController
    var previousSafeAreaInsets: UIEdgeInsets?

    var styleManager: StyleManager?

    let distanceFormatter = DistanceFormatter(approximate: true)
    
    var edgePadding: UIEdgeInsets {
        let padding: CGFloat = 15
        return UIEdgeInsets(top: view.safeAreaInsets.top + padding,
                            left: view.safeAreaInsets.left + padding,
                            bottom: view.safeAreaInsets.bottom + padding,
                            right: view.safeAreaInsets.right + padding)
    }
    
    /**
     Creates a new CarPlay navigation view controller for the given route controller and user interface.
     
     - parameter routeController: The route controller managing location updates for the navigation session.
     - parameter mapTemplate: The map template visible during the navigation session.
     - parameter interfaceController: The interface controller for CarPlay.
     
     - postcondition: Call `startNavigationSession(for:)` after initializing this object to begin navigation.
     */
    @objc(initForRouteController:mapTemplate:interfaceController:ignoreRouteControllerUpdates:voiceController:)
    public init(for routeController: RouteController,
                mapTemplate: CPMapTemplate,
                interfaceController: CPInterfaceController,
                resetRouteControllerDelegate: Bool = true,
                voiceController: RouteVoiceController = RouteVoiceController()) {
        self.routeController = routeController
        self.mapTemplate = mapTemplate
        self.carInterfaceController = interfaceController
        self.voiceController = voiceController
        super.init(nibName: nil, bundle: nil)

        styleManager = StyleManager(self, dayStyle: DayStyle(demoStyle: ()), nightStyle: NightStyle(demoStyle: ()))

        if resetRouteControllerDelegate {
            routeController.delegate = self
        }

        setupMapView()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCustomMapStyle(with mapStyleURL: URL?) {
        if let mapStyleURL  {
            styleManager = nil
            mapView.styleURL = mapStyleURL
        }
    }

    func setupMapView(showCompass: Bool = false) {
        mapView.compassView.isHidden = !showCompass
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true

        mapView.defaultAltitude = 500
        mapView.zoomedOutMotorwayAltitude = 1000
        mapView.longManeuverDistance = 500
        
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        mapView.frame = view.bounds
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        view.addSubview(mapView)
        
        mapView.navigationMapDelegate = self
        
        // These constraints don’t account for language direction, because the
        // safe area insets are nondirectional and may be affected by the side
        // on which the driver is sitting.
        mapViewRightSafeAreaBalancingConstraint = NSLayoutConstraint(item: mapView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0)
        view.addConstraint(mapViewRightSafeAreaBalancingConstraint!)
        mapViewLeftSafeAreaBalancingConstraint = NSLayoutConstraint(item: mapView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0)
        view.addConstraint(mapViewLeftSafeAreaBalancingConstraint!)
        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))

        self.resumeNotifications()
        self.routeController.resume()
        mapView.recenterMap()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleManager?.ensureAppropriateStyle()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.suspendNotifications()
    }
    
    func resumeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.progressDidChange(_:)), name: .routeControllerProgressDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.rerouted(_:)), name: .routeControllerDidReroute, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.visualInstructionDidChange(_:)), name: .routeControllerDidPassVisualInstructionPoint, object: nil)
    }
    
    func suspendNotifications() {
        NotificationCenter.default.removeObserver(self, name: .routeControllerProgressDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: .routeControllerDidReroute, object: nil)
        NotificationCenter.default.removeObserver(self, name: .routeControllerDidPassVisualInstructionPoint, object: nil)
    }
    
    override public func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if let previousSafeAreaInsets {
            let navigationBarIsOpen = view.safeAreaInsets > previousSafeAreaInsets
            self.mapView.compassView.isHidden = navigationBarIsOpen
        }
        
        previousSafeAreaInsets = view.safeAreaInsets
    }
    
    /**
     Begins a navigation session along the given trip.
     
     - parameter trip: The trip to begin navigating along.
     */
    @objc(startNavigationSessionForTrip:)
    public func startNavigationSession(for trip: CPTrip) {
        self.carSession = self.mapTemplate.startNavigationSession(for: trip)
    }
    
    /**
     Ends the current navigation session.
     
     - parameter canceled: A Boolean value indicating whether this method is being called because the user intends to cancel the trip, as opposed to letting it run to completion.
     */
    @objc(exitNavigationByCanceling:)
    public func exitNavigation(byCanceling canceled: Bool = false) {
        self.carSession.finishTrip()
        dismiss(animated: true, completion: nil)
        self.carPlayNavigationDelegate?.carPlayNavigationViewControllerDidDismiss(self, byCanceling: canceled)
    }
    
    /**
     Shows the interface for providing feedback about the route.
     */
    @objc public func showFeedback() {
        guard let carFeedbackTemplate else { return }
        self.carInterfaceController.pushTemplate(carFeedbackTemplate, animated: true)
    }
    
    /**
     A Boolean value indicating whether the map should follow the user’s location and rotate when the course changes.
     
     When this property is true, the map follows the user’s location and rotates when their course changes. Otherwise, the map shows an overview of the route.
     */
    @objc public var tracksUserCourse: Bool {
        get {
            self.mapView.tracksUserCourse ?? false
        }
        set {
            if !tracksUserCourse, newValue {
                self.mapView.recenterMap()
                self.mapView.addArrow(route: self.routeController.routeProgress.route,
                                       legIndex: self.routeController.routeProgress.legIndex,
                                       stepIndex: self.routeController.routeProgress.currentLegProgress.stepIndex + 1)
            } else if tracksUserCourse, !newValue {
                guard let userLocation = routeController.locationManager.location?.coordinate else {
                    return
                }
                self.mapView.enableFrameByFrameCourseViewTracking(for: 3)
                self.mapView.setOverheadCameraView(from: userLocation, along: self.routeController.routeProgress.route.coordinates!, for: self.edgePadding)
            }
        }
    }
    
    public func beginPanGesture() {
        self.mapView.tracksUserCourse = false
        self.mapView.enableFrameByFrameCourseViewTracking(for: 1)
    }
    
    public func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
        self.mapView.addArrow(route: self.routeController.routeProgress.route, legIndex: self.routeController.routeProgress.legIndex, stepIndex: self.routeController.routeProgress.currentLegProgress.stepIndex + 1)
        self.mapView.showRoutes([self.routeController.routeProgress.route])
        self.mapView.showWaypoints(self.routeController.routeProgress.route)
        self.mapView.recenterMap()
        NotificationCenter.default.post(name: Notification.Name("carPlayNavigationMapViewStyleLoaded"), object: nil)
    }
    
    @objc func visualInstructionDidChange(_ notification: NSNotification) {
        let routeProgress = notification.userInfo![RouteControllerNotificationUserInfoKey.routeProgressKey] as! RouteProgress
        self.updateManeuvers(for: routeProgress)
        self.mapView.showWaypoints(routeProgress.route)
        self.mapView.addArrow(route: routeProgress.route, legIndex: routeProgress.legIndex, stepIndex: routeProgress.currentLegProgress.stepIndex + 1)
    }
    
    @objc func progressDidChange(_ notification: NSNotification) {
        let routeProgress = notification.userInfo![RouteControllerNotificationUserInfoKey.routeProgressKey] as! RouteProgress
        let location = notification.userInfo![RouteControllerNotificationUserInfoKey.locationKey] as! CLLocation
        
        // Update the user puck
        self.mapView.updateCourseTracking(location: location, animated: true)
        
        let congestionLevel = routeProgress.averageCongestionLevelRemainingOnLeg ?? .unknown
        guard let maneuver = carSession.upcomingManeuvers.first else { return }
        
        let legProgress = routeProgress.currentLegProgress
        let legDistance = self.distanceFormatter.measurement(of: legProgress.distanceRemaining)
        let legEstimates = CPTravelEstimates(distanceRemaining: legDistance, timeRemaining: legProgress.durationRemaining)
        self.mapTemplate.update(legEstimates, for: self.carSession.trip, with: congestionLevel.asCPTimeRemainingColor)
        
        let stepProgress = legProgress.currentStepProgress
        let stepDistance = self.distanceFormatter.measurement(of: stepProgress.distanceRemaining)
        let stepEstimates = CPTravelEstimates(distanceRemaining: stepDistance, timeRemaining: stepProgress.durationRemaining)
        self.carSession.updateEstimates(stepEstimates, for: maneuver)
    }
    
    @objc func rerouted(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.updateRouteOnMap()
            self.mapView.recenterMap()
        }
    }
    
    func updateRouteOnMap() {
        self.mapView.addArrow(route: self.routeController.routeProgress.route, legIndex: self.routeController.routeProgress.legIndex, stepIndex: self.routeController.routeProgress.currentLegProgress.stepIndex + 1)
        self.mapView.showRoutes([self.routeController.routeProgress.route], legIndex: self.routeController.routeProgress.legIndex)
        self.mapView.showWaypoints(self.routeController.routeProgress.route, legIndex: self.routeController.routeProgress.legIndex)
    }

    func updateManeuvers(for routeProgress: RouteProgress) {
        guard let visualInstruction = routeProgress.currentLegProgress.currentStepProgress.currentVisualInstruction else { return }
        let step = self.routeController.routeProgress.currentLegProgress.currentStep
        
        let primaryManeuver = CPManeuver()
        let distance = self.distanceFormatter.measurement(of: step.distance)
        primaryManeuver.initialTravelEstimates = CPTravelEstimates(distanceRemaining: distance, timeRemaining: step.expectedTravelTime)
        
        // Just incase, set some default text
        var text = visualInstruction.primaryInstruction.text ?? step.instructions
        if let secondaryText = visualInstruction.secondaryInstruction?.text {
            text += "\n\(secondaryText)"
        }
        primaryManeuver.instructionVariants = [text]
        
        // Add maneuver arrow
        primaryManeuver.symbolSet = visualInstruction.primaryInstruction.maneuverImageSet(side: visualInstruction.drivingSide)
        
        // Estimating the width of Apple's maneuver view
        let bounds: () -> (CGRect) = {
            let widthOfManeuverView = min(self.view.bounds.width - self.view.safeAreaInsets.left, self.view.bounds.width - self.view.safeAreaInsets.right)
            return CGRect(x: 0, y: 0, width: widthOfManeuverView, height: 30)
        }
        
        if let attributedPrimary = visualInstruction.primaryInstruction.maneuverLabelAttributedText(bounds: bounds, shieldHeight: shieldHeight) {
            let instruction = NSMutableAttributedString(attributedString: attributedPrimary)
            
            if let attributedSecondary = visualInstruction.secondaryInstruction?.maneuverLabelAttributedText(bounds: bounds, shieldHeight: shieldHeight) {
                instruction.append(NSAttributedString(string: "\n"))
                instruction.append(attributedSecondary)
            }
            
            instruction.canonicalizeAttachments()
            primaryManeuver.attributedInstructionVariants = [instruction]
        }
        
        var maneuvers: [CPManeuver] = [primaryManeuver]
        
        // Add tertiary text if available. TODO: handle lanes.
        if let tertiaryInstruction = visualInstruction.tertiaryInstruction, !tertiaryInstruction.containsLaneIndications {
            let tertiaryManeuver = CPManeuver()
            tertiaryManeuver.symbolSet = tertiaryInstruction.maneuverImageSet(side: visualInstruction.drivingSide)
            
            if let text = tertiaryInstruction.text {
                tertiaryManeuver.instructionVariants = [text]
            }
            if let attributedTertiary = tertiaryInstruction.maneuverLabelAttributedText(bounds: bounds, shieldHeight: shieldHeight) {
                let attributedTertiary = NSMutableAttributedString(attributedString: attributedTertiary)
                attributedTertiary.canonicalizeAttachments()
                tertiaryManeuver.attributedInstructionVariants = [attributedTertiary]
            }
            
            if let upcomingStep = routeController.routeProgress.currentLegProgress.upComingStep {
                let distance = self.distanceFormatter.measurement(of: upcomingStep.distance)
                tertiaryManeuver.initialTravelEstimates = CPTravelEstimates(distanceRemaining: distance, timeRemaining: upcomingStep.expectedTravelTime)
            }
            
            maneuvers.append(tertiaryManeuver)
        }
        
        self.carSession.upcomingManeuvers = maneuvers
    }
    
    func presentArrivalUI(for waypoint: Waypoint) {
        
        NotificationCenter.default.post(name: Notification.Name("carPlayNavigationArrivalFinal"), object: nil, userInfo: ["waypoint": waypoint])
        
        let primaryAction = CPAlertAction(title: NSLocalizedString("End Navigation", comment: "CarPlay: End navigation button text"), style: .default) { _ in
            self.exitNavigation(byCanceling: true)
            
            if #available(iOS 13.0, *) {
                Task {
                    await self.mapTemplate.dismissNavigationAlert(animated: true)
                }
            }
            
        }
        
        let arrivedTitle = String.localizedStringWithFormat(
            NSLocalizedString("Arrived at %@", comment: "CarPlay: Arrived at geocache"),
            waypoint.name ?? "")
        
        let alert = CPNavigationAlert(titleVariants: [arrivedTitle],
                                      subtitleVariants: [NSLocalizedString("You have arrived at your final geocache.", comment: "CarPlay: Arrived at final geocache")],
                                      image: nil,
                                      primaryAction: primaryAction,
                                      secondaryAction: nil,
                                      duration: 0)
        
        self.mapTemplate.present(navigationAlert: alert, animated: true)
        
    }
    
    func presentWaypointArrivalUI(for waypoint: Waypoint) {
        
        NotificationCenter.default.post(name: Notification.Name("carPlayNavigationArrivalWaypoint"), object: nil, userInfo: ["waypoint": waypoint])
        
        let primaryAction = CPAlertAction(title: NSLocalizedString("Continue", comment: "CarPlay: Continue navigation"), style: .default) { _ in
            self.routeController.routeProgress.legIndex += 1
            if #available(iOS 13.0, *) {
                Task {
                    await self.mapTemplate.dismissNavigationAlert(animated: true)
                }
            }
            self.updateRouteOnMap()
        }
        let secondaryAction = CPAlertAction(title: NSLocalizedString("Log Cache", comment: "CarPlay: Log geocache"), style: .cancel) { _ in
            self.routeController.routeProgress.legIndex += 1
            if #available(iOS 13.0, *) {
                Task {
                    await self.mapTemplate.dismissNavigationAlert(animated: true)
                }
            }
            self.updateRouteOnMap()
        }
        
        let arrivedTitle = String.localizedStringWithFormat(
            NSLocalizedString("Arrived at %@", comment: "CarPlay: Arrived at geocache"),
            waypoint.name ?? "")
        
        let alert = CPNavigationAlert(titleVariants: [arrivedTitle],
                                      subtitleVariants: [NSLocalizedString("You have arrived at a cache on your route.", comment: "CarPlay: Arrived at a geocache on your route")],
                                      image: nil,
                                      primaryAction: primaryAction,
                                      secondaryAction: secondaryAction,
                                      duration: 0)
        
        self.mapTemplate.present(navigationAlert: alert, animated: true)
        
    }
    
    public func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
        
        if let geocacheAnnotation = annotation as? CarPlayImageAnnotation {
            
            if let image = geocacheAnnotation.image, let identifier = geocacheAnnotation.identifier {
                
                var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: identifier)

                if annotationImage == nil {
                    
                    annotationImage = MLNAnnotationImage(image: image, reuseIdentifier:identifier)
                    
                }
                
                return annotationImage
                
            }
            
        }

        return nil

    }
}

@available(iOS 12.0, *)
extension CarPlayNavigationViewController: StyleManagerDelegate {
    public func locationFor(styleManager: StyleManager) -> CLLocation? {
        self.routeController.locationManager.location
    }
    
    public func styleManager(_ styleManager: StyleManager, didApply style: Style) {
        
    }
    
    public func styleManagerDidRefreshAppearance(_ styleManager: StyleManager) {
        self.mapView.reloadStyle(self)
    }
}

@available(iOS 12.0, *)
extension CarPlayNavigationViewController: RouteControllerDelegate {
    public func routeController(_ routeController: RouteController, didArriveAt waypoint: Waypoint) -> Bool {
        if routeController.routeProgress.isFinalLeg {
            self.presentArrivalUI(for: waypoint)
            self.carPlayNavigationDelegate?.carPlayNavigationViewControllerDidArrive(self)
        } else {
            self.presentWaypointArrivalUI(for: waypoint)
        }
        return false
    }
}

/**
 The `CarPlayNavigationDelegate` protocol provides methods for reacting to significant events during turn-by-turn navigation with `CarPlayNavigationViewController`.
 */
@available(iOS 12.0, *)
@objc(MBNavigationCarPlayDelegate)
public protocol CarPlayNavigationDelegate {
    /**
     Called when the CarPlay navigation view controller is dismissed, such as when the user ends a trip.
     
     - parameter carPlayNavigationViewController: The CarPlay navigation view controller that was dismissed.
     - parameter canceled: True if the user dismissed the CarPlay navigation view controller by tapping the Cancel button; false if the navigation view controller dismissed by some other means.
     */
    @objc(carPlayNavigationViewControllerDidDismiss:byCanceling:)
    func carPlayNavigationViewControllerDidDismiss(_ carPlayNavigationViewController: CarPlayNavigationViewController, byCanceling canceled: Bool)

    /**
     Called when the CarPlay navigation view controller detects an arrival.

     - parameter carPlayNavigationViewController: The CarPlay navigation view controller that was dismissed.
     */
    @objc func carPlayNavigationViewControllerDidArrive(_ carPlayNavigationViewController: CarPlayNavigationViewController)
}

@available(iOS 12.0, *)
extension CarPlayNavigationViewController: NavigationMapViewDelegate {
    public func navigationMapViewUserAnchorPoint(_ mapView: NavigationMapView) -> CGPoint {
        // Inset by the content inset to avoid application-defined content.
        var contentFrame = mapView.bounds.inset(by: mapView.contentInset)

        // Avoid letting the puck go partially off-screen, and add a comfortable padding beyond that.
        let courseViewBounds = mapView.userCourseView?.bounds ?? .zero
        contentFrame = contentFrame.insetBy(dx: min(NavigationMapView.courseViewMinimumInsets.left + courseViewBounds.width / 2.0, contentFrame.width / 2.0),
                                            dy: min(NavigationMapView.courseViewMinimumInsets.top + courseViewBounds.height / 2.0, contentFrame.height / 2.0))

        // Get the bottom-center of the remaining frame.
        assert(!contentFrame.isInfinite)
        return CGPoint(x: contentFrame.midX, y: contentFrame.maxY)
    }
}
#endif
