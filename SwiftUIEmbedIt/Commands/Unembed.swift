//
//  Unembed.swift
//  SwiftUIEmbedIt
//
//  Created by Andy Kim on 13/3/21.
//

import Foundation
import XcodeKit

class Unembed: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer { completionHandler(nil) }
        print("[Unembed] commandIdentifier: \(invocation.commandIdentifier)")
        guard let firstSelection = invocation.buffer.selections.firstObject as? XCSourceTextRange else {
            print("Nothing is selected")
            return
        }
        
        print("firstSelection.start.line: \(firstSelection.start.line)")
        
        guard let firstLine = invocation.buffer.lines[firstSelection.start.line] as? NSString else {
            print("First line is not string")
            return
        }
        print("firstLine: \(String(describing: firstLine))")
        
        if firstLine.range(of: "{").location != NSNotFound {
            
        }
    }
}
