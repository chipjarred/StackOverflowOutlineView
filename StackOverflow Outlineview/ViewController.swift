//
//  ViewController.swift
//  StackOverflow Outlineview
//
//  Created by Chip Jarred on 4/9/21.
//

import Cocoa

class ViewController: NSViewController {

    var outlineViewData: OVDataSource? = OVDataSource()
    var outlineView: NSOutlineView!
    var outlineViewDelegate = OVDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        outlineView = (
            view.firstSubview { $0.identifier?.rawValue == "Outline" } as! NSOutlineView
        )
        outlineView.dataSource = outlineViewData
        outlineView.delegate = outlineViewDelegate
        outlineViewDelegate.enableDragAndDrop(for: outlineView)
        
        outlineView.reloadData()
    }

    override var representedObject: Any?
    {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

