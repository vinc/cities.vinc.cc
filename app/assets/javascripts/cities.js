var genMap = function(points) {
  var map = L.map('map').setView([20, 0], 2);
  var marker = {
    radius: 4,
    fillColor: 'turquoise',
    color: '#999',
    weight: 1,
    opacity: 1,
    fillOpacity: 0.8
  };

  L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
    attribution: '<a href="http://osm.org/copyright">OpenStreetMap</a>'
  }).addTo(map);


  for (var i = 0, n = points.length; i < n; i++) {
    var point = points[i].city.location;

    L.geoJson(point, {
      pointToLayer: function (feature, latlng) {
        return L.circleMarker(latlng, marker);
      }
    }).addTo(map);
  }
};
