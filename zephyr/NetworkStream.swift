//
//  NetworkStream.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import Foundation

class NetworkStream :NSObject {
    public var inStream: InputStream!
    public var outStream: OutputStream!
    private let maxReadLength = 4096

    func startNetworkComms(host: String) -> Bool {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        let port = UInt32(23)
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                           host as CFString,
                                           port,
                                           &readStream,
                                           &writeStream)

        inStream = readStream!.takeRetainedValue()
        outStream = writeStream!.takeRetainedValue()
        
        inStream.delegate = self
        outStream.delegate = self

        inStream.schedule(in: .current, forMode: .default)
        outStream.schedule(in: .current, forMode: .default)

        inStream.open()
        outStream.open()
        
        let numberOfRingsMax = 10
        var numberOfRings = 0
        
        for _ in 0 ... numberOfRingsMax {
            numberOfRings += 1
            Thread.sleep(forTimeInterval: 0.001)

            if (inStream.streamStatus == .open) && (outStream.streamStatus == .open) {
                    break
            }
        }
        
        _ = (numberOfRings == numberOfRingsMax) ? false : true;
        
        return (inStream != nil) && (outStream != nil)
    }

    func stopNetworkComms() {
        inStream.close()
        outStream.close()
    }

    func sendNetwork(message: String) {
        let data = message.data(using: .utf8)!
      
        data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error connecting")
          return
        }
            
        outStream.write(pointer, maxLength: data.count)
      }
    }

    private func readAvailableBytes(stream: InputStream, maxReadLength: Int) {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        var msg = String()
        
        while stream.hasBytesAvailable {
            let numberOfBytesRead = stream.read(buffer, maxLength: maxReadLength)
        
            if numberOfBytesRead < 0, let error = stream.streamError {
              print(error)
              break
            }

            // Construct the message object
            let data = Data(bytes: buffer, count: numberOfBytesRead)
            msg += String(decoding: data, as: UTF8.self)
        }
        
        print(msg)
    }
}

extension NetworkStream: StreamDelegate {
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case .hasBytesAvailable:
                print("new message received")
                readAvailableBytes(stream: aStream as! InputStream, maxReadLength: maxReadLength)
            case .endEncountered:
                print("end received")
                stopNetworkComms()
            case .errorOccurred:
                print("error occurred")
            case .hasSpaceAvailable:
                print("has space available")
            default:
                print("some other event...")
        }
    }
}
