**Receipt Scanner App Demo**


**Overview**

This repository contains a coded demo of a receipt scanner app designed to help users easily sort expenses between personal and business. The app allows users to scan receipts using their device's camera and then categorize the expenses accordingly. This is not connected to a server that will store this data, but simply allows for a demonstration of the intended sorting flow.


**Features**

Receipt Scanning: Users can scan receipts using their device's camera. This feature will work with very simple receipts but for production purposes would need to be improved.

Expense Sorting: The app automatically categorizes expenses as personal or business based on user input.

Notification System: Users receive notifications reminding them to categorize their expenses. Notifications are sent 15 seconds after the app is opened for demonstration purposes. In order to see the notification the app must be opened and closed within 15 seconds as notifications are not sent while the app is in the foreground.


**Libraries Used**

SwiftUI - Used to create the UI

Vision Framework - Used to be able to read text from images

AVFoundation - Used to enable the camera

UserNotifications - Used to send notifications
