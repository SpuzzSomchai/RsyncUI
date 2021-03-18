//
//  OtherProcessCmdCombine.swift
//  RsyncUI
//
//  Created by Thomas Evensen on 15/03/2021.
//

import Combine
import Foundation

final class OtherProcessCmdCombineClosure: Delay {
    var cancellable_processtermination: Cancellable?
    var cancellable_filehandler: Cancellable?

    // Process termination and filehandler closures
    var processtermination: () -> Void
    var filehandler: () -> Void
    // Command to be executed, normally rsync
    var command: String?
    // Arguments to command
    var arguments: [String]?

    func executeProcess(outputprocess: OutputProcess?) {
        guard command != nil else { return }
        // Process
        let task = Process()
        // If self.command != nil either alternativ path for rsync or other command than rsync to be executed
        if let command = self.command {
            task.launchPath = command
        }
        task.arguments = arguments
        // If there are any Environmentvariables like
        // SSH_AUTH_SOCK": "/Users/user/.gnupg/S.gpg-agent.ssh"
        if let environment = Environment() {
            task.environment = environment.environment
        }
        // Pipe for reading output from Process
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        // Combine, subscribe to NSNotification.Name.NSFileHandleDataAvailable
        // notifications
        cancellable_filehandler = NotificationCenter.default
            .publisher(for: NSNotification.Name.NSFileHandleDataAvailable)
            .sink { _ in
                let data = outHandle.availableData
                if data.count > 0 {
                    if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        outputprocess?.addlinefromoutput(str: str as String)
                        // Send message about files
                        self.filehandler()
                    }
                    outHandle.waitForDataInBackgroundAndNotify()
                }
            }
        // Combine, subscribe to Process.didTerminateNotification
        // notifications
        cancellable_processtermination = NotificationCenter.default
            .publisher(for: Process.didTerminateNotification)
            .sink { [self] _ in
                self.processtermination()
                // Logg to file
                _ = Logfile(outputprocess)
                cancellable_filehandler = nil
                cancellable_processtermination = nil
            }
        SharedReference.shared.process = task
        do {
            try task.run()
        } catch let e {
            let error = e
            self.propogateerror(error: error)
        }
    }

    init(command: String?,
         arguments: [String]?,
         processtermination: @escaping () -> Void,
         filehandler: @escaping () -> Void)
    {
        self.command = command
        self.arguments = arguments
        self.processtermination = processtermination
        self.filehandler = filehandler
    }

    deinit {
        SharedReference.shared.process = nil
        print("deinit OtherProcessCmdCombine")
    }
}

extension OtherProcessCmdCombineClosure: PropogateError {
    func propogateerror(error: Error) {
        SharedReference.shared.errorobject?.propogateerror(error: error)
    }
}