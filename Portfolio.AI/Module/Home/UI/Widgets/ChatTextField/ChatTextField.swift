//
//  ChatTextField.swift
//  FitCheck.AI
//
//  Created by Saransh Singhal on 31/8/25.
//


import SwiftUI
import PhotosUI

struct ChatTextField: View {
    @Binding var text: String
    let placeholder: String
    let onSend: () -> Void
    let onImageSelected: ((UIImage) -> Void)?
    @FocusState private var isFocused: Bool
    @State private var selectedPhoto: PhotosPickerItem?
    
    init(text: Binding<String>, placeholder: String = "Type a message...", onSend: @escaping () -> Void, onImageSelected: ((UIImage) -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.onSend = onSend
        self.onImageSelected = onImageSelected
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Image Upload Button
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "photo")
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(AppColors.pureBackground)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppColors.divider, lineWidth: 1)
                    )
            }
            .onChange(of: selectedPhoto) { oldValue, newValue in
                Task {
                    if let newValue,
                       let data = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        onImageSelected?(image)
                    }
                }
            }
            
            // Text Input
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(AppColors.pureBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isFocused ? Color.blue : AppColors.divider, lineWidth: 1)
                )
                .focused($isFocused)
                .lineLimit(1...4)
            
            // Send Button
            Button(action: {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSend()
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.gray
                        : Color.blue
                    )
                    .cornerRadius(20)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppColors.background)
    }
}

#Preview {
    @Previewable @State var sampleText = ""
    
    return ChatTextField(
        text: $sampleText,
        placeholder: "Type your message...",
        onSend: {
            print("Sending: \(sampleText)")
            sampleText = ""
        },
        onImageSelected: { image in
            print("Image selected: \(image.size)")
        }
    )
    .background(Color.gray.opacity(0.1))
}
