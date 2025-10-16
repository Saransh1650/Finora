//
//  OCRStockSelectionDialog.swift
//  Portfolio.AI
//
//  Created by Saransh Singhal on 15/10/25.
//

import PhotosUI
import SwiftUI

struct OCRStockSelectionDialog: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var portfolioManager: PortfolioManager

    @State private var selectedImage: PhotosPickerItem?
    @State private var loadedImage: UIImage?
    @State private var extractedStocks: [ExtractedStock] = []
    @State private var selectedStocks: Set<String> = []
    @State private var editableStocks: [String: EditableStockModel] = [:]
    @State private var isProcessing = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showImagePicker = true

    var body: some View {
        ZStack {
            // Background overlay
            AppColors.background.opacity(0.0)
                .ignoresSafeArea()
                .onTapGesture {
                    if !isProcessing && !isLoading {
                        dismiss()
                    }
                }

            // Dialog content
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Import Your Stocks")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    if isProcessing {
                        Text("Processing image...")
                    } else if extractedStocks.isEmpty && loadedImage != nil {
                        Text("No stocks found in image")
                    } else if !extractedStocks.isEmpty {
                        Text("Select stocks to add to your portfolio")
                    } else {
                        Text("Choose an image of your portfolio")
                    }
                }
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

                if showImagePicker && loadedImage == nil {
                    // Image Picker
                    PhotosPicker(
                        selection: $selectedImage,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.plus.fill")
                                .font(.system(size: 48))
                                .foregroundColor(AppColors.selected)

                            Text("Select Portfolio Image")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("Choose an image from your photo library")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .background(AppColors.selected.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    AppColors.selected.opacity(0.3),
                                    lineWidth: 2
                                )
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [8])
                                )
                        )
                        .cornerRadius(12)
                    }
                    .onChange(of: selectedImage, ) { _, _ in
                        Task {
                            await loadSelectedImage()
                        }
                    }
                } else if isProcessing {
                    // Processing indicator
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(
                                    tint: AppColors.selected
                                )
                            )
                            .scaleEffect(1.2)

                        Text("Analyzing image...")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else if !extractedStocks.isEmpty {
                    // Extracted stocks list
                    OCRSuggestedStockList(
                        extractedStocks: extractedStocks,
                        selectedStocks: $selectedStocks,
                        editableStocks: $editableStocks
                    )

                } else if loadedImage != nil {
                    // No stocks found
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.textSecondary)

                        Text("No stocks detected")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text("Try taking a clearer photo or use manual entry")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                }

                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                // Action Buttons
                HStack(spacing: 12) {
                    // Back/Cancel Button
                    Button(loadedImage == nil ? "Cancel" : "Back") {
                        if loadedImage == nil {
                            dismiss()
                        } else {
                            resetToImageSelection()
                        }
                    }
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppColors.background)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.border, lineWidth: 1)
                    )

                    // Add Selected Stocks Button
                    if !extractedStocks.isEmpty {
                        Button(action: addSelectedStocks) {
                            HStack(spacing: 8) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(
                                            CircularProgressViewStyle(
                                                tint: .white
                                            )
                                        )
                                        .scaleEffect(0.8)
                                } else {
                                    Text(
                                        "Add \(selectedStocks.count) Stock\(selectedStocks.count == 1 ? "" : "s")"
                                    )
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppColors.pureBackground)
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            canAddStocks && !isLoading
                                ? AppColors.selected : AppColors.textSecondary
                        )
                        .cornerRadius(8)
                        .disabled(!canAddStocks || isLoading)
                    }
                }
            }
            .padding(24)
            .background(AppColors.background)
            .border(AppColors.border, width: 1)
            .cornerRadius(16)
            .shadow(
                color: AppColors.textPrimary.opacity(0.1),
                radius: 20,
                x: 0,
                y: 8
            )
            .padding(.horizontal, 32)
        }
    }

    private var canAddStocks: Bool {
        !selectedStocks.isEmpty
            && selectedStocks.allSatisfy { symbol in
                editableStocks[symbol]?.isValid == true
            }
    }

    private func resetToImageSelection() {
        loadedImage = nil
        extractedStocks = []
        selectedStocks = []
        editableStocks = [:]
        errorMessage = nil
        showImagePicker = true
    }

    private func loadSelectedImage() async {
        guard let selectedImage = selectedImage else { return }

        do {
            if let data = try await selectedImage.loadTransferable(
                type: Data.self
            ),
                let image = UIImage(data: data)
            {
                self.loadedImage = image
                showImagePicker = false
                await processImage(image)
            }
        } catch {
            errorMessage = "Failed to load image: \(error.localizedDescription)"
            resetToImageSelection()
        }
    }

    private func processImage(_ image: UIImage) async {
        isProcessing = true
        errorMessage = nil

        AppOcr.extractStockData(from: image) { stocks, error in
            Task { @MainActor in

                if error != nil {
                    self.errorMessage =
                        "OCR processing failed: \(error!.localizedDescription)"
                    self.isProcessing = false
                    resetToImageSelection()
                    return
                }

                if let stocks = stocks, !stocks.isEmpty {
                    self.extractedStocks = stocks
                } else {
                    self.errorMessage =
                        "No stocks found in the image. Please try again with a clearer image."
                }
                isProcessing = false

            }
        }
    }

    private func addSelectedStocks() {
        guard
            let userId = SupabaseManager.shared.client.auth.currentUser?.id
                .uuidString
        else {
            errorMessage = "User not authenticated. Please log in again."
            return
        }

        isLoading = true
        errorMessage = nil

        let stocksToAdd = selectedStocks.compactMap { symbol -> StockModel? in
            guard let editableData = editableStocks[symbol],
                let investment = Double(editableData.totalInvestment),
                let quantity = Double(editableData.quantity)
            else {
                return nil
            }

            return StockModel(
                userId: userId,
                symbol: symbol,
                totalInvested: investment,
                quantity: quantity
            )
        }

        Task {
            await portfolioManager.addStock(stocksToAdd)
            isLoading = false
            dismiss()
        }
    }
}

#Preview {
    OCRStockSelectionDialog()
        .environmentObject(PortfolioManager())
}
