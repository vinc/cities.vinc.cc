'use strict';

function Map(id) {
  this.map = L.map(id, {
    minZoom: 2,
    maxZoom: 6
  });

  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '<a href="http://osm.org/copyright">OpenStreetMap</a>'
  }).addTo(this.map);

  this.add = function(points, color) {
    var map = this.map;

    var markerOptions = {
      radius: 8,
      fillColor: color,
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

    if (markers.length) {
      map.fitBounds(L.featureGroup(markers).getBounds(), { maxZoom: 4 });
    } else {
      map.setView([20, 0], 2);
    }
  };
}
