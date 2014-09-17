'use strict';

function Map(id) {
  this.map = L.map(id, {
    minZoom: 2,
    maxZoom: 5
  });

  L.tileLayer('http://maps.vinc.cc/v2/relief/{z}/{x}/{y}.png', {
    attribution: '<a href="http://vinc.cc">Vinc</a>'
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
      var location = point.location;
      var popup = '<a href="' + point.path + '">' + point.title + '</a>';

      return L.geoJson(location, {
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, markerOptions);
        }
      }).bindPopup(popup).addTo(map);
    });

    if (markers.length) {
      map.fitBounds(L.featureGroup(markers).getBounds(), { maxZoom: 4 });
    } else {
      map.setView([20, 0], 2);
    }
  };
}

$(document).on('page:change', function() {
  if (window._gaq != null) {
    return _gaq.push(['_trackPageview']);
  } else if (window.pageTracker != null) {
    return pageTracker._trackPageview();
  }
});

$(document).on('ready page:load', function() {
  $('input[type=slider]').each(function() {
    var input = $(this);
    var options = {};

    ['value', 'min', 'max', 'step'].forEach(function(attr) {
      options[attr] = JSON.parse(input.attr(attr));
    });

    input.slider(options).on('slideStop', function(e) {
      var value = JSON.stringify(e.value || JSON.parse(input.attr('min'))); // FIXME: 0 become undefined

      input.val(value);

      console.log(value);
      console.log(input.val());
    });
  });
});
