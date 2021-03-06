//
//  Socket+File.swift
//  Swifter
//
//  Created by Damian Kolakowski on 13/07/16.
//

#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

extension Socket {
    
    public func writeFile(file: File) throws -> Void {
        var offset: off_t = 0
        let result = sendfile(fileno(file.pointer), self.socketFileDescriptor, 0, &offset, nil, 0)
        if result == -1 {
            throw SocketError.WriteFailed("sendfile: " + Errno.description())
        }
    }
    
}

#if os(Linux)
    
import Glibc

struct sf_hdtr { }

func sendfile(source: Int32, _ target: Int32, _: off_t, _: UnsafeMutablePointer<off_t>, _: UnsafeMutablePointer<sf_hdtr>, _: Int32) -> Int32 {
    var buffer = [UInt8](count: 1024, repeatedValue: 0)
    while true {
        let readResult = read(source, &buffer, buffer.count)
        guard readResult > 0 else {
            return Int32(readResult)
        }
        var writeCounter = 0
        while writeCounter < readResult {
            let writeResult = write(target, &buffer + writeCounter, readResult - writeCounter)
            guard writeResult > 0 else {
                return Int32(writeResult)
            }
            writeCounter = writeCounter + writeResult
        }
    }
}

#endif
