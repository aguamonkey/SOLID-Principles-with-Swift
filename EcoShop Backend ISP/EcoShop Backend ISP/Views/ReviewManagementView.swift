import SwiftUI

struct ReviewManagementView: View {
    @StateObject private var viewModel: ReviewViewModel
    @State private var showingAddReview = false
    @State private var reviewToRemove: Review?

    init(reviewHandler: ReviewHandling) {
        _viewModel = StateObject(wrappedValue: ReviewViewModel(reviewHandler: reviewHandler))
    }

    var body: some View {
        LedgerPage(title: "Notes from\nthe regulars.", subtitle: "The guestbook / useful words about useful things.") {
            Button { showingAddReview = true } label: { Label("Leave a note", systemImage: "plus") }
                .buttonStyle(LedgerButtonStyle())
            LedgerStyle.label("CUSTOMER NOTES")
            if viewModel.isLoading { ProgressView("Opening the guestbook…") }
            if let error = viewModel.errorMessage {
                LedgerNotice(message: error) { Task { await viewModel.loadReviews() } }
            }
            if !viewModel.isLoading && viewModel.reviews.isEmpty && viewModel.errorMessage == nil {
                LedgerNotice(message: "The guestbook is empty. Leave the first note.")
            }
            ForEach(viewModel.reviews) { review in
                VStack(alignment: .leading, spacing: 14) {
                    LedgerStyle.label("REGARDING / \(review.productId)")
                    Text(review.title).font(.system(.title2, design: .serif))
                    Text(review.content).foregroundStyle(LedgerStyle.secondary)
                    HStack(spacing: 5) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < review.rating ? "star.fill" : "star")
                        }
                    }.foregroundStyle(LedgerStyle.accent).accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(review.rating) out of 5 stars")
                    Button("Remove note", role: .destructive) { reviewToRemove = review }.buttonStyle(.bordered)
                }
                LedgerStyle.divider
            }
            LedgerNotice(message: "Sample customer notes / kept for this session.")
        }
        .task { await viewModel.loadReviews() }
        .sheet(isPresented: $showingAddReview) { AddReviewView(viewModel: viewModel) }
        .confirmationDialog("Remove this note?", isPresented: Binding(
            get: { reviewToRemove != nil }, set: { if !$0 { reviewToRemove = nil } }
        ), titleVisibility: .visible) {
            if let review = reviewToRemove {
                Button("Remove note", role: .destructive) { Task { await viewModel.deleteReview(review.id) } }
            }
        }
    }
}

struct AddReviewView: View {
    @ObservedObject var viewModel: ReviewViewModel
    @State private var productId = ""
    @State private var title = ""
    @State private var content = ""
    @State private var rating = 5
    @State private var validationError: String?
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Your note") {
                    TextField("Product reference, e.g. EC-01", text: $productId)
                    TextField("Title", text: $title)
                    TextField("What did you think?", text: $content, axis: .vertical).lineLimit(3...6)
                    Stepper("Rating: \(rating) out of 5", value: $rating, in: 1...5)
                }
                if let error = validationError ?? viewModel.errorMessage { Text(error).foregroundStyle(LedgerStyle.accent) }
                Button(isSaving ? "Saving…" : "Save note") { Task { await save() } }.disabled(isSaving)
            }
            .scrollContentBackground(.hidden).background(LedgerStyle.paper)
            .navigationTitle("New note").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() }.disabled(isSaving) } }
        }.tint(LedgerStyle.ink).interactiveDismissDisabled(isSaving)
    }

    private func save() async {
        validationError = nil
        let values = [productId, title, content].map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard values.allSatisfy({ !$0.isEmpty }) else {
            validationError = "Add a product reference, title and note before saving."
            return
        }
        isSaving = true
        defer { isSaving = false }
        if await viewModel.addReview(Review(id: UUID().uuidString, productId: values[0], title: values[1], content: values[2], rating: rating)) { dismiss() }
    }
}
