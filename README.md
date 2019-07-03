# MorphyTransitions

[![CI Status](https://img.shields.io/travis/awaran/MorphyTransitions.svg?style=flat)](https://travis-ci.org/awaran/MorphyTransitions)
[![Version](https://img.shields.io/cocoapods/v/MorphyTransitions.svg?style=flat)](https://cocoapods.org/pods/MorphyTransitions)
[![License](https://img.shields.io/cocoapods/l/MorphyTransitions.svg?style=flat)](https://cocoapods.org/pods/MorphyTransitions)
[![Platform](https://img.shields.io/cocoapods/p/MorphyTransitions.svg?style=flat)](https://cocoapods.org/pods/MorphyTransitions)

## Transition example (in slow motion)
![](transition.gif)


## Video tutorial


## Instructions (for Storyboard scroll down for instructions in code)
After installing the cocoapod (details down below)

#### Step 1:
Replace UINavigationController with TransNavController

![](TransNav.png)

#### Step 2:
Each view will now have a Morph id section in your storyboard.  Create IDs that coraspond to views that morph into / out of each other.  For example, if I wanted the green upper left view from the starting view controller to morph into the upper left green view of the ending view controller, I would name both views with the same  Morph Id.  In this case, I named them one but you can pick any identifier you want to.

![](StartVC.png)
![](EndVC.png)


#### Step 3:
Your done!


## Instructions (for Code)
#### Step 1:
Replace UINavigationController with TransNavController

#### Step 2:
Each view will now have var name morphIdentifier.  Create morphIdentifiers that coraspond to views that morph into / out of each other.  For example, if I wanted the green upper left view from the starting view controller to morph into the upper left green view of the ending view controller, I would name both views with the same  morphIdentifiers.  In this case, I named them one but you can pick any identifier you want to.

```swift
beforeVC.one.morphIdentifier = "one"
afterVC.one.morphIdentifier = "one"
```

#### Step 3:
Your done!

## Extra animation assistance In UIView


### func overlapViewWithReset(dest:UIView, animationDuration:TimeInterval, doesFade:Bool = false, fadeDuration:TimeInterval = 0.0, callback:@escaping ((_ resetBlock:@escaping()->Void) -> Void) = {(resetBlock:@escaping()->Void) in resetBlock() }) throws

##### Description
Overlaps the view you call from to the destination view

dest: The destination view you overlap self onto
animationDuration: How long it takes for the overlap to happen
doesFade: after the overlap, if this is set on, it will make the self view fade out revealing the dest view
fadeDuration: If doesFade is set to true, this is how long it will take for self to fade out
callback: the callback will happen after the animation and possible fade animation happens
    resetBlock: the block that you use to reset the views back to their original locations with their original layouts. Be sure to call reset or the fames will be locked in non-autolayout format

```swift
beforeVC.one.overlapViewWithReset(dest:beforeVC.two ....
```



### func swapViewsWithReset(dest:UIView, animationDuration:TimeInterval, doesFade:Bool = false, fadeDuration:TimeInterval = 0.0, callback:@escaping ((_ resetBlock:@escaping()->Void) -> Void) = {(resetBlock:@escaping()->Void) in resetBlock() }) throws

##### Description
Swaps the calling view with the dest view then resets back to their original location

dest: The destination view you want to swap with
animationDuration: How long it takes for the swap to happen
doesFade: after the swap, if this is set on, it will make the self and dest views fade out
fadeDuration: If doesFade is set to true, this is how long it will take for self and dest to fade out
callback: the callback will happen after the animation and possible fade animation happens
    resetBlock: the block that you use to reset the views back to their original locations with their original layouts.  Be sure to call reset or the fames will be locked in non-autolayout format

```swift
beforeVC.one.swapViewsWithReset(dest:beforeVC.two ....
```


### func swapView(dest:UIView, animationDuration:TimeInterval, doesFade:Bool = false, fadeDuration:TimeInterval = 0.0, callback:@escaping (() -> Void) = {}) throws

Swaps the calling view with the dest view including their nslayouts.  ProTip (to get a view to move from one set of layouts to another set of layouts, set the dest view as invisable then animate between the visable and invisable views)

dest: The destination view you want to swap with
animationDuration: How long it takes for the swap to happen
doesFade: after the swap, if this is set on, it will make the self and dest views fade out
fadeDuration: If doesFade is set to true, this is how long it will take for self and dest to fade out
callback: the callback will happen after the animation and possible fade animation happens

```swift
beforeVC.one.swapView(dest:beforeVC.two ....
```



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

MorphyTransitions is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MorphyTransitions'
```

## Author

Arjay Waran, waran.arjay@gmail.com

## License

MorphyTransitions is available under the MIT license. See the LICENSE file for more info.
