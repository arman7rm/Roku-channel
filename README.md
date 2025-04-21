# Roku-channel

Instructions to View: Upload the my-roku-app.zip file to your Roku Development Application installer to view.

# Thoughts
This was a fun project to learn SceneGraph and  BrightScript. It is a simple UI that initially renders an Overhang and a loading component while 
fetching data from an API in the background. Once the data is retrieved, validated and sanitized, it is stored in a content node which is used to render a GridScreen that features a ZoomList Component, displaying various titles (in the form of rowListItemComponents) in categorical rows. 

# Future improvements - What I would do given more time with this feature:
- Add unit testing for the various brs files ensuring comoponents load and methods execute as expected.
- Dynamically render ref sets as they appear in view
- Architect a better system for handling broken payload links like images.
- Store commonly used functions like get API data into a globally accessbile file 
- Optimize retrieval of fields from deeply nested payloads
- Create component to display when API fails and no content could be loaded
- Add exponential backoff on API calls to mitigate network failures
- Add logging
- Add Linting
