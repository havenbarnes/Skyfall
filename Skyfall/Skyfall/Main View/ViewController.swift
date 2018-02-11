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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var crosshair: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        
        let leftSpace = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        searchBar.leftView = leftSpace
        searchBar.leftViewMode = UITextFieldViewMode.always
        searchBar.leftViewMode = .always
    }
    
    @objc func tapped(recognizer: UITapGestureRecognizer) {
        let sceneView = recognizer.view as! ARSCNView
        let hitLocation = crosshair.center
        let hitResults = sceneView.hitTest(hitLocation, options: [:])
        if !hitResults.isEmpty {
            print("!!!!!!!!!!!!!!!\n\(hitResults.first!.localCoordinates)\n!!!!!!!!!!!!!!!!!")
            let coords = hitResults.first!.localCoordinates
            let r = sqrt(pow(coords.x, 2) + pow(coords.y, 2) + pow(coords.z, 2))
            let theta = acos(coords.y / r)
            let phi = atan(coords.x / coords.z)
            
            let latitude = 90 - (theta * 180 / Float.pi)

            let longitude = phi * 180 / Float.pi
            print("!!!!!!!!!!!!!!!\n\(latitude),\(longitude)\n!!!!!!!!!!!!!!!!!")
        }
    }
    
    // MARK: - ARSCNViewDelegate
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let planeNode = self.createGlobeNode(anchor: planeAnchor)
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
        
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

