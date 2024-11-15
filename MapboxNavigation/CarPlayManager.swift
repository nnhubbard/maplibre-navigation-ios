#if canImport(CarPlay)
import CarPlay
#if canImport(MapboxGeocoder)
import MapboxGeocoder
#endif
import MapboxCoreNavigation
import MapboxDirections
import Turf

/**
 The activity during which a `CPTemplate` is displayed. This enumeration is used to distinguish between different templates during different phases of user interaction.
 */
@available(iOS 12.0, *)
@objc(MBCarPlayActivity)
public enum CarPlayActivity: Int {
    /// The user is browsing the map or searching for a destination.
    case browsing
    /// The user is previewing a route or selecting among multiple routes.
    case previewing
    /// The user is actively navigating along a route.
    case navigating
}

/**
 `CarPlayManagerDelegate` is the main integration point for Mapbox CarPlay support.
 
 Implement this protocol and assign an instance to the `delegate` property of the shared instance of `CarPlayManager`.
 */
@available(iOS 12.0, *)
@objc(MBCarPlayManagerDelegate)
public protocol CarPlayManagerDelegate {

    var userCourseView: UIView? { get }

    /**
     Offers the delegate an opportunity to provide a customized list of leading bar buttons.
     
     These buttons' tap handlers encapsulate the action to be taken, so it is up to the developer to ensure the hierarchy of templates is adequately navigable.
     If this method is not implemented, or if nil is returned, an implementation of CPSearchTemplate will be provided which uses the Mapbox Geocoder.
     
     - parameter carPlayManager: The shared CarPlay manager.
     - parameter traitCollection: The trait collection of the view controller being shown in the CarPlay window.
     - parameter template: The template into which the returned bar buttons will be inserted.
     - parameter activity: What the user is currently doing on the CarPlay screen. Use this parameter to distinguish between multiple templates of the same kind, such as multiple `CPMapTemplate`s.
     - returns: An array of bar buttons to display on the leading side of the navigation bar while `template` is visible.
     */
    @objc(carPlayManager:leadingNavigationBarButtonsWithTraitCollection:inTemplate:forActivity:)
    optional func carPlayManager(_ carPlayManager: CarPlayManager, leadingNavigationBarButtonsCompatibleWith traitCollection: UITraitCollection, in template: CPTemplate, for activity: CarPlayActivity) -> [CPBarButton]?

    /**
     Offers the delegate an opportunity to provide a customized list of trailing bar buttons.
     
     These buttons' tap handlers encapsulate the action to be taken, so it is up to the developer to ensure the hierarchy of templates is adequately navigable.
     
     - parameter carPlayManager: The shared CarPlay manager.
     - parameter traitCollection: The trait collection of the view controller being shown in the CarPlay window.
     - parameter template: The template into which the returned bar buttons will be inserted.
     - parameter activity: What the user is currently doing on the CarPlay screen. Use this parameter to distinguish between multiple templates of the same kind, such as multiple `CPMapTemplate`s.
     - returns: An array of bar buttons to display on the trailing side of the navigation bar while `template` is visible.
     */
    @objc(carPlayManager:trailingNavigationBarButtonsWithTraitCollection:inTemplate:forActivity:)
    optional func carPlayManager(_ carPlayManager: CarPlayManager, trailingNavigationBarButtonsCompatibleWith traitCollection: UITraitCollection, in template: CPTemplate, for activity: CarPlayActivity) -> [CPBarButton]?

    /**
     Offers the delegate an opportunity to provide a customized list of buttons displayed on the map.
     
     These buttons handle the gestures on the map view, so it is up to the developer to ensure the map template is interactive.
     If this method is not implemented, or if nil is returned, a default set of zoom and pan buttons will be provided.
     
     - parameter carPlayManager: The shared CarPlay manager.
     - parameter traitCollection: The trait collection of the view controller being shown in the CarPlay window.
     - parameter template: The template into which the returned map buttons will be inserted.
     - parameter activity: What the user is currently doing on the CarPlay screen. Use this parameter to distinguish between multiple templates of the same kind, such as multiple `CPMapTemplate`s.
     - returns: An array of map buttons to display on the map while `template` is visible.
     */
    @objc(carPlayManager:mapButtonsCompatibleWithTraitCollection:inTemplate:forActivity:)
    optional func carPlayManager(_ carplayManager: CarPlayManager, mapButtonsCompatibleWith traitCollection: UITraitCollection?, in template: CPTemplate, for activity: CarPlayActivity) -> [CPMapButton]?

    /**
     Offers the delegate an opportunity to provide a way to set customized buttons of the displayed map template of the previewing activity.

     This is a more free way to customize the template with trailing and leading navigatioon bar buttons, map buttons, etc. in one place.
     If this method is not implemented, the template is configured with use of the separate delegate methods for the supported buttons.

     - parameter template: The template to be customized.
     */
    @objc optional func setupPreviewingButtons(of mapTemplate: CPMapTemplate)

