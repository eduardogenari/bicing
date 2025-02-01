import pandas as pd
import folium

# Load the data from the pickle file
stations_data = pd.read_pickle("stations_data.pkl")

# Create a map centered around Barcelona
barcelona_map = folium.Map(location=[41.3851, 2.1734], zoom_start=13)

# Add a red dot for each station
for _, station in stations_data.iterrows():
    folium.CircleMarker(
        location=[station['lat'], station['lon']],
        radius=3,
        color='red',
        fill=True,
        fill_color='red'
    ).add_to(barcelona_map)

# Save the map to an HTML file
barcelona_map.save("stations_map.html")
