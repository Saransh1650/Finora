//
//  ChatAttachment.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 9/20/25.
//

import Foundation

// MARK: - Enums

enum AttachmentType: String, Codable, CaseIterable {
    case image = "image"
    case document = "document"
    case pdf = "pdf"
    case csv = "csv"
    case json = "json"
    case text = "text"
    case other = "other"
    
    var allowedMimeTypes: [String] {
        switch self {
        case .image:
            return ["image/jpeg", "image/png", "image/gif", "image/webp"]
        case .document:
            return ["application/msword", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"]
        case .pdf:
            return ["application/pdf"]
        case .csv:
            return ["text/csv", "application/csv"]
        case .json:
            return ["application/json"]
        case .text:
            return ["text/plain", "text/markdown"]
        case .other:
            return []
        }
    }
    
    var maxFileSizeMB: Int {
        switch self {
        case .image:
            return 10 // 10MB for images
        case .document, .pdf:
            return 25 // 25MB for documents
        case .csv, .json, .text:
            return 5 // 5MB for text files
        case .other:
            return 15 // 15MB for other files
        }
    }
    
    static func from(mimeType: String) -> AttachmentType {
        for type in AttachmentType.allCases {
            if type.allowedMimeTypes.contains(mimeType) {
                return type
            }
        }
        return .other
    }
}

enum AttachmentStatus: String, Codable, CaseIterable {
    case uploading
    case uploaded
    case processing
    case processed
    case error
    case deleted
}

// MARK: - Support Models

struct AttachmentMetadata: Codable {
    let originalName: String?
    let description: String?
    let uploadedBy: String?
    let compressionRatio: Double?
    let thumbnailPath: String?
    let extractedText: String?
    let analysisResults: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case originalName = "original_name"
        case description
        case uploadedBy = "uploaded_by"
        case compressionRatio = "compression_ratio"
        case thumbnailPath = "thumbnail_path"
        case extractedText = "extracted_text"
        case analysisResults = "analysis_results"
    }
    
    init(
        originalName: String? = nil,
        description: String? = nil,
        uploadedBy: String? = nil,
        compressionRatio: Double? = nil,
        thumbnailPath: String? = nil,
        extractedText: String? = nil,
        analysisResults: [String: String]? = nil
    ) {
        self.originalName = originalName
        self.description = description
        self.uploadedBy = uploadedBy
        self.compressionRatio = compressionRatio
        self.thumbnailPath = thumbnailPath
        self.extractedText = extractedText
        self.analysisResults = analysisResults
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        originalName = try container.decodeIfPresent(String.self, forKey: .originalName)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        uploadedBy = try container.decodeIfPresent(String.self, forKey: .uploadedBy)
        compressionRatio = try container.decodeIfPresent(Double.self, forKey: .compressionRatio)
        thumbnailPath = try container.decodeIfPresent(String.self, forKey: .thumbnailPath)
        extractedText = try container.decodeIfPresent(String.self, forKey: .extractedText)
        
        // Handle Any type for analysisResults
        if let analysisResults = try? container.decode([String: String].self, forKey: .analysisResults) {
            self.analysisResults = analysisResults
        } else {
            self.analysisResults = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(originalName, forKey: .originalName)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(uploadedBy, forKey: .uploadedBy)
        try container.encodeIfPresent(compressionRatio, forKey: .compressionRatio)
        try container.encodeIfPresent(thumbnailPath, forKey: .thumbnailPath)
        try container.encodeIfPresent(extractedText, forKey: .extractedText)
        
        if let analysisResults = analysisResults {
            try container.encode(analysisResults, forKey: .analysisResults)
        }
    }
}

// MARK: - Main Model

struct ChatAttachment: Codable, Identifiable {
    let id: UUID
    let messageId: UUID
    let fileName: String
    let fileType: String
    let fileSize: Int
    let storagePath: String
    let attachmentType: AttachmentType
    let status: AttachmentStatus
    let metadata: AttachmentMetadata?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case messageId = "message_id"
        case fileName = "file_name"
        case fileType = "file_type"
        case fileSize = "file_size"
        case storagePath = "storage_path"
        case attachmentType = "attachment_type"
        case status
        case metadata
        case createdAt = "created_at"
    }
    
