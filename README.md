# SheetInteraction
SheetInteraction allows developers to observe changes to a UISheetPresentationController sheet's position, and perform percent-driven animations driven by a sheet stack's position.

Developers may wish to perform percent-driven animations when users interact with [UISheetPresentationController](https://developer.apple.com/documentation/uikit/uisheetpresentationcontroller)'s modal sheet stack. Unfortunately, UISheetPresentationController only notifies its delegate when a sheet's detent finishes changing (i.e. when a sheet finishes animating to its target detent). What developers may wish to know is how much a sheet has animated between its smallest and largest detents, as well as between each individual detent, and be notified of that information interactively as those changes occur.

SheetInteraction provides developers with the following features:
- Track amount a sheet has animated from its smallest to largest detents (as a `totalPercentage` from 0-1).
- Track amount a sheet has animated between each detent (e.g. 0.33 betweeen `medium` and `large`).
- Observe the target detent at which a sheet will rest when user ends interaction (i.e. on touch up) and before sheet begins animating to its final resting detent.