    /**
     Offers the delegate an opportunity to provide a way to set customized buttons of the displayed map template of the navigation activity.

     This is a more free way to customize the template with trailing and leading navigatioon bar buttons, map buttons, etc. in one place.
     If this method is not implemented, the template is configured with use of the separate delegate methods for the supported buttons.

     - parameter template: The template to be customized.
     */
    @objc optional func setupNavigatingButtons(of mapTemplate: CPMapTemplate)

    /**
     Offers the delegate an opportunity to provide an alternate navigator, otherwise a default built-in RouteController will be created and used.
     
     - parameter carPlayManager: The shared CarPlay manager.
     - parameter route: The route for which the returned route controller will manage location updates.
     - returns: A route controller that manages location updates along `route`.
     */
    @objc(carPlayManager:routeControllerAlongRoute:)
    optional func carPlayManager(_ carPlayManager: CarPlayManager, routeControllerAlong route: Route) -> RouteController

    /**
     Offers the delegate an opportunity to react to updates in the search text.
     
     - parameter carPlayManager: The shared CarPlay manager.
     - parameter searchTemplate: The search template currently accepting user input.
     - parameter searchText: The updated search text in `searchTemplate`.
     - parameter completionHandler: Called when the search is complete. Accepts a list of search results.
     
     - postcondition: You must call `completionHandler` within this method.
     */
    @objc(carPlayManager:searchTemplate:updatedSearchText:completionHandler:)
    optional func carPlayManager(_ carPlayManager: CarPlayManager, searchTemplate: CPSearchTemplate, updatedSearchText searchText: String, completionHandler: @escaping ([CPListItem]) -> Void)

    /**
     Offers the delegate an opportunity to react to selection of a search result.
     
     - parameter carPlayManager: The shared CarPlay manager.
     - parameter searchTemplate: The search template currently accepting user input.
     - parameter item: The search result the user has selected.
     - parameter completionHandler: Called when the delegate is done responding to the selection.
     
     - postcondition: You must call `completionHandler` within this method.
     */
    @objc(carPlayManager:searchTemplate:selectedResult:completionHandler:)
    optional func carPlayManager(_ carPlayManager: CarPlayManager, searchTemplate: CPSearchTemplate, selectedResult item: CPListItem, completionHandler: @escaping () -> Void)

    /**
     Called when navigation begins so that the containing app can update accordingly.
     
     - parameter carPlayManager: The shared CarPlay manager.
     - parameter routeController: The route controller that has begun managing location updates for a navigation session.
     - parameter navigationController: The CarPLay navigation view controller that controls map and navigation.
     */
    @objc(carPlayManager:didBeginNavigationWithRouteController:andNavigationViewController:)
    func carPlayManager(_ carPlayManager: CarPlayManager, didBeginNavigationWith routeController: RouteController, and navigationController: CarPlayNavigationViewController)

    /**
     Called when navigation ends so that the containing app can update accordingly.
     
     - parameter carPlayManager: The shared CarPlay manager.
     */
    @objc func carPlayManagerDidEndNavigation(_ carPlayManager: CarPlayManager)

    /**
     Called when the carplay manager will disable the idle timer.

     Implementing this method will allow developers to change whether idle timer is disabled when carplay is connected and the vice-versa when disconnected.

     - parameter carPlayManager: The shared CarPlay manager.
     - returns: A Boolean value indicating whether to disable idle timer when carplay is connected and enable when disconnected.
     */
    @objc optional func carplayManagerShouldDisableIdleTimer(_ carPlayManager: CarPlayManager) -> Bool
    
    /**
     Called when the carplay manager begins a pan

     - parameter carPlayManager: The shared CarPlay manager.
     */
    @objc func carPlayManagerDidBeginPan(_ carPlayManager: CarPlayManager)
    
    /**
     Called when the carplay manager ends a pan

     - parameter carPlayManager: The shared CarPlay manager.
     */
    @objc func carPlayManagerDidEndPan(_ carPlayManager: CarPlayManager)
    
    /**
     Called when the map template did appear

     - parameter mapView: The mapView
     */
    @objc func mapTemplateDidAppear(_ mapView: NavigationMapView)
    
    /**
     Called when the map template will appear

     - parameter mapView: The mapView
     */
    @objc func mapTemplateWillAppear(_ mapView: NavigationMapView)
    
    /**
     Called when the map view is added

     - parameter mapView: The mapView
     */
    @objc func mapViewWasAdded(_ mapView: NavigationMapView)

}

/**
 `CarPlayManager` is the main object responsible for orchestrating interactions with a Mapbox map on CarPlay.
 
 You do not create instances of this object yourself; instead, use the `CarPlayManager.shared` class property.
 
 Messages declared in the `CPApplicationDelegate` protocol should be sent to this object in the containing application's application delegate. Implement `CarPlayManagerDelegate` in the containing application and assign an instance to the `delegate` property of the `CarPlayManager` shared instance.
 */
@available(iOS 12.0, *)
@objc(MBCarPlayManager)
public class CarPlayManager: NSObject {
    public static let CarPlayWaypointKey: String = "MBCarPlayWaypoint"

    /**
     The shared CarPlay manager.
     */
    @objc(sharedManager)
    public static var shared = CarPlayManager()

