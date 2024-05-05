//
//  ReviewManagementView.swift
//  EcoShop Backend ISP
//
//  Created by Joshua Browne on 05/05/2024.
//

import SwiftUI

struct ReviewManagementView: View {
    @ObservedObject var viewModel: ReviewViewModel
    @State private var showingAddReviewView = false  // State to control the display of an add review form

    var body: some View {
        NavigationView {
            VStack {
                reviewList
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
                // Assuming AddReviewView exists and is designed to handle the addition of reviews
                AddReviewView(viewModel: viewModel)
            }
        }
        .onAppear {
            Task {
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
                    Text("Rating: \(review.rating)/5")
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.deleteReview(review.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// Assuming AddReviewView is defined elsewhere
struct AddReviewView: View {
    @ObservedObject var viewModel: ReviewViewModel
    @State private var productId: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var rating: Int = 5

    var body: some View {
        NavigationView {
            Form {
                TextField("Product ID", text: $productId)
                TextField("Title", text: $title)
                TextEditor(text: $content)
                    .frame(height: 200)
                Stepper("Rating: \(rating)", value: $rating, in: 1...5)
                Button("Add Review") {
                    addReview()
                }
            }
            .navigationTitle("New Review")
            .navigationBarItems(leading: Button("Dismiss") {
                dismiss()
            })
        }
    }

    private func addReview() {
        let newReview = Review(id: UUID().uuidString, productId: productId, title: title, content: content, rating: rating)
        viewModel.addReview(newReview)
        dismiss()
    }

    private func dismiss() {
        // Logic to dismiss this view
    }
}

// Preview for SwiftUI previews
struct ReviewManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewManagementView(viewModel: ReviewViewModel(reviewHandler: MockReviewHandler()))
    }
}

class MockReviewHandler: ReviewHandling {
    func findAllReviews() async -> [Review] { return [] }
    func addReview(_ review: Review) {}
    func updateReview(_ review: Review) {}
    func deleteReview(_ reviewId: String) {}
    func getReview(_ reviewId: String) -> Review? { return nil }
}
