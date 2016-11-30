//
//  WPImageURLHelper+SiteIcons.swift
//  WordPress
//
//  Created by Andrew McKnight on 11/22/16.
//

import Foundation

extension WPImageURLHelper
{
    private static let defaultBlavatarSize: CGFloat = 40

    public class func siteIconURL(forSiteIconURL path: String, size: NSInteger) -> NSURL? {
        guard let components = NSURLComponents(string: path) else { return nil }
        components.queryItems = [
            NSURLQueryItem(name: ImageURLQueryField.Height.rawValue, value: "\(size)"),
            NSURLQueryItem(name: ImageURLQueryField.Width.rawValue, value: "\(size)")
        ]
        return components.URL
    }

    public class func siteIconURL(forContentProvider contentProvider: ReaderPostContentProvider, size: Int) -> NSURL? {
        if (contentProvider.siteIconURL() == nil || contentProvider.siteIconURL().characters.count == 0) {
            guard let blogURL = contentProvider.blogURL(), let hash = NSURL(string: blogURL)?.host?.md5() else {
                return nil
            }

            let components = NSURLComponents()
            components.host = GravatarDefaults.host
            components.scheme = GravatarDefaults.scheme
            components.path = ["", URLComponent.Blavatar.rawValue, hash].joinWithSeparator("/")
            components.queryItems = commonQueryItems(withSize: size)
            return components.URL
        }

        if !contentProvider.siteIconURL().containsString("/\(URLComponent.Blavatar.rawValue)/") {
            return NSURL(string: contentProvider.siteIconURL())
        }

        let components = NSURLComponents(string: contentProvider.siteIconURL())
        components?.queryItems = commonQueryItems(withSize: size)
        return components?.URL
    }

    public class func siteIconURL(forPath path: String?, imageViewBounds bounds: CGRect?) -> NSURL? {
        guard
            let path = path,
            let bounds = bounds,
            let url = NSURL(string: path),
            let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
            else { return nil }

        let size = blavatarSizeInPoints(forImageViewBounds: bounds)
        components.queryItems = commonQueryItems(withSize: size)
        return components.URL
    }

    public static func blavatarSizeInPoints(forImageViewBounds bounds: CGRect) -> Int {
        var size = defaultBlavatarSize

        if !CGSizeEqualToSize(bounds.size, .zero) {
            size = max(bounds.width, bounds.height)
        }

        return Int(size * UIScreen.mainScreen().scale)
    }

    private static func commonQueryItems(withSize size: Int) -> [NSURLQueryItem] {
        return [
            NSURLQueryItem(name: ImageURLQueryField.Default.rawValue, value: ImageDefaultValue.None.rawValue),
            NSURLQueryItem(name: ImageURLQueryField.Size.rawValue, value: "\(size)")
        ]
    }
}
