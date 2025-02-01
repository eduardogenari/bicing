import pandas as pd
import folium
import branca.colormap as cm

# Load the data from the pickle file
stations_data = pd.read_pickle("stations_data.pkl")

# Create a map centered around Barcelona with a grayscale background
barcelona_map = folium.Map(
    location=[41.3851, 2.1734],
    zoom_start=13,
    tiles='CartoDB positron'
)

# Create a color scale from the lightest red to a darker red
color_scale = cm.LinearColormap(['#ffcccc', '#8b0000'], vmin=0, vmax=166)

# Add a dot for each station with color based on the altitude
for _, station in stations_data.iterrows():
    folium.CircleMarker(
        location=[station['lat'], station['lon']],
        radius=3,
        color=color_scale(station['altitude']),
        fill=True,
        fill_color=color_scale(station['altitude'])
    ).add_to(barcelona_map)

# Save the map to an HTML file
barcelona_map.save("stations_map.html")
