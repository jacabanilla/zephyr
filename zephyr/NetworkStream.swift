//
//  NetworkStream.swift
//  zephyr
//
//  Created by Jorge Alexander Cabanilla on 1/25/21.
//

import Foundation

// event codes for the Stream Delegate
public enum  StreamEvent {
    case openCompleted      // in, out
    case hasBytesAvailable  // in
    case hasSpaceAvailable  //     out
    case errorOccurred      // in, out
    case endEncountered     // in, out
}

/*
 Bi-directional stream interface that wraps the delegate and
 publishes a reactive pattern to the applciation.  All replies
 from the AVR will land in reply.
*/
class NetworkStream: NSObject, ObservableObject, StreamDelegate {
    @Published var reply = String()

    private var inStream: InputStream!
    private var outStream: OutputStream!
    private let maxReadLength = 256
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
            case .openCompleted:
                print("stream opened")
        
            case .hasBytesAvailable:
                print("new message received")
                receive(stream: aStream as! InputStream, maxReadLength: maxReadLength)

                // return bytes for translations

            case .endEncountered:
                print("end received")
                close()

            case .errorOccurred:
                print("error occurred")

            case .hasSpaceAvailable:
                print("has space available")

            default:
                print("some other event...")
        }
    }

    func open(host: String, port: UInt32) -> Bool {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

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

    func close() {
        inStream.close()
        outStream.close()
    }
    
    func transmit(message: String) {
        guard (outStream != nil) else {
            return
        }
        
        let data = message.data(using: .utf8)!
      
        data.withUnsafeBytes {
        guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
          print("Error connecting")
          return
        }
            
        outStream.write(pointer, maxLength: data.count)
      }
    }

    private func receive(stream: InputStream, maxReadLength: Int) {
        guard (inStream != nil) else {
            return
        }

        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        var msg = ""
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

        // This is a small hack when using ncat followed by a clearing of the buffer
        reply = msg.replacingOccurrences(of: "<user0> ", with: "")
    }
}
