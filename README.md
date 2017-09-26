# FITLGTest

Just a test app submitted by Matt Quiros

## Instructions from the Interviewers

1. The screen contains a search bar and initial data that displays the top 20 nearby restaurants. (Use google map api). The list of nearby restaurant should display an image, name, address, and distance from the user's current location.

2. Upon searching, an auto complete functionality should be implemented  to search for specific restaurant nearby the user.

3. Restaurant details should be displayed on a separate screen after clicking the item. Details should display an image, name, address, distance, and google map (use latitude/longitude).

## What I Did

1. The first screen does contain a non-functional search bar, and loads the restaurants nearest to the user. This uses the Google Places API, has infinite scrolling (meaning, more data can be loaded as you scroll to the bottom), and non-laggy image downloading. It makes requests to two API endpoints:
    * Google Places Search API - to get the list of nearby locations
    * Google Places Photos API - to get the photo for every single search result once they come back from the Search API. One request is made for every single search result, but the images are cached after the first time they are retrieved.

2. Clicking on a search result opens a detail screen and fires multiple requests to the following APIs:
    * Google Place Details API - to get the full details on the selected search result
    * Google Place Photos API - to get a higher-resolution version of the image
    * Google Static Maps API - to get the search result in a static map view

3. I no longer included the search and autocomplete functionality because the test project is already a ton of work as it is. Doing so will only entail the construction of more API calls to Google Places Query Autocomplete API and more screens, which will not be fundamentally different in implementation as with the two screens I already built. If the intention with this exam is for you to see my code style and problem solving abilities, then the two features above are complex enough and you won't see anything new even if I completed the autocomplete feature.

## How to Run

1. Clone this repository.
2. Use Xcode 8. The project is in Swift 3.
3. Run on the iOS 10.3 Simulator.
