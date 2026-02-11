 SheCare – Women Safety & Emergency Response System

SheCare is a real-time women safety application designed to provide multiple layers of emergency protection using sensor-based triggers, AI-powered voice analysis, and location-based alert systems.

The core goal of SheCare is simple:

To help someone in danger when no one else is around.

🚀 Tech Stack

Frontend: Flutter, HTML, CSS, JavaScript

Backend: Django

Database: MySQL

AI Processing: Voice emotion detection model

Sensors Used: Accelerometer (shake detection), Microphone, Hardware Volume Buttons

Location Services: GPS (Latitude & Longitude tracking)

🔥 Key Features
📍 1. Live Location Sharing

Users can share their real-time location while traveling.

Location data (latitude & longitude) is sent securely to the backend.

Emergency contacts receive precise coordinates during distress.

📱 2. Shake-to-SOS (Sensor-Based Emergency Trigger)

Uses mobile accelerometer sensor.

If shake value exceeds predefined threshold:

Sensor data is sent to backend.

System validates threshold breach.

SOS alert is sent automatically to registered emergency contacts.

🎤 3. AI-Based Voice Emotion Detection

User can activate microphone manually.

Audio is sent to backend AI model.

Model analyzes:

Fear

Distress

Anger

If emotional distress is detected → SOS is triggered.

🗣 4. Trigger Word Detection (Always Listening Mode)

Predefined keywords like:

“Help”

“Save me”

If detected → Automatic SOS alert.

🔘 5. Volume Button Triple Press SOS

Pressing volume button three times triggers:

Instant emergency alert

Location transmission

🚓 6. Emergency Request to Pink Police

Users can send direct distress request to nearby Pink Police unit.

Location is attached with the emergency request.

🗺 7. Safe & Unsafe Location Mapping

Users and authorities can:

Mark safe places

Mark dangerous zones

Helps others stay aware of risky areas nearby.

🛡 Security Architecture

Backend threshold validation prevents false triggering.

AI-based filtering reduces unnecessary alerts.

Secure database storage with Django ORM.

Real-time event handling and sensor monitoring.
