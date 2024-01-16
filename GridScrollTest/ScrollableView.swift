//
//  ScrollableView.swift
//  GridScrollTest
//
//  Created by Christian Vinterly on 11/01/2024.
//

import SwiftUI

struct ScrollableView<Content: View>: UIViewControllerRepresentable {

    final class Coordinator: NSObject, UIScrollViewDelegate {

        @Binding var offset: CGPoint
        @Binding var scrollViewsTracking: [Namespace.ID: Bool?]
        private let scrollView: UIScrollView
        private let id: Namespace.ID
        private var isDragging = false
        private var isDecelerating = false

        init(
            _ scrollView: UIScrollView,
            offset: Binding<CGPoint>,
            id: Namespace.ID,
            scrollViewsTracking: Binding<[Namespace.ID: Bool?]>
        ) {
            self.scrollView = scrollView
            self._offset = offset
            self.id = id
            self._scrollViewsTracking = scrollViewsTracking
            super.init()
            self.scrollView.delegate = self
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let isOtherScrollViewTracking = scrollViewsTracking
                .filter { $0.key != id }
                .values
                .contains { $0 == true }

            guard !isOtherScrollViewTracking else {
                // Stop animation of previous deacceleration if user scrolls other synced view while deaccelerating
                isDecelerating = false
                isDragging = false
                scrollView.setContentOffset(scrollView.contentOffset, animated: false)
                return
            }

            guard scrollView.isTracking || isDragging || isDecelerating else { return }
                self.offset = scrollView.contentOffset
                self.scrollViewsTracking[self.id] = self.isDragging
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isDragging = true
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            isDragging = false
            isDecelerating = decelerate

            DispatchQueue.main.async {
                self.scrollViewsTracking[self.id] = self.isDragging
            }
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            isDecelerating = false
        }
    }

    typealias UIViewControllerType = UIScrollViewController<Content>

    @Binding var offset: CGPoint
    @Binding var scrollViewsTracking: [Namespace.ID: Bool?]
    var activeScrollView: Namespace.ID?
    var animationDuration: TimeInterval
    var showsScrollIndicator: Bool
    var axis: Axis
    var content: () -> Content
    var onScale: ((CGFloat)->Void)?
    var disableScroll: Bool
    var disableScrollIfNotFirstActive: Bool
    var stopScrolling: Binding<Bool>
    private let scrollViewController: UIViewControllerType

    @Namespace var id

    init(
        _ offset: Binding<CGPoint>,
        scrollViewsTracking: Binding<[Namespace.ID: Bool?]>,
        activeScrollView: Namespace.ID?,
        animationDuration: TimeInterval,
        showsScrollIndicator: Bool = true,
        axis: Axis = .vertical,
        onScale: ((CGFloat)->Void)? = nil,
        disableScroll: Bool = false,
        disableScrollIfNotFirstActive: Bool = true,
        stopScrolling: Binding<Bool> = .constant(false),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._offset = offset
        self._scrollViewsTracking = scrollViewsTracking
        self.activeScrollView = activeScrollView
        self.onScale = onScale
        self.animationDuration = animationDuration
        self.content = content
        self.showsScrollIndicator = showsScrollIndicator
        self.axis = axis
        self.disableScroll = disableScroll
        self.disableScrollIfNotFirstActive = disableScrollIfNotFirstActive
        self.stopScrolling = stopScrolling
        self.scrollViewController = UIScrollViewController(
            rootView: self.content(),
            offset: offset,
            axis: self.axis,
            onScale: self.onScale
        )
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<Self>
    ) -> UIViewControllerType {
        self.scrollViewController
    }

