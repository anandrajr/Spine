//
//  Resource.swift
//  Spine
//
//  Created by Ward van Teijlingen on 25-08-14.
//  Copyright (c) 2014 Ward van Teijlingen. All rights reserved.
//

import Foundation

public typealias ResourceType = String

/**
A ResourceIdentifier uniquely identifies a resource that exists on the server.
*/
public struct ResourceIdentifier: Equatable {
	/// The resource type.
	var type: ResourceType
	
	/// The resource ID.
	var id: String
	
	/**
	Instantiates a new ResourceIdentifier with the given type and id.
	
	- parameter type: The type of the resource.
	- parameter id:   The ID of the resource.
	
	- returns: A ResourceIdentifier
	*/
	init(type: ResourceType, id: String) {
		self.type = type
		self.id = id
	}
	
	/**
	Instantiates a new ResourceIdentifier from the given dictionary.
	The dictionary must contain values for the "type" and "id" keys.
	
	- parameter dictionary: Dictionary containing the type and id.
	
	- returns: A ResourceIdentifier
	*/
	init(dictionary: NSDictionary) {
		type = dictionary["type"] as! ResourceType
		id = dictionary["id"] as! String
	}
	
	/**
	Returns a dictionary with "type" and "id" keys.
	
	- returns: Dictionary containing the type and id.
	*/
	func toDictionary() -> NSDictionary {
		return ["type": type, "id": id]
	}
}

public func ==(lhs: ResourceIdentifier, rhs: ResourceIdentifier) -> Bool {
	return lhs.type == rhs.type && lhs.id == rhs.id
}

/**
A base recource class that provides some defaults for resources.
You can create custom resource classes by subclassing from Resource.
*/
public class Resource: NSObject, NSCoding {
	/// The resource type in plural form.
	public class var resourceType: ResourceType {
		fatalError("Override resourceType in a subclass.")
	}
	
	/// Instance counterpart of `resourceType` method.
	final var resourceType: ResourceType { return self.dynamicType.resourceType }
	
	/// All fields that must be persisted in the API.
	public class var fields: [Field] { return [] }
	
	/// Instance counterpart of `resourceType` method.
	final var fields: [Field] { return self.dynamicType.fields }
	
	/// The ID of this resource.
	public var id: String?
	
	/// The canonical URL of the resource.
	public var URL: NSURL?
	
	/// Whether the fields of the resource are loaded.
	public var isLoaded: Bool = false
	
	/// The metadata for this resource.
	public var meta: [String: AnyObject]?
	
	public required override init() {
		super.init()
	}
	
	public required init(coder: NSCoder) {
		super.init()
		self.id = coder.decodeObjectForKey("id") as? String
		self.URL = coder.decodeObjectForKey("URL") as? NSURL
		self.isLoaded = coder.decodeBoolForKey("isLoaded")
		self.meta = coder.decodeObjectForKey("meta") as? [String: AnyObject]
	}
	
	public func encodeWithCoder(coder: NSCoder) {
		coder.encodeObject(self.id, forKey: "id")
		coder.encodeObject(self.URL, forKey: "URL")
		coder.encodeBool(self.isLoaded, forKey: "isLoaded")
		coder.encodeObject(self.meta, forKey: "meta")
	}
	
	/**
	Returns the attribute value for the given key
	
	- parameter field: The name of the field to get the value for.
	
	- returns: The value of the field.
	*/
	public func valueForField(field: String) -> AnyObject? {
		return valueForKey(field)
	}
	
	/**
	Sets the given attribute value for the given key.
	
	- parameter value: The value to set.
	- parameter field: The name of the field to set the value for.
	*/
	public func setValue(value: AnyObject?, forField field: String) {
		setValue(value, forKey: field)
	}

	/**
	Sets all fields of resource `resource` to nil and sets `isLoaded` to false.
	*/
	public func unload() {
		for field in self.fields {
			self.setValue(nil, forField: field.name)
		}
		
		isLoaded = false
	}
		
	class func fieldNamed(name: String) -> Field? {
		return fields.filter { $0.name == name }.first
	}

}

extension Resource {
	override public var description: String {
		return "\(self.resourceType)(\(self.id), \(self.URL))"
	}
	
	override public var debugDescription: String {
		return description
	}
}

public func == <T: Resource> (left: T, right: T) -> Bool {
	return (left.id == right.id) && (left.resourceType == right.resourceType)
}