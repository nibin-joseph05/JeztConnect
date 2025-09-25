# JeztConnect

A Flutter application for Jezt Technologies demonstrating login, dashboard data fetching, and logout functionality. The app uses token-based authentication, polished UI, and graceful error handling to provide a smooth user experience.

## Features

* Animated splash screen with branding
* Login with Company ID and password (with validation and error messages)
* Dashboard displaying live API data in scrollable cards
* Pull-to-refresh functionality and retry on network errors
* Logout with confirmation
* Handles API errors gracefully
* Supports token-based authentication using Bearer tokens
* Clean, responsive UI compatible with multiple devices

## Screens

1. **Splash Screen**: Shows company branding while initializing the app.
2. **Login Screen**: Users can login using the provided test credentials. Displays inline validation and API error handling.
3. **Dashboard Screen**: Fetches and displays live data from the API in a scrollable view. Supports refresh and retry in case of network issues.
4. **Logout Flow**: Allows the user to logout and clears the token. Navigates back to the login screen.

## Test Credentials

* **Company ID**: 1048
* **Password**: Jeztai@1234

## API Endpoints

* **Login**: [https://cloud.jezt.tech/api/jezt/token/](https://cloud.jezt.tech/api/jezt/token/)
* **Dashboard**: [https://cloud.jezt.tech/api/viewfromjson/](https://cloud.jezt.tech/api/viewfromjson/)
* **Logout**: [https://cloud.jezt.tech/api/logout/](https://cloud.jezt.tech/api/logout/)

## Getting Started

1. Clone the repository:

git clone https://github.com/nibin-joseph05/JeztConnect.git

2. Navigate into the project directory:

cd JeztConnect

3. Install dependencies:

flutter pub get

4. Run the app on a connected device or emulator:

flutter run

## APK & Demo Video

Download the release APK and demo video from Google Drive:
[JeztConnect Release & Demo](https://drive.google.com/drive/folders/1JMtRKaBrT7M5yKHrGW7TH3-NIa76h90a?usp=sharing)

* The video demonstrates:

    * Splash screen → Login (validation, error handling)
    * Successful login with test credentials
    * Dashboard: live API data, refresh, error/retry handling
    * Logout flow with confirmation

## Notes

* The app uses token-based authentication. The access token from login is passed as a Bearer header for API calls.
* Polished UI with animations and responsive design.
* Graceful error handling ensures smooth user experience even with network issues.
* Compatible with Android devices. Ensure minimum SDK version 21.

## Author

**Nibin Joseph**
Email: [nibin.joseph.career@gmail.com](mailto:nibin.joseph.career@gmail.com)
Phone: +91 9778234876
