//
//  ChatAttachmentRepo.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 20/9/25.
//

import Foundation
import Supabase

class ChatAttachmentRepo{
    static private let supabase = SupabaseManager.shared.client
    
    static private var currentUserId: String? {
        supabase.auth.currentUser?.id.uuidString
    }
    
    /// Fetch attachments for a message
    static func fetchAttachments(messageId: UUID) async -> ([ChatAttachment]?, Failure?) {
        do {
            let response: [ChatAttachment] = try await supabase
                .from("chat_attachments")
                .select()
                .eq("message_id", value: messageId.uuidString)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            return (response, nil)
            
        } catch {
            return (nil, Failure(message: "Error fetching attachments: \(error.localizedDescription)", errorType: .fetchError))
        }
    }
    
    /// Upload an attachment
    static func uploadAttachment(
        messageId: UUID,
        fileName: String,
        fileType: String,
        fileSize: Int,
        fileData: Data,
        metadata: AttachmentMetadata? = nil
    ) async -> (ChatAttachment?, Failure?) {
        // Validate file before upload
        let validation = ChatAttachment.validateFile(fileName: fileName, fileType: fileType, fileSize: fileSize)
        if !validation.isValid {
            return (nil, Failure(message: validation.error ?? "Invalid file", errorType: .validationError))
        }
        
        do {
            // Generate unique storage path
            let fileExtension = URL(fileURLWithPath: fileName).pathExtension
            let uniqueFileName = "\(UUID().uuidString).\(fileExtension)"
            let storagePath = "chat-attachments/\(uniqueFileName)"
            
            // Upload file to storage
            let _ = try await supabase.storage
                .from("chat-files")
                .upload(storagePath, data: fileData)
            
            // Create attachment record
            let attachment = ChatAttachment(
                messageId: messageId,
                fileName: fileName,
                fileType: fileType,
                fileSize: fileSize,
                storagePath: storagePath,
                status: .uploaded,
                metadata: metadata
            )
            
            let response: [ChatAttachment] = try await supabase
                .from("chat_attachments")
                .insert(attachment)
                .select()
                .execute()
                .value
            
            return (response.first, nil)
            
        } catch {
            return (nil, Failure(message: "Error uploading attachment: \(error.localizedDescription)", errorType: .insertError))
        }
    }
    
    /// Update attachment status or metadata
    static func updateAttachment(
        id: UUID,
        status: AttachmentStatus? = nil,
        metadata: AttachmentMetadata? = nil
    ) async -> (ChatAttachment?, Failure?) {
        do {
            // Create a struct for the update to ensure proper encoding
            struct AttachmentUpdate: Encodable {
                let status: String?
                let metadata: AttachmentMetadata?
                
                init(status: AttachmentStatus?, metadata: AttachmentMetadata?) {
                    self.status = status?.rawValue
                    self.metadata = metadata
                }
            }
            
            let update = AttachmentUpdate(status: status, metadata: metadata)
            
            let response: [ChatAttachment] = try await supabase
                .from("chat_attachments")
                .update(update)
                .eq("id", value: id.uuidString)
                .select()
                .execute()
                .value
            
            return (response.first, nil)
            
        } catch {
            return (nil, Failure(message: "Error updating attachment: \(error.localizedDescription)", errorType: .updateError))
        }
    }
    
    /// Delete an attachment
    static func deleteAttachment(id: UUID) async -> (Bool, Failure?) {
        do {
            // First get the attachment to retrieve storage path
            let attachments: [ChatAttachment] = try await supabase
                .from("chat_attachments")
                .select()
                .eq("id", value: id.uuidString)
                .execute()
                .value
            
            guard let attachment = attachments.first else {
                return (false, Failure(message: "Attachment not found", errorType: .fetchError))
            }
            
            // Delete from storage
            try await supabase.storage
                .from("chat-files")
                .remove(paths: [attachment.storagePath])
            
            // Delete from database
            try await supabase
                .from("chat_attachments")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            
            return (true, nil)
            
        } catch {
            return (false, Failure(message: "Error deleting attachment: \(error.localizedDescription)", errorType: .deleteError))
        }
    }
    
}
