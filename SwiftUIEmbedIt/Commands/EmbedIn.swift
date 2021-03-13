//
//  EmbedIn.swift
//  SwiftUIEmbedIt
//
//  Created by Andy Kim on 12/3/21.
//

import Foundation
import XcodeKit

class EmbedIn: NSObject, XCSourceEditorCommand {
    
    enum EmbedError: CustomStringConvertible {
        case noSelectionFound
        case unknownType
        
        var description: String {
            switch self {
            case .noSelectionFound:
                return "No Selection Found, Please select lines to embed"
            case .unknownType:
                return "Unknown embed type found"
            }
        }
        
        private var errorCode: Int {
            return 404
        }
        
        var error: NSError {
            let domain = "au.com.hoodles.SwiftUIExtension.SwiftUIEmbedIt"
            let userInfo = [NSLocalizedDescriptionKey: description]
            return NSError(domain: domain, code: errorCode, userInfo: userInfo)
        }
    }
    
    enum EmbedType {
        case hStack, vStack, zStack, scrollView, geometryReader, list, navigationView, group, loop, embed
        var start: String {
            switch self {
            case .hStack: return "HStack {"
            case .vStack: return "VStack {"
            case .zStack: return "ZStack {"
            case .scrollView: return "ScrollView {"
            case .geometryReader: return "GeometryReader { geometry in"
            case .list: return "List(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in"
            case .navigationView: return "NavigationView {"
            case .embed: return "/*@START_MENU_TOKEN@*//*@PLACEHOLDER=Container@*/VStack/*@END_MENU_TOKEN@*/ {"
            case .group: return "Group {"
            case .loop: return "ForEach(/*@START_MENU_TOKEN@*/0 ..< 5/*@END_MENU_TOKEN@*/) { item in"
            }
        }
        
        init?(rawValue: String) {
            switch rawValue {
            case "EmbedInHStack": self = .hStack
            case "EmbedInVStack": self = .vStack
            case "EmbedInZStack": self = .zStack
            case "EmbedInScrollView": self = .scrollView
            case "EmbedInGeometryReader": self = .geometryReader
            case "EmbedInNavigationView": self = .navigationView
            case "EmbedInList": self = .list
            case "EmbedIn": self = .embed
            case "EmbedInGroup": self = .group
            case "EmbedInLoop": self = .loop
            default: return nil
            }
        }
    }
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        print("[EmbedIn] commandIdentifier: \(invocation.commandIdentifier)")
        // At least something is selected
        guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            print("Nothing is selected")
            completionHandler(EmbedError.noSelectionFound.error)
            return
        }
        
        guard let embedType = EmbedType(rawValue: invocation.commandIdentifier) else {
            print("Unknown type: \(invocation.commandIdentifier)")
            completionHandler(EmbedError.unknownType.error)
            return
        }

        if let selection = embed(in: embedType, lines: invocation.buffer.lines, in: firstSelection) {
            invocation.buffer.selections.setArray([selection])
        }
        
        completionHandler(nil)
    }
    
    func embed(in type: EmbedType, lines: NSMutableArray, in selection: XCSourceTextRange) -> XCSourceTextRange? {
        let range = selection.start.line...selection.end.line
        let prevSelection = selection.copy() as! XCSourceTextRange
        
        print("embed in: \(type.start)")
        
        let strings = lines.compactMap { $0 as? String }
        let selectedStrings = Array(strings[range])
        selectedStrings.forEach { print($0) }
        
        let leadingSpaceCount = selectedStrings[0].prefix(while: { $0 == " " }).count
        var nestedStrings = selectedStrings.map { "\t\($0)" }
        let embedStart = "\(type.start)".leftPadding(toLength: leadingSpaceCount + type.start.count, withPad: " ")
        let embedEnd = "}".leftPadding(toLength: leadingSpaceCount + 1, withPad: " ")
        nestedStrings.insert(embedStart, at: 0)
        nestedStrings.append(embedEnd)
        
        let rangeToRemove = NSRange(location: range.lowerBound, length: (range.upperBound - range.lowerBound) + 1)
        lines.removeObjects(in: rangeToRemove)
        
        for string in nestedStrings.reversed() {
            lines.insert(string, at: range.lowerBound)
        }
        
        let sourceTextRange = XCSourceTextRange()
        sourceTextRange.start = XCSourceTextPosition(line: prevSelection.start.line, column: prevSelection.start.column)
        sourceTextRange.end = XCSourceTextPosition(line: prevSelection.end.line + 2, column: leadingSpaceCount + 1)
        return sourceTextRange
    }
}

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}
