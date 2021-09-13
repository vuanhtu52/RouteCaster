//
//  SettingsSection.swift
//  SettingsTemplate
//
//  Created by Stephen Dowless on 2/10/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Map
    case Location
    case Statistics
    case Unfriend
    
    var description: String {
        switch self {
        case .Map : return "Display on map"
        case .Location: return "Location access"
        case .Statistics: return "Statistics"
        case .Unfriend: return ""
        }
    }
}


enum MapOption: Int, CaseIterable, SectionType {
    case visibleOnMap
    case color
    
    var containsSwitch: Bool {
        switch self {
        case .visibleOnMap: return true
        case .color: return false
        }
    }
    var description: String {
        switch self {
        case .visibleOnMap: return "Visible on map"
        case .color: return "Color"
        }
    }
}

enum LocationOption: Int, CaseIterable, SectionType {
    case seeLocation
    
    var containsSwitch: Bool { return true }
    
    var description: String {
        switch self {
        case .seeLocation: return "Allow to see current location"
        }
    }
}

enum StatisticsOption: Int, CaseIterable, SectionType {
    case viewStatistics
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .viewStatistics: return "View comparing statistics"
        }
    }
}

enum UnfriendOption: Int, CaseIterable, SectionType {
    case unfriend
    
    var containsSwitch: Bool { return false }
    
    var description: String {
        switch self {
        case .unfriend: return "Unfriend"
        }
    }
}