    public var mapStyleURL: URL? {
        didSet {
            mapViewController?.setCustomMapStyle(with: mapStyleURL)
            currentNavigator?.setCustomMapStyle(with: mapStyleURL)
        }
    }

    public var showsCompass: Bool = false

    /**
     Developers should assign their own object as a delegate implementing the CarPlayManagerDelegate protocol for customization.
     */
    @objc public weak var delegate: CarPlayManagerDelegate?

    /**
     If set to `true`, turn-by-turn directions will simulate the user traveling along the selected route when initiated from CarPlay.
     */
    @objc public var simulatesLocations = false

    /**
     This property specifies a multiplier to be applied to the user's speed in simulation mode.
     */
    @objc public var simulatedSpeedMultiplier = 1.0

    /**
     A Boolean value indicating whether the phone is connected to CarPlay.
     */
    @objc public var isConnectedToCarPlay = false
    
    /**
     A Boolean value indicating whether this is the first load of CarPlay.
     */
    @objc public var isFirstLoad = true

    public fileprivate(set) var interfaceController: CPInterfaceController?
    public fileprivate(set) var carWindow: UIWindow?
    public fileprivate(set) var routeController: RouteController?

    public fileprivate(set) var mainMapTemplate: CPMapTemplate?
    public fileprivate(set) weak var currentNavigator: CarPlayNavigationViewController?

    var mapViewController: CarPlayMapViewController? {
        carWindow?.rootViewController as? CarPlayMapViewController
    }

    /**
     The most recent search results.
     */
    var recentSearchItems: [CPListItem]?
    
    /**
     The most recent search text.
     */
    var recentSearchText: String?

    lazy var fullDateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.day, .hour, .minute]
        return formatter
    }()

    lazy var shortDateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.allowedUnits = [.day, .hour, .minute]
        return formatter
    }()

    lazy var briefDateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.day, .hour, .minute]
        return formatter
    }()

    private var defaultMapButtons: [CPMapButton]?

    public static func resetSharedInstance() {
        self.shared = CarPlayManager()
    }

    /**
     Starts a navigation with the gives routeController and the included route.
     */
    @MainActor
    public func startNavigation(with routeController: RouteController) {
        guard
            let interfaceController,
            let carPlayMapViewController = mapViewController
        else {
            return
        }

        let route = routeController.routeProgress.route
        let waypoints = route.routeOptions.waypoints

        let summaryVariants = [
            self.fullDateComponentsFormatter.string(from: route.expectedTravelTime)!,
            self.shortDateComponentsFormatter.string(from: route.expectedTravelTime)!,
            self.briefDateComponentsFormatter.string(from: route.expectedTravelTime)!
        ]
        let routeChoice = CPRouteChoice(summaryVariants: summaryVariants, additionalInformationVariants: [route.description], selectionSummaryVariants: [route.description])
        routeChoice.userInfo = route
        let routeChoices = [routeChoice]

        let originPlacemark = MKPlacemark(coordinate: waypoints.first!.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: waypoints.last!.coordinate, addressDictionary: ["street":  waypoints.last!.name ?? ""])
        let trip = CPTrip(origin: MKMapItem(placemark: originPlacemark), destination: MKMapItem(placemark: destinationPlacemark), routeChoices: routeChoices)

        if interfaceController.templates.count > 1 {
            interfaceController.popToRootTemplate(animated: false)
        }

        if #available(iOS 14.0, *) {
            interfaceController.dismissTemplate(animated: true, completion: nil)
        }

        let navigationMapTemplate = CPMapTemplate()
        interfaceController.setRootTemplate(navigationMapTemplate, animated: true)

        let navigationViewController = CarPlayNavigationViewController(
            for: routeController,
            mapTemplate: navigationMapTemplate,
            interfaceController: interfaceController,
            resetRouteControllerDelegate: false
        )
        if let userCourseView = delegate?.userCourseView {
            navigationViewController.mapView.userCourseView = userCourseView
        }
        navigationViewController.startNavigationSession(for: trip)
        navigationViewController.carPlayNavigationDelegate = self

        navigationViewController.setCustomMapStyle(with: mapStyleURL)
        navigationViewController.setupMapView(showCompass: showsCompass)
        self.currentNavigator = navigationViewController

        setup(mapTemplate: navigationMapTemplate)

        carPlayMapViewController.isOverviewingRoutes = false
        carPlayMapViewController.present(navigationViewController, animated: true, completion: nil)

        self.delegate?.carPlayManager(self, didBeginNavigationWith: routeController, and: navigationViewController)
    }

    func endNavigation() {
        currentNavigator = nil
        delegate?.carPlayManagerDidEndNavigation(self)
    }

    public func showActionSheetAlert(title: String, message: String?) {
        guard let interfaceController else {
            return
        }

        let okAction = CPAlertAction(title: "OK", style: .default) { _ in}
        let actionSheetTemplate = CPActionSheetTemplate(title: title, message: message, actions: [okAction])
        interfaceController.presentTemplate(actionSheetTemplate, animated: true)
    }
}

// MARK: CPApplicationDelegate

