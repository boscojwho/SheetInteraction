# SheetInteraction

<p>
    <a href="https://developer.apple.com/swift/"><img alt="Swift 5.7" src="https://img.shields.io/badge/swift-5.7-orange.svg?style=flat"></a>
    <a href="https://github.com/boscojwho/SheetInteraction/blob/main/LICENSE"><img alt="License" src="https://img.shields.io/badge/License-GPLv3-blue.svg"></a>
</p>

## About
<b>SheetInteraction</b> allows developers to observe changes to a UISheetPresentationController sheet's position, and perform percent-driven animations driven by a sheet stack's position.

<i>Note: This solution is limited to UIKit projects running on iOS devices in compact horizontal size class (i.e. iPhone, or iPad mini running in portrait mode).</i>

Developers may wish to perform percent-driven animations when users interact with [UISheetPresentationController](https://developer.apple.com/documentation/uikit/uisheetpresentationcontroller)'s modal sheet stack. Unfortunately, UISheetPresentationController only notifies its delegate when a sheet's detent finishes changing (i.e. when a sheet finishes animating to its target detent). What developers may wish to know is how much a sheet has animated between its smallest and largest detents, as well as between each individual detent, and be notified of that information interactively as those changes occur.

SheetInteraction provides developers with the following features:
- Track amount a sheet has animated from its smallest to largest detents (as a `percentageTotal` from 0-1).
- Track amount a sheet has animated between each detent using a value between 0-1 (e.g. 0.33 animated betweeen `medium` and `large`).
- Observe the target detent at which a sheet will rest when user ends interaction (i.e. on touch up) and before sheet begins animating to its final resting detent.

The above features allow developers to tie user interface animations and state to a sheet's user interaction using animation APIs specified in the [Animations](#animations) section below.

## Example
A working example is provided in this project's `Sources/Example` directory. Build and run the `SheetInteraction-Example` scheme to see it in action.

## How to Use
To begin, initialize a `SheetInteraction` object on the root view controller of a modal view controller stack. The root view controller can either be a `UINavigationController` or `UIViewController`. This object *must* be initialized with the root view of the root view controller. In a navigation controller setup, ensure this is a view that includes the navigation bar (**Warning**: Do not use a modal view stack's drop shadow view provided by UIKit, as its `frame` and `safeAreaInsets` may not necessarily align with that of the `sheetView`'s).

SheetInteraction only needs to be initialized once for any modal view stack.

Once initialized, set `SheetInteraction.sheetInteractionGesture.delegate`, and implement `gestureRecognizer(shouldRecognizeSimultaneouslyWith...)` such that `sheetInteractionGesture` always recognizes simultaneously with any other gesture.

Finally, set `SheetInteraction.delegate`, and implement `SheetInteractionDelegate` in order to drive user-interface changes while user interaction is happening.

## Animations
On interaction change, to make user-interface updates that vary according to the current detent, use `sheetInteraction.animating(<detentToAnimateWith>, interactionChange: interactionChange)`. The animation block provides a `percentageAnimating` value that ranges from 0-1, where 0 is equal to the next smallest detent, and 1 is equal to the specified detent. In other words, this value approaches 1 when user is moving the sheet to a larger detent, and vice-versa.

On interaction change, use the value `interactionChange.percentageTotal` to make user-interface updates that vary based on a sheet's overall position relative to its window.

On interaction end, use `sheetInteraction.sheetController.detent(withIdentifier: targetDetentInfo.detentIdentifier)` to get the target detent. You may also wish to use the custom `detent.greaterThan(<anotherDetent>)` comparison function to make user-interface updates that are applicable to more than one detent. For example:
```
if targetDetent.greaterThan(.mediumSmall(), in: sheetInteraction.sheetController) == true {
    /// e.g. Show or hide user-interface element(s) that only apply to detents larger than `mediumSmall()`.
}
```

## Under-the-Hood
SheetInteraction adds a pan gesture recognizer to the `sheetView` provided to it. That pan gesture is what enables SheetInteraction to determine when a user begins, changes, and ends interacting with a modal sheet. 

During the `begin` and `end` phases, SheetInteraction relies on the `sheetView`'s UISheetPresentationController to provide it with the currently selected detent.

During the `change` phase, SheetInteraction uses the sheet's layout metrics provided by `SheetLayoutInfo` to generate a set of `detentLayoutInfo` for all active detents. `SheetLayoutInfo` is a set of layout measurements for the sheet relative to the sheet's window (apart from the sheet's `frame`, this is mostly static layout data). The set of `detentLayoutInfo` is specific to each active detent, and is only valid during user interaction.
