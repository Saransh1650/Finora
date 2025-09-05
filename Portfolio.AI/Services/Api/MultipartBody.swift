import Foundation

class MultipartBody {
    var fields: [String: Any]
    var files: [MultipartFile]

    init(fields: [String: Any] = [:], files: [MultipartFile] = []) {
        self.fields = fields
        self.files = files
    }

    func toData(boundary: String) -> Data {
        var body = Data()

        for (key, value) in fields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        for file in files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(file.field)\"; filename=\"\(file.filename ?? file.file.lastPathComponent)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            body.append(try! Data(contentsOf: file.file))
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}

class MultipartFile {
    var field: String
    var file: URL
    var filename: String?

    init(field: String, file: URL, filename: String? = nil) {
        self.field = field
        self.file = file
        self.filename = filename
    }
}