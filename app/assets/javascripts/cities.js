var genMap = function(points) {
  var map = L.map('map', { minZoom: 2 });

  var markerOptions = {
    radius: 4,
    fillColor: 'turquoise',
    color: '#999',
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
  };

  var markers = points.map(function(point) {
    var location = point.city.location;

    return L.geoJson(location, {
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, markerOptions);
      }
    }).addTo(map);
  });

  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '<a href="http://osm.org/copyright">OpenStreetMap</a>'
  }).addTo(map);

  map.fitBounds(L.featureGroup(markers).getBounds(), { maxZoom: 2 });
};
