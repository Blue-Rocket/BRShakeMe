=======================
BRShakeMe: Introduction
=======================

This code is motivated by a problem is seismology whereby accelerations recorded on a smartphone can be used to detect if an earthquake is occurring in real time (or has occurred). This has great implications for early warning systems as even a few seconds early warning is valuable to disaster response coordinators.

In an ideal world, accelerations would be recorded and analyzed continuously on the smartphone without unduly draining its resources and without interferring with the smartphone users normal activities. Using standard Apple API's we know this ideal cannot be realized in its entirty on an iPhone. This code represents an experiment to begin to determine how close to the ideal we can come.

====================
What this code does:
====================

In short, this code shows how to use location updates to periodically access acceleration data even when an app is suspended.

When an app is running in the foreground, accelerations can be obtained continuously for as long as the app remains in the foreground. When the app enters the background, accelerations can be obtained for a short period until the app is suspended after which accelerations cannot be obtained again until the app is launched into the foreground at a later time. This is not very valuable to the problem at hand.

This code shows one way to extend the access to accelerations over time using location updates. Location updates can be configured to wake a suspended app periodically, for a short period of time, and during that time, the code proves accelerations can be obtained and analyzed. Using this approach, the timing of the "wake up" calls is not deterministic and varies in its frequency. If the user is moving about, the location updates happen more frequently, and when the user is at rest, they occurr mush less frequently.

The code can be configured to vary the aggressiveness of the location update settings. The least aggressive approach, meaning having the least impact on the iPhone resources, corresponds to the behavior I just described in the preceding paragraph. 

A more aggressive approach keeps the app in the background (non-suspended) much longer, which greatly extends the monitoring time, but does task device resources harder (refer to the USE_HIGH_POWER_LOCATIONS constant in the app delegate).





