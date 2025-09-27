//
//  MessageUpdate.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 26/9/25.
//

import Foundation

struct MessageUpdate: Encodable {
    let content: String?
    let metadata: MessageMetadata?
    let tokens_used: Int?
    let processing_time_ms: Int?

    init(
        content: String?,
        metadata: MessageMetadata?,
        tokensUsed: Int?,
        processingTimeMs: Int?
    ) {
        self.content = content
        self.metadata = metadata
        self.tokens_used = tokensUsed
        self.processing_time_ms = processingTimeMs
    }
}
