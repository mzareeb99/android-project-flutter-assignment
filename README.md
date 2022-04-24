# android-project-flutter-assignment

### 1) What class is used to implement the controller pattern in this library? What features does it allow the developer to control?
The snappingSheetController widget class used to implement the controller pattern in the library, it controls snap positions of 
the snapping sheet and it has snapPositions property which can hold the snap positions of the sheet in pixels or factor and it
also has a snapToPosition that can change the snap position.
#
### 2) The library allows the bottom sheet to snap into position with various different animations. What parameter controls this behavior?
The SnappingSheet class has a snapPositions property it is a list which holds the diffrent snapping positions for the SheetBelow,the          snappingCurve parameter controls the animation of the snapping.
#
### 3)  Name one advantage of InkWell over the latter and one advantage of GestureDetector over the first.
InkWell and GestureDetector are similar they provide the same features the difference between them is that GestureDetector is more broad and can provide more options the advantage of GestureDetector over InkWell is that it provides more gestures and that its doesnt need to have a Material ancestor. the advantage of InkWell that it is a rectangle area of Material that responds to ink splashes so it has effects ink related features that arent found in gesture.

