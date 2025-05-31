//
//  ReviewManagementView.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import SwiftUI

struct ReviewManagementView: View {
    @StateObject private var viewModel: ReviewViewModel
    @State private var showingAddReviewView = false
    
    init(reviewHandler: ReviewHandling) {
        _viewModel = StateObject(wrappedValue: ReviewViewModel(reviewHandler: reviewHandler))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }
                
                reviewList
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Review Management")
            .toolbar {
                Button(action: {
                    showingAddReviewView.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingAddReviewView) {
                AddReviewView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadReviews()
            }
        }
    }
    
    private var reviewList: some View {
        List {
            ForEach(viewModel.reviews, id: \.id) { review in
                VStack(alignment: .leading) {
                    Text("Product ID: \(review.productId)")
                    Text("Title: \(review.title)").font(.headline)
                    Text("Content: \(review.content)")
                    HStack {
                        ForEach(0..<5) { star in
                            Image(systemName: star < review.rating ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteReview(review.id)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

struct AddReviewView: View {
    @ObservedObject var viewModel: ReviewViewModel
    @State private var productId: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var rating: Int = 5
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Product ID", text: $productId)
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(height: 200)
                Stepper("Rating: \(rating)", value: $rating, in: 1...5)
                Button("Add Review") {
                    Task {
                        await addReview()
                    }
                }
            }
            .navigationTitle("New Review")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func addReview() async {
        let newReview = Review(
            id: UUID().uuidString,
            productId: productId,
            title: title,
            content: content,
            rating: rating
        )
        await viewModel.addReview(newReview)
        dismiss()
    }
}

#Preview {
    ReviewManagementView(reviewHandler: MockReviewHandler())
}
