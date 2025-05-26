# Where Is That Plane Going?

This repository contains a simple automation designed for iPhones. Its purpose is to let you quickly identify the destination of a plane flying overhead — all with a single tap.

## How it works

1. You tap the shortcut.
2. The shortcut retrieves your current location as GPS coordinates.
3. These coordinates are sent as HTTP headers to a custom-made REST API, which reformats the request to match the requirements of the Flightradar24 API. The system assumes a 7 km radius in all cardinal directions and searches for nearby aircraft.
4. If a plane is detected, its origin and destination are retrieved as [ICAO codes](https://en.wikipedia.org/wiki/ICAO_airport_code). These codes are translated into plain-language airport names.
5. A JSON response with a single `"Message"` field is returned to the Shortcut and displayed to the user.

![Example result](https://github.com/malmriv/malmriv.github.io/blob/master/images/captura_witpg.jpeg?raw=true)

## Implementation

The full implementation details will be shared in an upcoming blog post. For now, here is a high-level overview:

1. The Shortcut is built using Apple's default tools — nothing fancy. (Surprisingly, it includes JSON parsing capabilities, although these are somewhat hidden under the label "lists").
2. A `GET` request is sent to an API, including two custom headers: `Latitud` and `Longitud`, each containing the user's location in degrees.
3. The API is deployed in a Docker container on a server. I used [Render.com](https://render.com) because its free plan was sufficient for my needs. The API consists of two R scripts:  
   - One exposes the API using [Plumber](https://www.rplumber.io/)  
   - The other handles the logic using [httr2](https://httr2.r-lib.org/) and [jsonlite](https://cran.r-project.org/web/packages/jsonlite/index.html)
4. The API receives the user's location and computes the bounding box spanning 7 km in all directions. It then queries the Flightradar24 API to identify nearby aircraft (usually just the most visible one). No additional filtering logic is applied — the first result is typically enough, even near airports.
5. The Flightradar24 response is translated into human-readable text by mapping ICAO airport codes to actual airport names using a resource like the [OurAirports database](https://ourairports.com/data/).
6. The Shortcut receives the result as a JSON object with a single `"Message"` field, which is then displayed as a notification.
