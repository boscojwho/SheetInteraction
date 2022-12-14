# SheetInteraction
SheetInteraction allows developers to perform percent-driven animations on a UISheetPresentationController's modal sheet stack.

Developers may wish to perform percent-driven animations when users interact with UIKit's modal sheet stack (UISheetPresentationController). Unfortunately, UISheetPresentationController only notifies its delegate when a sheet's detent finishes changing (i.e. when a sheet finishes animating to its target detent). What we'd like to know is how much a sheet has animated between its smallest and largest detents, and get that information interactively as that change occurs.

SheetInteraction gives developers the ability to track the following:
- The amount a sheet has animated from its smallest to largest detents (as a `totalPercentage` from 0-1).
- The amount a sheet has animated between each detent (e.g. 0.33 betweeen `medium` and `large`).
- Report the target detent at which a sheet will rest when user ends interaction (i.e. on touch up).
