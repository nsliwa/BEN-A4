# BEN-A4
Lab 4 for MSLC

Nicole Sliwa
Bre-shard Busby
Ender Barillas

*******************************************************************************************
*******                                                                             *******
******* Youtube link: https://www.youtube.com/watch?v=KoipYmZcFK4&feature=youtu.be  *******
*******                                                                             *******
*******************************************************************************************


Module A
* Reads and displays images from the camera in real time
    - Yes.

* Highlights multiple faces in the scene using CoreImage filters
    - Using Low Accuracy option (for CPU conservation and false positives decrease), for every face detected:
        - Applies a bump distortion filter centered on the center of the face feature
        - Default radius: .5 width of face feature
        - Tested with up to 10 faces simulaneously

* Highlights eye and mouth position using CoreImage filters
    - Creates radial gradiant filters of 3 different colors for each eye / mouth
    - Using CIOverlayBlendMode, applies shades maps to image, centered on each feature

Module B
Uses video of the user's finger (with flash on) to sense a single dimension stream indicating the "redness" of the finger
    - Flash initialized as on to differentiate between finger and other objects
    - Once finger detected, timer set to collect data and process heart rate in 15 seconds
    - Average redness of image stored in buffer holding max 60 seconds worth of data (queue to push / pop when buffer reaches target capacity of 1800)
    - ProcessSamples function computes BPM and sets timer to process again in 15 seconds
    - If finger removed, timer is invalidated and queue is reset. 
        - If >=15 seconds of data has been collected, current BPM locked in until next finger is detected
        - If <15 seconds of data has been collected, user is prompted to start over
Uses the redness to measure the heart rate of the individual (coarse estimate)
    - Uses sliding window method from A2 to count local maxima
    - If <60 seconds of data are present in buffer, count is extrapolated to full 60 seconds
    - Window size set to 13 to be able to detect max heart rate of ~138. Consistently works for heart rate 75-85 (average resting heart rate)


* Extra Features:
    - Added custom app icon tailored to various iphone/ipad versions
    - Customized loading screen

    - Slider controls radius of bump distortion of face
    - Smiles in image are counted. If:
        - No smiles detected: no additional filter applied
        - Majority of faces are smiling: apply bloom filter
        - Majority of faces are not smileing: apply gloom filter
    - Tracks eye status (i.e. present/absent, open/closed). If:
        - User is winking with either eye, filterd image captured and saved to phone's camera roll
        - User's eyes are closed (for longer than typical blink and camera is set to back), flash is toggled
    - Tracks objects in video feed to help keep track of wink/blink of multiple people 
    - Settings button presents settings options in modal view, allowing user to enable/disable any of:
        - Smile effect (gloom/bloom filters)
        - Wink action (flash toggle on wink)
        - Blink action (photo capture on eyes closed)
        - Radial gradient filters on eyes/mouth
        - Bump distoriton filter on face
        * Stores settings in NSUserDefaults for persistence 

    - Implemented ContainerView and embed segue to store / manage GLKViewController for PPG signal
        * Actual PPG signal display not fully implemented

