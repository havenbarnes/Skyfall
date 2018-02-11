//
//  ViewController.swift
//  FloorLava
//
//  Created by Haven Barnes on 6/20/17.
//  Copyright © 2017 Azing. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Photos

class ViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var crosshair: UILabel!
    @IBOutlet weak var helpMessage: UIVisualEffectView!
    
    var modalView: WeatherModalView?
    var activityView: UIActivityIndicatorView?
    
    private var globeAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.isPlaying = true
        
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupUI() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        sceneView.addGestureRecognizer(tap)
    }

    @objc func tapped(recognizer: UITapGestureRecognizer) {
        guard modalView?.superview == nil else { return }
        let sceneView = recognizer.view as! ARSCNView
        let hitLocation = crosshair.center
        let hitResults = sceneView.hitTest(hitLocation, options: [:])
        if !hitResults.isEmpty {
            let coords = hitResults.first!.localCoordinates
            let r = sqrt(pow(coords.x, 2) + pow(coords.y, 2) + pow(coords.z, 2))
            let theta = acos(coords.y / r)
            let phi = atan(coords.x / coords.z)
            
            let latitude = 90 - (theta * 180 / Float.pi)
            var longitude = (phi * 180 / Float.pi)
//            if coords.x < 0 {
//                longitude = -abs(longitude)
//            }
            print("\(latitude),\(longitude)")
            presentModal(latitude: latitude, longitude: longitude)
        }
    }
    
    func presentModal(latitude: Float, longitude: Float) {
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityView?.center = view.center
        activityView?.startAnimating()
        if activityView != nil {
            view.addSubview(activityView!)
        }
        
        App.shared.api.fetch(endpoint: .forecast("\(latitude)", "\(longitude)"), options: nil) { (json) in
            
            guard let json = json else {
                let alert = UIAlertController(title: "Weather Fetch Failed", message: "Please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.modalView = WeatherModalView.fromNib()
            self.modalView?.weatherData = json
            self.modalView?.load(lat: latitude, long: longitude, completion: {
                var frame = self.modalView?.frame
                frame?.origin.y = self.view.frame.height
                frame?.size.width = self.view.frame.width
                frame?.size.height = self.view.frame.height
                self.modalView?.frame = frame!
                self.view.addSubview(self.modalView!)
                
                self.activityView?.removeFromSuperview()
                self.activityView = nil
                UIView.animate(withDuration: 0.4, animations: {
                    frame?.origin.y = 0
                    self.modalView?.frame = frame!
                })
            })
        }
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard !globeAdded else { return }
        
        let planeNode = self.createGlobeNode(anchor: planeAnchor)
        node.addChildNode(planeNode)
        globeAdded = true
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.helpMessage.alpha = 0
            }
        }
    }
    
    func createGlobeNode(anchor: ARPlaneAnchor) -> SCNNode {
        // Create a SceneKit plane to visualize the node using its position and extent.
        // Create the geometry and its materials
        let sphere = SCNSphere(radius: 0.2)
        let material = SCNMaterial()
        
        var texture = ""
        if isDay() {
            texture = "earth-day"
        } else {
            texture = "earth-night"
        }
        material.diffuse.contents = UIImage(named: texture)
        sphere.materials = [material]
    
        // Create a node with the plane geometry we created
        let globeNode = SCNNode(geometry: sphere)
        globeNode.position = SCNVector3Make(anchor.center.x, 0.2, anchor.center.z)

        return globeNode
    }
    
    func isDay() -> Bool {
        let date = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let hour = calendar.component(.hour, from: date)
        return hour > 6 || hour < 18
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    
}

extension SCNVector3 {
    static func +(lhv:SCNVector3, rhv:SCNVector3) -> SCNVector3 {
        return SCNVector3(lhv.x + rhv.x, lhv.y + rhv.y, lhv.z + rhv.z)
    }
}

