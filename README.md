# ScratchHack
Xcode project containing the Scratch Hack application (Swift)
This is the Xcode project for the iOS application 'Scratch Hack'. 
Scratch Hack was recently updated and added back onto the Apple App Store, it is now free.

This project includes some scripts used in the backend of the application. They're located in the Scripts folder. These scripts dealt with scraping scratch ticket information from state websites, formatting the information, and delivering scratch ticket information to the mobile application when called. Orignially, the application used PHP and the SimpleHTMLDom framework for scraping information from lottery websites. It has since been changed to use 16 Python scripts to scrape this information and insert it into an AWS MySQL database. The mobile app accesses information from the db through an Azure web app. The scripts folder doesn't contain the PHP scripts used to deliver data to the mobile app, however it does contain the webscrapers for each state.

This app is used to display information about scratch tickets from 16 states. It was originally a paid application, users could purchase subscriptions to view data from specific states. Since its originial release, it has been updated to remove subscriptions and allow users to view data after watching an ad.
