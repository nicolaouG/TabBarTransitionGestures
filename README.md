<img src="https://img.shields.io/badge/swift5.0-compatible-4BC51D.svg?style=flat" alt="Swift 5.0 compatible" /></a> <a href="https://github.com/nicolaouG/GNRangeSlider/blob/master/LICENSE">

# TabBarTransitionGestures
Change tabs with animation or with a pan gesture

![](tabbarTransitionAndGesture.gif)

*Notes*
- Back swipe gesture is prioritized.
- When transitioning to a tableView or collectionView tab for the first time, the contentInsets are not adjusted as expected when there is a navBar.
- When selecting a tabBarItem, the colors under translucent tabBar and its navBar (if any) are not updating to new values until the animation finishes.
