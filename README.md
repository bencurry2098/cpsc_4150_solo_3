# Dog Gallery App
**Created by Benjamin Curry**
A Flutter app that displays dog images using the [Dog CEO API](https://dog.ceo/dog-api/).  
Users can view random dog photos or search for specific breeds.

---

## API Used
- **Base URL:** `https://dog.ceo/api/`
- **Example Endpoint (Random):**  -
  ```
  https://dog.ceo/api/breeds/image/random/12
  ```
- **Example Endpoint (By Breed):**  
  ```
  https://dog.ceo/api/breed/hound/images/random/12
  ```

The API returns a JSON response containing an array of image URLs.

---

## How to Run
1. Ensure Flutter is installed and configured.
2. Clone or copy the project files into a directory.
3. Run the app with:
   ```bash
   flutter run
   ```
4. Select a device or emulator when prompted.

---

## User Actions
- **Search:**  
  Enter a dog breed (e.g., “hound”) and press **Enter** or tap the **Search** icon.
- **Refresh:**  
  Use the **Refresh** button on the app bar or the **Fetch** floating button to reload images.
- **Pull-to-Refresh:**  
  Drag down on the image grid to refresh results.

---

## Edge Case Handling
**Case:** Searching for a non-existent breed (e.g., “xyzdog”).  
**Behavior:**  
The app catches the API error and displays an error message with a retry button instead of crashing.  
This ensures graceful error handling and a responsive UI.
