//
//  ViewController.swift
//  WSTipLayerView
//
//  Created by praveen on 23/08/22.
//

import UIKit

class ViewController: UIViewController {
    
    var tipView:WSTipLayerView!
    @IBOutlet weak var btnPlay:UIButton!
    @IBOutlet weak var btnForward:UIButton!
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblStatus:UILabel!
    @IBOutlet weak var bottomView:UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tipView = WSTipLayerView.init()
        tipView.tipDelegate = self;
//        tipView.arrowColor = UIColor.cyan
//        tipView.shadowColor = UIColor.cyan
        tipView.showWSTipView()
    }


}

extension ViewController: WSTipLayerViewDelegate {
    func numberOfTips() -> Int {
        return 5;
    }
    
    func viewForTipAtIndex(index: Int) -> UIView {
        var view: UIView;
        switch (index) {
            case 0:
                view = btnPlay;
                break;
            case 1:
                view = btnForward;
                break;
            case 2:
                view = imgView;
                break;
            case 3:
                view = lblStatus;
                break;
            default:
                view = bottomView;
                break;
        }
        return view;
    }
    
    func messageForTipAtIndex(index: Int) -> String {
        var message:String;
        switch (index) {
            case 0:
                message = "This is a play button and you can use this to play current song.";
                break;
            case 1:
                message = "This is a forward button and you can use this to forward your current playing song.";
                break;
            case 2:
                message = "This is a song image.";
                break;
            case 3:
                message = "This is a current song status and this indicates current syncing status.";
                break;
            default:
                message = "This is bottom view and this contains all information about current song.";
                break;
        }
        return message;
    }
    
    func tipArrowStyleForTipAtIndex(index: Int) -> WSTipArrowStyle {
        var arrowStyle:WSTipArrowStyle;
        switch (index) {
            case 0:
            arrowStyle = .CenterBottom
                break;
            case 1:
            arrowStyle = .CenterBottom
                break;
            case 2:
            arrowStyle = .CenterBottom
                break;
            case 3:
            arrowStyle = .CenterTop
                break;
            default:
            arrowStyle = .CenterTop
                break;
        }
        return arrowStyle;
    }
    
    func didTapOnTipIndex(index: Int) {
        NSLog("Action at: %d",index);
    }
}