    func updateUIViewController(_ viewController: UIViewControllerType, context: UIViewControllerRepresentableContext<Self>) {

        viewController.scrollView.showsVerticalScrollIndicator = self.showsScrollIndicator
        viewController.scrollView.showsHorizontalScrollIndicator = self.showsScrollIndicator
        viewController.updateContent(self.content)

        let duration: TimeInterval = self.duration(viewController)
        let newValue: CGPoint = self.offset

        if let activeScrollView = activeScrollView, disableScrollIfNotFirstActive && id != activeScrollView {
            viewController.scrollView.isScrollEnabled = false
        } else {
            viewController.scrollView.isScrollEnabled = !self.disableScroll
        }

        if self.stopScrolling.wrappedValue {
            viewController.scrollView.setContentOffset(
                viewController.scrollView.contentOffset,
                animated: false
            )
            return
        }

        let isOtherScrollViewTracking = scrollViewsTracking
            .filter { $0.key != id }
            .values
            .contains { $0 == true }

        guard isOtherScrollViewTracking || (!viewController.scrollView.isTracking && !viewController.scrollView.isDecelerating) else { return }

        guard duration != .zero else {
            viewController.scrollView.contentOffset = newValue
            return
        }

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.allowUserInteraction, .curveEaseInOut, .beginFromCurrentState],
            animations: {
                viewController.scrollView.contentOffset = newValue
            }, 
            completion: nil
        )
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            self.scrollViewController.scrollView,
            offset: $offset,
            id: id,
            scrollViewsTracking: $scrollViewsTracking
        )
    }

    private func newContentOffset(_ viewController: UIViewControllerType, newValue: CGPoint) -> CGPoint {
        let maxOffsetViewFrame: CGRect = viewController.view.frame
        let maxOffsetFrame: CGRect = viewController.hostingController.view.frame
        let maxOffsetX: CGFloat = maxOffsetFrame.maxX - maxOffsetViewFrame.maxX
        let maxOffsetY: CGFloat = maxOffsetFrame.maxY - maxOffsetViewFrame.maxY

        return CGPoint(x: min(newValue.x, maxOffsetX), y: min(newValue.y, maxOffsetY))
    }

    private func duration(_ viewController: UIViewControllerType) -> TimeInterval {

        var diff: CGFloat = 0

        switch axis {
            case .horizontal:
                diff = abs(viewController.scrollView.contentOffset.x - self.offset.x)
            default:
                diff = abs(viewController.scrollView.contentOffset.y - self.offset.y)
        }

        if diff == 0 {
            return .zero
        }

        let percentageMoved = diff / UIScreen.main.bounds.height

        return self.animationDuration * min(max(TimeInterval(percentageMoved), 0.25), 1)
    }
}

final class UIScrollViewController<Content: View> : UIViewController, ObservableObject {

    var offset: Binding<CGPoint>
    var onScale: ((CGFloat)->Void)?
    let hostingController: UIHostingController<Content>
    private let axis: Axis
    lazy var scrollView: UIScrollView = {

        let scrollView = UIScrollView()
        scrollView.canCancelContentTouches = true
        scrollView.delaysContentTouches = true
        scrollView.scrollsToTop = true
        scrollView.backgroundColor = .clear

        if self.onScale != nil {
            scrollView.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(self.onGesture)))
        }

        return scrollView
    }()

    @objc func onGesture(gesture: UIPinchGestureRecognizer) {
        self.onScale?(gesture.scale)
    }

    init(
        rootView: Content,
        offset: Binding<CGPoint>,
        axis: Axis,
        onScale: ((CGFloat)-> Void)?
    ) {
        self.offset = offset
        self.hostingController = UIHostingController<Content>(rootView: rootView)
        self.hostingController.view.backgroundColor = .clear
        self.axis = axis
        self.onScale = onScale
        super.init(nibName: nil, bundle: nil)
    }

    func updateContent(_ content: () -> Content) {

        hostingController.rootView = content()
        scrollView.addSubview(hostingController.view)
        updateContentSize()
    }

    func updateContentSize() {
        var contentSize: CGSize = hostingController.view.intrinsicContentSize

        switch axis {
            case .vertical:
                contentSize.width = scrollView.frame.width
            case .horizontal:
                contentSize.height = scrollView.frame.height
        }

        hostingController.view.frame = CGRect(origin: .zero, size: contentSize)
        scrollView.contentSize = contentSize
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.scrollView)
        self.createConstraints()
        self.view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Small hack to fix offset issue on appear
        DispatchQueue.main.async {
            self.offset.wrappedValue = CGPoint(x: 1e-10, y: 1e-10)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateContentSize()
        scrollView.setContentOffset(.zero, animated: false)
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
    }

    fileprivate func createConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        DispatchQueue.main.async {
            self.hostingController.view.frame = CGRect(origin: .zero, size: self.scrollView.contentSize)
        }
    }
}