@available(iOS 12.0, *)
extension CarPlayManager: CPApplicationDelegate {
    public func application(_ application: UIApplication, didConnectCarInterfaceController interfaceController: CPInterfaceController, to window: CPWindow) {
        self.isConnectedToCarPlay = true
        interfaceController.delegate = self
        self.interfaceController = interfaceController

        if let shouldDisableIdleTimer = delegate?.carplayManagerShouldDisableIdleTimer?(self) {
            UIApplication.shared.isIdleTimerDisabled = shouldDisableIdleTimer
        } else {
            UIApplication.shared.isIdleTimerDisabled = true
        }

        let viewController = CarPlayMapViewController()
        window.rootViewController = viewController
        self.carWindow = window
        
        self.delegate?.mapViewWasAdded(viewController.mapView)

        let mapTemplate = mapTemplate(for: interfaceController, viewController: viewController)
        self.mainMapTemplate = mapTemplate
        self.mainMapTemplate?.automaticallyHidesNavigationBar = false
        interfaceController.setRootTemplate(mapTemplate, animated: false)
    }

    public func application(_ application: UIApplication, didDisconnectCarInterfaceController interfaceController: CPInterfaceController, from window: CPWindow) {
        self.isConnectedToCarPlay = false
        self.interfaceController = nil
        self.carWindow?.isHidden = true

        if let shouldDisableIdleTimer = delegate?.carplayManagerShouldDisableIdleTimer?(self) {
            UIApplication.shared.isIdleTimerDisabled = !shouldDisableIdleTimer
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    func mapTemplate(for interfaceController: CPInterfaceController, viewController: UIViewController) -> CPMapTemplate {
        let traitCollection = viewController.traitCollection

        let mapTemplate = CPMapTemplate()
        mapTemplate.mapDelegate = self

        guard delegate?.setupPreviewingButtons == nil else {
            delegate?.setupPreviewingButtons?(of: mapTemplate)
            return mapTemplate
        }

        if let leadingButtons = delegate?.carPlayManager?(self, leadingNavigationBarButtonsCompatibleWith: traitCollection, in: mapTemplate, for: .browsing) {
            mapTemplate.leadingNavigationBarButtons = leadingButtons
        } else {
            #if canImport(CarPlay) && canImport(MapboxGeocoder)
            let searchTemplate = CPSearchTemplate()
            searchTemplate.delegate = self

            let searchButton = searchTemplateButton(searchTemplate: searchTemplate, interfaceController: interfaceController, traitCollection: traitCollection)
            mapTemplate.leadingNavigationBarButtons = [searchButton]
            #endif
        }

        if let trailingButtons = delegate?.carPlayManager?(self, trailingNavigationBarButtonsCompatibleWith: traitCollection, in: mapTemplate, for: .browsing) {
            mapTemplate.trailingNavigationBarButtons = trailingButtons
        }

        if let mapButtons = delegate?.carPlayManager?(self, mapButtonsCompatibleWith: traitCollection, in: mapTemplate, for: .browsing) {
            mapTemplate.mapButtons = mapButtons
        } else if let vc = viewController as? CarPlayMapViewController {
            mapTemplate.mapButtons = [vc.recenterButton, self.panMapButton(for: mapTemplate, traitCollection: traitCollection), vc.zoomInButton(), vc.zoomOutButton()]
        }

        return mapTemplate
    }

    public func panMapButton(for mapTemplate: CPMapTemplate, traitCollection: UITraitCollection) -> CPMapButton {
        let panButton = CPMapButton { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            if !mapTemplate.isPanningInterfaceVisible {
                strongSelf.defaultMapButtons = mapTemplate.mapButtons
                let closeButton = strongSelf.dismissPanButton(for: mapTemplate, traitCollection: traitCollection)
                mapTemplate.mapButtons = [closeButton]
                mapTemplate.showPanningInterface(animated: true)
            }
        }

        let bundle = Bundle.mapboxNavigation
        panButton.image = UIImage(named: "carplay_pan", in: bundle, compatibleWith: traitCollection)

        return panButton
    }

    func dismissPanButton(for mapTemplate: CPMapTemplate, traitCollection: UITraitCollection) -> CPMapButton {
        let closeButton = CPMapButton { [weak self] _ in
            self?.resetPanButtons(mapTemplate)
        }

        let bundle = Bundle.mapboxNavigation
        closeButton.image = UIImage(named: "carplay_close", in: bundle, compatibleWith: traitCollection)

        return closeButton
    }

    func resetPanButtons(_ mapTemplate: CPMapTemplate) {
        guard let mapButtons = defaultMapButtons else {
            return
        }

        mapTemplate.mapButtons = mapButtons
        mapTemplate.dismissPanningInterface(animated: false)
    }
}

// MARK: CPInterfaceControllerDelegate

@available(iOS 12.0, *)
extension CarPlayManager: CPInterfaceControllerDelegate {
    public func templateWillAppear(_ template: CPTemplate, animated: Bool) {
        
        if template == self.interfaceController?.rootTemplate, let carPlayMapViewController = mapViewController {
            mapViewController?.recenterButton.isHidden = true
            
            let mapView = carPlayMapViewController.mapView
            mapView.removeRoutes()
            mapView.removeWaypoints()
            if isFirstLoad {
                
                mapView.setUserTrackingMode(.followWithCourse, animated: true, completionHandler: nil)
                isFirstLoad = false
                
            }
            
            self.delegate?.mapTemplateWillAppear(mapView)
            
        }

        if let mapTemplate = template as? CPMapTemplate {
            resetPanButtons(mapTemplate)
        }
        
    }
    
    public func templateDidAppear(_ template: CPTemplate, animated: Bool) {
        guard self.interfaceController?.topTemplate == self.mainMapTemplate else { return }
        if template == self.interfaceController?.rootTemplate, let carPlayMapViewController = mapViewController {
            let mapView = carPlayMapViewController.mapView
            self.delegate?.mapTemplateDidAppear(mapView)
        }
    }

    public func templateWillDisappear(_ template: CPTemplate, animated: Bool) {
        let isCorrectType = type(of: template) == CPSearchTemplate.self || type(of: template) == CPMapTemplate.self

        guard let interface = interfaceController, let top = interface.topTemplate,
              type(of: top) == CPSearchTemplate.self || interface.templates.count == 1,
              isCorrectType,
              let carPlayMapViewController = mapViewController else { return }
        if type(of: template) == CPSearchTemplate.self {
            carPlayMapViewController.isOverviewingRoutes = false
        }
        carPlayMapViewController.resetCamera(animated: false)
    }
}

// MARK: CPListTemplateDelegate

@available(iOS 12.0, *)
extension CarPlayManager: CPListTemplateDelegate {
    public func listTemplate(_ listTemplate: CPListTemplate, didSelect item: CPListItem, completionHandler: @escaping () -> Void) {
        // Selected a search item from the extended list?
        #if canImport(CarPlay) && canImport(MapboxGeocoder)
        if let userInfo = item.userInfo as? [String: Any],
           let placemark = userInfo[CarPlayManager.CarPlayGeocodedPlacemarkKey] as? GeocodedPlacemark,
           let location = placemark.location {
            let destinationWaypoint = Waypoint(location: location)
            self.interfaceController?.popTemplate(animated: false)
            self.calculateRouteAndStart(to: destinationWaypoint, completionHandler: completionHandler)
            return
        }
        #endif
        
        // Selected a favorite? or any item with a waypoint.
        if let userInfo = item.userInfo as? [String: Any],
           let waypoint = userInfo[CarPlayManager.CarPlayWaypointKey] as? Waypoint {
            self.calculateRouteAndStart(to: waypoint, completionHandler: completionHandler)
            return
        }
        
        completionHandler()
    }

    public func calculateRouteAndStart(from fromWaypoint: Waypoint? = nil, to toWaypoint: Waypoint, waypoints routeWaypoints: [Waypoint]? = nil, completionHandler: @escaping () -> Void) {
        guard let rootViewController = mapViewController,
              let mapTemplate = interfaceController?.rootTemplate as? CPMapTemplate,
              let userLocation = rootViewController.mapView.userLocation,
              let location = userLocation.location,
              let interfaceController else {
            completionHandler()
            return
        }

        let name = NSLocalizedString("CARPLAY_CURRENT_LOCATION", bundle: .mapboxNavigation, value: "Current Location", comment: "Name of the waypoint associated with the current location")
        let originWaypoint = fromWaypoint ?? Waypoint(location: location, heading: userLocation.heading, name: name)

        let routeOptions = routeWaypoints != nil ? NavigationRouteOptions(waypoints: routeWaypoints!) : NavigationRouteOptions(waypoints: [originWaypoint, toWaypoint])
        routeOptions.profileIdentifier = .automobile
        routeOptions.shapeFormat = .polyline6
        
        Directions.shared.calculate(routeOptions) { [weak self, weak mapTemplate] waypoints, routes, error in
            defer {
                completionHandler()
            }

            guard let self, let mapTemplate else {
                return
            }
            if error != nil {
                
                showActionSheetAlert(title: NSLocalizedString("Directions Error", comment:"CarPlay directions error"), message: error?.localizedDescription)
                
            }
            guard let waypoints, let routes else {
                return
            }
            
            // Updated the additional information to use the cache code
            var additionalInformation = "";
            if let cacheCode = toWaypoint.userInfo?["cacheCode"] {
                additionalInformation = cacheCode
            }
            if let waypoints = routeWaypoints {
                
                var cacheCodes = [String]()
                for waypoint in waypoints {
                    
                    if let cacheCode = waypoint.userInfo?["cacheCode"] {
                        
                        cacheCodes.append(cacheCode)
                        
                    }
                    
                }
                if cacheCodes.count > 0 {
                    additionalInformation = cacheCodes.joined(separator: ", ")
                }
               
            }

            let routeChoices = routes.map { route -> CPRouteChoice in
                let summaryVariants = [
                    self.fullDateComponentsFormatter.string(from: route.expectedTravelTime)!,
                    self.shortDateComponentsFormatter.string(from: route.expectedTravelTime)!,
                    self.briefDateComponentsFormatter.string(from: route.expectedTravelTime)!
                ]
                
                let routeChoice = CPRouteChoice(summaryVariants: summaryVariants, additionalInformationVariants: [additionalInformation], selectionSummaryVariants: [route.description])
                routeChoice.userInfo = route
                return routeChoice
            }

            let originPlacemark = MKPlacemark(coordinate: waypoints.first!.coordinate)
            let destinationPlacemark = MKPlacemark(coordinate: waypoints.last!.coordinate, addressDictionary: ["street": waypoints.last!.name ?? ""])
            let trip = CPTrip(origin: MKMapItem(placemark: originPlacemark), destination: MKMapItem(placemark: destinationPlacemark), routeChoices: routeChoices)
            trip.userInfo = routeOptions

            let goTitle = NSLocalizedString("Start", comment: "Start CarPlay route navigation")
            let alternativeRoutesTitle = NSLocalizedString("CARPLAY_MORE_ROUTES", bundle: .mapboxNavigation, value: "More Routes", comment: "Title for alternative routes in CPTripPreviewTextConfiguration")
            let overviewTitle = NSLocalizedString("CARPLAY_OVERVIEW", bundle: .mapboxNavigation, value: "Overview", comment: "Title for overview button in CPTripPreviewTextConfiguration")
            let defaultPreviewText = CPTripPreviewTextConfiguration(startButtonTitle: goTitle, additionalRoutesButtonTitle: alternativeRoutesTitle, overviewButtonTitle: overviewTitle)

            let previewMapTemplate = self.mapTemplate(forPreviewing: trip)
            previewMapTemplate.showTripPreviews([trip], textConfiguration: defaultPreviewText)
            interfaceController.pushTemplate(previewMapTemplate, animated: true)
            
        }
    }

    func mapTemplate(forPreviewing trip: CPTrip) -> CPMapTemplate {
        let rootViewController = self.carWindow?.rootViewController as! CarPlayMapViewController
        let mapTemplate = CPMapTemplate()
        mapTemplate.mapDelegate = self
        if let leadingButtons = delegate?.carPlayManager?(self, leadingNavigationBarButtonsCompatibleWith: rootViewController.traitCollection, in: mapTemplate, for: .previewing) {
            mapTemplate.leadingNavigationBarButtons = leadingButtons
        }
        if let trailingButtons = delegate?.carPlayManager?(self, trailingNavigationBarButtonsCompatibleWith: rootViewController.traitCollection, in: mapTemplate, for: .previewing) {
            mapTemplate.trailingNavigationBarButtons = trailingButtons
        }
        return mapTemplate
    }
}

// MARK: CPMapTemplateDelegate

@available(iOS 12.0, *)
extension CarPlayManager: CPMapTemplateDelegate {
    public func mapTemplate(_ mapTemplate: CPMapTemplate, startedTrip trip: CPTrip, using routeChoice: CPRouteChoice) {
        guard let interfaceController,
              let carPlayMapViewController = mapViewController else {
            return
        }

        mapTemplate.hideTripPreviews()

        let route = routeChoice.userInfo as! Route
        let routeController: RouteController = if let routeControllerFromDelegate = delegate?.carPlayManager?(self, routeControllerAlong: route) {
            routeControllerFromDelegate
        } else {
            self.createRouteController(with: route)
        }

        if interfaceController.templates.count > 1 {
            interfaceController.popToRootTemplate(animated: false)
        }

        if #available(iOS 14.0, *) {
            interfaceController.dismissTemplate(animated: true, completion: nil)
        }

        let navigationMapTemplate = CPMapTemplate()
        interfaceController.setRootTemplate(navigationMapTemplate, animated: true)

        let navigationViewController = CarPlayNavigationViewController(for: routeController,
                                                                       mapTemplate: navigationMapTemplate,
                                                                       interfaceController: interfaceController)
        if let userCourseView = delegate?.userCourseView  {
            navigationViewController.mapView.userCourseView = userCourseView
        }
        navigationViewController.startNavigationSession(for: trip)
        navigationViewController.carPlayNavigationDelegate = self
        navigationViewController.setCustomMapStyle(with: mapStyleURL)
        self.currentNavigator = navigationViewController

        setup(mapTemplate: navigationMapTemplate)
        
        carPlayMapViewController.isOverviewingRoutes = false
        carPlayMapViewController.present(navigationViewController, animated: true, completion: nil)

        let mapView = carPlayMapViewController.mapView
        mapView.removeRoutes()
        mapView.removeWaypoints()

        self.delegate?.carPlayManager(self, didBeginNavigationWith: routeController, and: navigationViewController)
    }

    func setup(mapTemplate: CPMapTemplate) {
        mapTemplate.mapDelegate = self

        guard delegate?.setupNavigatingButtons == nil else {
            delegate?.setupNavigatingButtons?(of: mapTemplate)
            return
        }

        let traitCollection = currentNavigator?.traitCollection

        if let mapButtons = delegate?.carPlayManager?(self, mapButtonsCompatibleWith: traitCollection, in: mapTemplate, for: .navigating) {
            mapTemplate.mapButtons = mapButtons
        } else {
            let overviewButton = CPMapButton { [weak self] button in
                guard let navigationViewController = self?.currentNavigator else {
                    return
                }
                navigationViewController.tracksUserCourse = !navigationViewController.tracksUserCourse

                let imageName = navigationViewController.tracksUserCourse ? "carplay_overview" : "carplay_locate"
                button.image = UIImage(named: imageName, in: .mapboxNavigation, compatibleWith: nil)
            }
            overviewButton.image = UIImage(named: "carplay_overview", in: .mapboxNavigation, compatibleWith: nil)
            mapTemplate.mapButtons.append(overviewButton)

            if self.currentNavigator?.carFeedbackTemplate != nil {
                let showFeedbackButton = CPMapButton { [weak self] _ in
                    self?.currentNavigator?.showFeedback()
                }
                showFeedbackButton.image = UIImage(named: "carplay_feedback", in: .mapboxNavigation, compatibleWith: nil)
                mapTemplate.mapButtons.append(showFeedbackButton)
            }
        }

        if let rootViewController = mapViewController,
           let leadingButtons = delegate?.carPlayManager?(self, leadingNavigationBarButtonsCompatibleWith: rootViewController.traitCollection, in: mapTemplate, for: .navigating) {
            mapTemplate.leadingNavigationBarButtons = leadingButtons
        } else {
            let muteTitle = NSLocalizedString("CARPLAY_MUTE", bundle: .mapboxNavigation, value: "Mute", comment: "Title for mute button")
            let unmuteTitle = NSLocalizedString("CARPLAY_UNMUTE", bundle: .mapboxNavigation, value: "Unmute", comment: "Title for unmute button")

            let muteButton = CPBarButton(type: .text) { (button: CPBarButton) in
                NavigationSettings.shared.voiceMuted = !NavigationSettings.shared.voiceMuted
                button.title = NavigationSettings.shared.voiceMuted ? unmuteTitle : muteTitle
            }
            muteButton.title = NavigationSettings.shared.voiceMuted ? unmuteTitle : muteTitle
            mapTemplate.leadingNavigationBarButtons = [muteButton]
        }

        if let rootViewController = mapViewController,
           let trailingButtons = delegate?.carPlayManager?(self, trailingNavigationBarButtonsCompatibleWith: rootViewController.traitCollection, in: mapTemplate, for: .navigating) {
            mapTemplate.trailingNavigationBarButtons = trailingButtons
        }
        else {
            let exitButton = CPBarButton(type: .text) { [weak self] (_: CPBarButton) in
                self?.currentNavigator?.exitNavigation(byCanceling: true)
            }
            exitButton.title = NSLocalizedString("CARPLAY_END", bundle: .mapboxNavigation, value: "End", comment: "Title for end navigation button")
            mapTemplate.trailingNavigationBarButtons = [exitButton]
        }
    }

    public func mapTemplate(_ mapTemplate: CPMapTemplate, selectedPreviewFor trip: CPTrip, using routeChoice: CPRouteChoice) {
        guard let carPlayMapViewController = mapViewController else {
            return
        }
        carPlayMapViewController.isOverviewingRoutes = true
        let mapView = carPlayMapViewController.mapView
        let route = routeChoice.userInfo as! Route

        // FIXME: Unable to tilt map during route selection -- https://github.com/mapbox/mapbox-gl-native/issues/2259
        let topDownCamera = mapView.camera
        topDownCamera.pitch = 0
        mapView.setCamera(topDownCamera, animated: false)

        let padding = NavigationMapView.defaultPadding + mapView.safeAreaInsets
        mapView.showcase([route], padding: padding)
    }

    public func mapTemplateDidCancelNavigation(_ mapTemplate: CPMapTemplate) {
        guard let carPlayMapViewController = mapViewController else {
            return
        }
        let mapView = carPlayMapViewController.mapView
        mapView.removeRoutes()
        mapView.removeWaypoints()
        endNavigation()
    }

    public func mapTemplateDidBeginPanGesture(_ mapTemplate: CPMapTemplate) {
        if let navigationViewController = currentNavigator, mapTemplate == navigationViewController.mapTemplate {
            navigationViewController.beginPanGesture()
            self.delegate?.carPlayManagerDidBeginPan(self)
        }
    }
    
    public func mapTemplate(_ mapTemplate: CPMapTemplate, didEndPanGestureWithVelocity velocity: CGPoint) {
        if mapTemplate == self.interfaceController?.rootTemplate, let carPlayMapViewController = mapViewController {
            carPlayMapViewController.recenterButton.isHidden = carPlayMapViewController.mapView.userTrackingMode != .none
        }
        
        self.delegate?.carPlayManagerDidEndPan(self)

        // We want the panning surface to have "friction". If the user did not "flick" fast/hard enough, do not update the map with a final animation.
        guard sqrtf(Float(velocity.x * velocity.x + velocity.y * velocity.y)) > 100 else {
            return
        }
        
        let decelerationRate: CGFloat = 0.9
        let offset = CGPoint(x: velocity.x * decelerationRate / 4, y: velocity.y * decelerationRate / 4)
        self.updatePan(by: offset, mapTemplate: mapTemplate, animated: true)
    }
    
    public func mapTemplateWillDismissPanningInterface(_ mapTemplate: CPMapTemplate) {
        guard let carPlayMapViewController = mapViewController else {
            return
        }
        
        let mode = carPlayMapViewController.mapView.userTrackingMode
        carPlayMapViewController.recenterButton.isHidden = mode != .none
    }

    public func mapTemplate(_ mapTemplate: CPMapTemplate, didUpdatePanGestureWithTranslation translation: CGPoint, velocity: CGPoint) {
        let mapView: NavigationMapView
        if let navigationViewController = currentNavigator, mapTemplate == navigationViewController.mapTemplate {
            mapView = navigationViewController.mapView
        } else if let carPlayMapViewController = mapViewController {
            mapView = carPlayMapViewController.mapView
        } else {
            return
        }
        
        mapView.setContentInset(mapView.safeAreaInsets, animated: false, completionHandler: nil) // make sure this is always up to date in-case safe area changes during gesture
        self.updatePan(by: translation, mapTemplate: mapTemplate, animated: false)
    }
    
    private func updatePan(by offset: CGPoint, mapTemplate: CPMapTemplate, animated: Bool) {
        let mapView: NavigationMapView
        if let navigationViewController = currentNavigator, mapTemplate == navigationViewController.mapTemplate {
            mapView = navigationViewController.mapView
        } else if let carPlayMapViewController = carWindow?.rootViewController as? CarPlayMapViewController {
            mapView = carPlayMapViewController.mapView
        } else {
            return
        }

        let coordinate = coordinate(of: offset, in: mapView)
        mapView.setCenter(coordinate, animated: animated)
    }

    func coordinate(of offset: CGPoint, in mapView: NavigationMapView) -> CLLocationCoordinate2D {
        let contentFrame = mapView.bounds.inset(by: mapView.safeAreaInsets)
        let centerPoint = CGPoint(x: contentFrame.midX, y: contentFrame.midY)
        let endCameraPoint = CGPoint(x: centerPoint.x - offset.x, y: centerPoint.y - offset.y)

        return mapView.convert(endCameraPoint, toCoordinateFrom: mapView)
    }

    public func mapTemplate(_ mapTemplate: CPMapTemplate, panWith direction: CPMapTemplate.PanDirection) {
        let mapView = currentNavigator?.mapView ?? mapViewController?.mapView

        guard let mapView else {
            return
        }

        // Determine the screen distance to pan by based on the distance from the visual center to the closest side.
        let contentFrame = mapView.bounds.inset(by: mapView.safeAreaInsets)
        let increment = min(mapView.bounds.width, mapView.bounds.height) / 2.0
        
        // Calculate the distance in physical units from the visual center to where it would be after panning downwards.
        let downshiftedCenter = CGPoint(x: contentFrame.midX, y: contentFrame.midY + increment)
        let downshiftedCenterCoordinate = mapView.convert(downshiftedCenter, toCoordinateFrom: mapView)
        let distance = mapView.centerCoordinate.distance(to: downshiftedCenterCoordinate)
        
        // Shift the center coordinate by that distance in the specified direction.
        guard let relativeDirection = CLLocationDirection(panDirection: direction) else {
            return
        }
        let shiftedDirection = (mapView.direction + relativeDirection).wrap(min: 0, max: 360)
        let shiftedCenterCoordinate = mapView.centerCoordinate.coordinate(at: distance, facing: shiftedDirection)

        mapView.setCenter(shiftedCenterCoordinate, animated: true)
        mapView.tracksUserCourse = false
    }

    private func createRouteController(with route: Route) -> RouteController {
        if self.simulatesLocations {
            let locationManager = SimulatedLocationManager(route: route)
            locationManager.speedMultiplier = self.simulatedSpeedMultiplier
            return RouteController(along: route, locationManager: locationManager)
        } else {
            return RouteController(along: route)
        }
    }
}

// MARK: CarPlayNavigationDelegate

@available(iOS 12.0, *)
extension CarPlayManager: CarPlayNavigationDelegate {
    public func carPlayNavigationViewControllerDidArrive(_: CarPlayNavigationViewController) {
        endNavigation()
    }

    public func carPlayNavigationViewControllerDidDismiss(_ carPlayNavigationViewController: CarPlayNavigationViewController, byCanceling canceled: Bool) {
        if let mainMapTemplate {
            self.interfaceController?.setRootTemplate(mainMapTemplate, animated: true)
        }
        if let interfaceController, interfaceController.templates.count > 1 {
            interfaceController.popToRootTemplate(animated: true)
        }
        endNavigation()
    }
}
#else
/**
 CarPlay support requires iOS 12.0 or above and the CarPlay framework.
 */
@objc(MBCarPlayManager)
class CarPlayManager: NSObject {
    /**
     The shared CarPlay manager.
     */
    @objc public static var shared = CarPlayManager()
    
    /**
     A Boolean value indicating whether the phone is connected to CarPlay.
     */
    @objc public var isConnectedToCarPlay = false
}
#endif