    init(
        id: UUID = UUID(),
        messageId: UUID,
        fileName: String,
        fileType: String,
        fileSize: Int,
        storagePath: String,
        attachmentType: AttachmentType? = nil,
        status: AttachmentStatus = .uploading,
        metadata: AttachmentMetadata? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.messageId = messageId
        self.fileName = fileName
        self.fileType = fileType
        self.fileSize = fileSize
        self.storagePath = storagePath
        self.attachmentType = attachmentType ?? AttachmentType.from(mimeType: fileType)
        self.status = status
        self.metadata = metadata
        self.createdAt = createdAt
    }
}

// MARK: - Convenience Extensions

extension ChatAttachment {
    var fileSizeMB: Double {
        Double(fileSize) / (1024 * 1024)
    }
    
    var fileSizeFormatted: String {
        let mb = fileSizeMB
        if mb < 1 {
            let kb = Double(fileSize) / 1024
            return String(format: "%.1f KB", kb)
        } else {
            return String(format: "%.1f MB", mb)
        }
    }
    
    var isImage: Bool {
        attachmentType == .image
    }
    
    var isDocument: Bool {
        [.document, .pdf].contains(attachmentType)
    }
    
    var isTextFile: Bool {
        [.text, .csv, .json].contains(attachmentType)
    }
    
    var displayName: String {
        metadata?.originalName ?? fileName
    }
    
    var fileExtension: String {
        URL(fileURLWithPath: fileName).pathExtension.lowercased()
    }
    
    var thumbnailPath: String? {
        metadata?.thumbnailPath
    }
    
    var extractedText: String? {
        metadata?.extractedText
    }
    
    var canBeProcessed: Bool {
        status == .uploaded && !isTextFile
    }
    
    var isReady: Bool {
        status == .uploaded || status == .processed
    }
    
    var hasError: Bool {
        status == .error
    }
    
    func withUpdatedStatus(_ newStatus: AttachmentStatus) -> ChatAttachment {
        ChatAttachment(
            id: self.id,
            messageId: self.messageId,
            fileName: self.fileName,
            fileType: self.fileType,
            fileSize: self.fileSize,
            storagePath: self.storagePath,
            attachmentType: self.attachmentType,
            status: newStatus,
            metadata: self.metadata,
            createdAt: self.createdAt
        )
    }
    
    func withUpdatedMetadata(_ newMetadata: AttachmentMetadata) -> ChatAttachment {
        ChatAttachment(
            id: self.id,
            messageId: self.messageId,
            fileName: self.fileName,
            fileType: self.fileType,
            fileSize: self.fileSize,
            storagePath: self.storagePath,
            attachmentType: self.attachmentType,
            status: self.status,
            metadata: newMetadata,
            createdAt: self.createdAt
        )
    }
}

// MARK: - Hashable Conformance

extension ChatAttachment: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChatAttachment, rhs: ChatAttachment) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - File Validation

extension ChatAttachment {
    static func validateFile(
        fileName: String,
        fileType: String,
        fileSize: Int
    ) -> (isValid: Bool, error: String?) {
        let attachmentType = AttachmentType.from(mimeType: fileType)
        let maxSizeBytes = attachmentType.maxFileSizeMB * 1024 * 1024
        
        // Check file size
        if fileSize > maxSizeBytes {
            return (false, "File size exceeds maximum allowed size of \(attachmentType.maxFileSizeMB)MB")
        }
        
        // Check file type
        if attachmentType == .other && !attachmentType.allowedMimeTypes.isEmpty {
            return (false, "File type '\(fileType)' is not supported")
        }
        
        // Check file name
        if fileName.isEmpty {
            return (false, "File name cannot be empty")
        }
        
        return (true, nil)
    }
}
