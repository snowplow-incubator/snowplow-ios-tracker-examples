//
//  ShareViewController.swift
//  SnowPlowDemoShareExtension
//
//  Created by Stephen Williams on 4/08/22.
//  Copyright © 2022 Snowplow Analytics Ltd. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        Tracker.shared.trackExtensionUsage(content: contentText ?? "No content")
        showLoading()

        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
    }

    private func showLoading() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()

        let holder = UIView()
        holder.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
        holder.center = view.center
        holder.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]

        holder.layer.cornerRadius = 10
        holder.backgroundColor = .white
        holder.addSubview(spinner)

        view.addSubview(holder)

        spinner.centerXAnchor.constraint(equalTo: holder.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: holder.centerYAnchor).isActive = true
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
}
