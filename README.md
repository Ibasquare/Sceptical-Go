### Sceptical Go

 ScepticalGo is a 2D puzzle game where you need to find your way in space among multiple planets and asteroids to reach the end of the level! Your only mean of propulsion is to use the gravity of the planets around you to take the right turn at the right time. If you miss your shoot, you will be lost in space forever, wandering indefinitely... 

Fortunately, you can place planets with different properties, as well as portals and other stars on your path to help and guide you towards the end of the level!

## Installation
In order to install the application on your mobile phone, one should install the **ScepticalGo.apk** file, present at the top of the master branch, on his phone.
Users should simply use the following command line:
```sh
$ adb -s device install ScepticalGo.apk
```
where `device` should be replace by the name of the device the user want to install the app on. The list of device connected to the computer can be asses using: 
```sh
$ adb devices
```
*Remark* : iOS may need to install the adb command using **brew**.
## Packages used
Here is the final list of the packages used in our application. As part of the course, permission to use each of the packages has been requested before using them.
-   `shared_preferences` (0.4.2) : Store user progress in the game
-   `flutter_launcher_icons`(0.7.0) : Change the icon of the application
-   `video_player`(0.7.2) : Display recorded video (used for hints)
## About

This project was made for the course of *Object-Oriented Programming on Mobile Devices* during the first quadrimester of 2018.
This project was carried out by  Ben Mariem Sami, Derroitte Natan and Marechal Emeline.