#!/usr/bin/env cato 2.0

/*
	A script for syncing data between Sphere.IO and Contentful.
 */

let ContentfulContentTypeId = "F94etMpd2SsI2eSq4QsiG"
let ContentfulSphereIOFieldId = "nJpobh9I3Yle0lnN"
let ContentfulSpaceId = "jx9s8zvjjls9"
let SphereIOProject = "ecomhack-demo-67"

import AFNetworking
import Alamofire
import AppKit
import Chores
import ContentfulDeliveryAPI
import ContentfulManagementAPI
import Cube // Note: has to be added manually as a development Pod
import ISO8601DateFormatter
import Result

func env(variable: String) -> String {
    return NSProcessInfo.processInfo().environment[variable] ?? ""
}

func key(name: String, project: String = "WatchButton") -> String {
    return (>["pod", "keys", "get", name, project]).stdout
}

NSApplicationLoad()

let contentfulToken = env("CONTENTFUL_MANAGEMENT_API_ACCESS_TOKEN")
let contentfulClient = CMAClient(accessToken: contentfulToken)

var clientId = env("SPHERE_IO_CLIENT_ID")
if clientId == "" {
    clientId = key("SphereIOClientId")
}

var clientSecret = env("SPHERE_IO_CLIENT_SECRET")
if clientSecret == "" {
    clientSecret = key("SphereIOClientSecret")
}

if clientId == "" || clientSecret == "" {
    print("Missing commercetools credentials, please refer to the README.")
    exit(1)
}

let sphereClient = SphereIOClient(clientId: clientId,
        clientSecret: clientSecret, project: SphereIOProject)

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

func createEntry(space: CMASpace, type: CMAContentType, product: Product, exitAfter: Bool = false) {
    var fields: [NSObject : AnyObject] = [
        ContentfulSphereIOFieldId: [ "en-US": product.identifier ],
        "name": [ "en-US": product.name ],
        "productDescription": [ "en-US": product.productDescription ],
        "price": [ "en-US": (product.price["amount"]!).floatValue ],
    ]

    space.createAssetWithTitle([ "en-US": product.name ],
            description: [ "en-US": product.productDescription ],
            fileToUpload: [ "en-US": product.imageUrl ], success: { (_, asset) in
        asset.processWithSuccess(nil, failure: nil)
        fields["productImage"] = [ "en-US": asset ]

        space.createEntryOfContentType(type, withFields: fields, success: { (_, entry) in
            print(entry)

            if (exitAfter) {
                exit(0)
            }
        }) { (_, error) in
            print(error)

            if (exitAfter) {
                exit(1)
            }
        }
    }) { (_, error) in print(error) }
}

func handleSpace(space: CMASpace, products: [Product]) {
    space.fetchEntriesMatching(["content_type": ContentfulContentTypeId], success: { (_, entries) in 
        let importedProductIds = entries.items.map() { 
            $0.fields[ContentfulSphereIOFieldId] as! String
        }

        space.fetchContentTypeWithIdentifier(ContentfulContentTypeId, success: { (_, type) in
            for (index, product) in products.enumerate() {
                let exitAfter = (index + 1) == products.count

                if importedProductIds.contains(product.identifier) {
                    if exitAfter {
                        exit(0)
                    }

                    continue
                }

                createEntry(space, type: type, product: product, exitAfter: exitAfter)
            }
        }) { (_, error) in print(error) }
    }) { (_, error) in print(error) }
}

sphereClient.fetchProductData() { (result) in
	if let value = result.value, results = value["results"] as? [[String:AnyObject]] {
		let products = results.map { (res) in Product(res) }

        contentfulClient.fetchSpaceWithIdentifier(ContentfulSpaceId, success: { (_, space) in
            handleSpace(space, products: products)
        }) { (_, error) in print(error) }
	} else {
		fatalError("Failed to retrieve products from commercetools.")
	}
}

NSApp.run()
