'use strict';

function Map(id) {
  this.map = L.map(id, {
    minZoom: 2,
    maxZoom: 7
  });

  L.tileLayer('http://maps.vinc.cc/terrain/{z}/{x}/{y}.png', {
    attribution: ''
  }).addTo(this.map);

  L.control.scale({
    metric: true,
    imperial: false
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
      var popup = '<h1><a href="' + point.path + '">' + point.title + '</a></h1>';

      if (point.population) {
        popup += '<p><strong>Population:</strong> ' + parseInt(point.population, 10).toLocaleString() + '</p>';
      }
      if (point.elevation) {
        popup += '<p><strong>Elevation:</strong> ' + parseInt(point.elevation, 10).toLocaleString() + ' m</p>';
      }

      return L.geoJson(location, {
        pointToLayer: function (feature, latlng) {
          return L.circleMarker(latlng, markerOptions);
        }
      }).bindPopup(popup).addTo(map);
    });

    if (markers.length) {
      map.fitBounds(L.featureGroup(markers).getBounds(), { maxZoom: 6 });
    } else {
      map.setView([20, 0], 2);
    }
  };

  this.bbox = function() {
    return this.map.getBounds().toBBoxString();
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
  var toggleInput = function(checkbox) {
    var target = $('#form_' + checkbox.attr('id').replace('query_', ''));

    if (checkbox.is(':checked')) {
      target.show();
    } else {
      target.hide();
    }
  };

  $('input[type=checkbox]').each(function() {
    toggleInput($(this));
  });
  $('input[type=checkbox]').change(function() {
    toggleInput($(this));
  });

  $('input[type=slider]').each(function() {
    var input = $(this);
    var options = { tooltip: 'hide' };

    ['value', 'min', 'max', 'step'].forEach(function(attr) {
      options[attr] = JSON.parse(input.attr(attr));
    });

    input.slider(options).on('slideStop', function(e) {
      var value = e.value || options.min; // FIXME: 0 become undefined

      input.val(JSON.stringify(value));
    });

    input.slider(options).on('slide', function(e) {
      var value = e.value || options.min;
      var i = 0;
      var helper = input.next();
      if (helper.length === 0) {
        return;
      }
      var html = helper.html();

      if (!Array.isArray(value)) {
        value = [value];
      }
      html = html.replace(/([-0-9.,]+)/g, function(match) {
        return parseInt(value[i++]).toLocaleString();
      });
      helper.html(html);
    });
  });
});
