//
//  WebViewController.swift
//  PlaceInTime
//
//  Created by Rachel Schneebaum on 3/8/17.
//  Copyright © 2017 Rachel Schneebaum. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    var landmark: Landmark!

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var progressBar: UIProgressView! {
        didSet {
            progressBar.alpha = 1
        }
    }

    private var webView: WKWebView?
    private var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setBackButton()
        guard let landmark = landmark else { return }
        title = landmark.name

//        guard let encodedString = "https://en.wikipedia.org/wiki/\(landmark.name)"
//            .addingPercentEscapes(using: .utf8) else { return }
        guard let encodedString = "https://en.wikipedia.org/wiki/\(landmark.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        urlString = encodedString

        let height = mainView.frame.size.height
        let width = UIScreen.main.bounds.size.width
        let x = mainView.frame.origin.x
        let y = mainView.frame.origin.y
        webView = WKWebView(frame: CGRect(x: x,
                                          y: y,
                                          width: width,
                                          height: height))
        webView?.addObserver(self,
                             forKeyPath: #keyPath(WKWebView.estimatedProgress),
                             options: .new,
                             context: nil)
        guard let webView = webView else { return }
        view.addSubview(webView)

        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressBar.progress = Float(webView!.estimatedProgress)

            if progressBar.progress == 1 {
                UIView.animate(withDuration: 0.5) {
                    self.progressBar.alpha = 0
                }
            }
        }
    }

    deinit {
        webView?.removeObserver(self,
                                forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

}
