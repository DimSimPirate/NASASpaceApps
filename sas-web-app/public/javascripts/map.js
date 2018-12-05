var markers = [];
var map;
var summaries = [];
var currentCountry = null;

function init() {
  initSlider()
}

function initMap() {
  map = new google.maps.Map(document.getElementById('map'), {
    zoom: 3,
    center: {lat: 20, lng: 100},
    mapTypeId: 'roadmap'
  });

  $.get('/disaster_full', x => addPoints(x.data))
  $.get('/disaster_summary', x => initSummary(x.data))
  initAutocomplete()
}

function initSummary(points) {
  points.forEach(point => {
    summaries.push(point);
  });
}

function initSlider () {
  var slider = document.createElement('div')
  noUiSlider.create(slider, {
    start: [2007],
    connect: [false,false],
    range: {
      'min': 2007,
      'max': 2017
    },
    step: 1
  })
  slider.noUiSlider.on('update', function (values, handle) {
    var year = String(values[0]).slice(0, 4)
    $('#year').text("Year: " + year)
    $('#year').data('year', year)
    displayCountryInfo(currentCountry)
    filterDates()
  })
  var selector = '#slider'
  $(selector).empty().append(
    $('<div>').attr('class', '.no-ui-slider').append(slider)
  )
}


var filterDates =  _.debounce(function(){
  console.log("filtering dates")
  var selected = Number($('#year').data('year'))
  markers.forEach(m => {
    var year = Number(m.info.date.slice(0, 4));
    if (year === selected){
      m.setVisible(true)
    } else {
      m.setVisible(false)
    }
  })
}, 300)


function displayCountryInfo(country) {
  if (country == null) {
    return
  }
  var year = Number($('#year').data('year'))
  var countryInfo;
  var disp = false;
  for (i = 0; i < summaries.length; i++) {
    if (country == summaries[i].country && year == summaries[i]['year(date)']) {
      countryInfo = summaries[i]
      console.log(countryInfo)
      disp = true;
    }
  }

  if (disp == false) {
    return
  }
  clearTable('summaryTable')
  clearTable('countryTable')

  addRow('countryTable','Total Landslides', marker.countryInfo.landslides)
  addRow('countryTable','Total Earthquakes', marker.countryInfo.earthquakes)
  fatalities = marker.countryInfo.fatalities
  if (fatalities == null) {
    fatalities = 0
  }
  addRow('countryTable','Total Fatalities', fatalities)
  avg_pop = marker.countryInfo.avg_affected_pop
  if (avg_pop != null) {

    addRow('countryTable','Average Affected Population', Math.round(avg_pop))
  }
}

function addPoints(points) {
  points.forEach(point => {
    if (!point.date) {
      return;
    }
    var pointCountry = point.country;
    var pointYear = parseInt(point.date.substring(0, 4));
    var countrySummary;
    for (i = 0; i < summaries.length; i++) {
      if (pointCountry == summaries[i].country && pointYear == summaries[i]['year(date)']) {
        countrySummary = summaries[i];
      }
    }

    var latLng = new google.maps.LatLng(point["latitude.dis"], point["longitude.dis"]);
    var marker = new google.maps.Marker({
      info: point,
      countryInfo: countrySummary,
      position: latLng,
      map: map,
      icon: getCircle(point.fatalities, point.hazard_type),
      visible: false
    });
    if (point.date)
      markers.push(marker)

    marker.addListener('click', function() {
      currentCountry == null
      console.log(marker.info)
      map.setCenter(marker.getPosition());
      clearTable('summaryTable')
      clearTable('countryTable')

      addRow('summaryTable', 'Country', marker.info.country)
      city = marker.info.city
      if (city != null) {
        addRow('summaryTable', 'City', city)
      }
      fatalities = marker.info.fatalities
      if (fatalities == null) {
        fatalities = 0
      }
      addRow('summaryTable', 'Fatalities', fatalities)
      addRow('summaryTable', 'Date', marker.info.date)
      trigger = marker.info.trigger
      if (trigger != null) {
        addRow('summaryTable', 'Trigger', trigger)
      }

      source_link = marker.info.source_link
      if (source_link != null) {
        name = marker.info.source_name
        linkName = "Source"
        if (name != null) {
          linkName = name
        }

        link = "<a href='" + source_link + "'>" + linkName + "</a>"
        $('#' + 'summaryTable').append($('<tr>').append(
          $('<td>').text("Source Link"),
          $('<td>').append(link)))

      }

      addRow('countryTable','Total Landslides', marker.countryInfo.landslides)
      addRow('countryTable','Total Earthquakes', marker.countryInfo.earthquakes)
      fatalities = marker.countryInfo.fatalities
      if (fatalities == null) {
        fatalities = 0
      }
      addRow('countryTable','Total Fatalities', fatalities)
      avg_pop = marker.countryInfo.avg_affected_pop
      if (avg_pop != null) {
        addRow('countryTable','Average Affected Population', Math.round(avg_pop))
      }
    });
  })
  filterDates()
}

function addRow(table, key, val) {
  $('#' + table).append($('<tr>').append(
    $('<td>').text(key),
    $('<td>').text(val)))
}
function clearTable(table) {
  $('#' + table).empty()
}


function getCircle(radius, hazard_type) {
  var colour = 'red';
  if (hazard_type === "earthquake") {
    colour = 'blue'
  }
  var scale = Math.sqrt(radius) + 10;
  scale = scale > 50 ? 50 : scale;
  return {
    path: google.maps.SymbolPath.CIRCLE,
    fillColor: colour,
    fillOpacity: .2,
    scale: Math.sqrt(radius) + 10,
    strokeColor: 'white',
    strokeWeight: 1
  };
}


function initAutocomplete () {
  // Create the search box and link it to the UI element.
  var input = document.getElementById('search')
  var searchBox = new google.maps.places.SearchBox(input)

  // Bias the SearchBox results towards current map's viewport.
  map.addListener('bounds_changed', function () {
    searchBox.setBounds(map.getBounds())
  })

  // Listen for the event fired when the user selects a prediction and retrieve
  // more details for that place.
  searchBox.addListener('places_changed', function () {
    var places = searchBox.getPlaces()

    if (places.length === 0) {
      return
    }

    // For each place, name and location.
    var bounds = new google.maps.LatLngBounds()
    places.forEach(function (place) {
      if (!place.geometry) {
        console.log('Returned place contains no geometry')
        return
      }

      //Gets the country for a specific place
      var filtered_array = place.address_components.filter(function(address_component){
        return address_component.types.includes("country");
      });
      var country = filtered_array.length ? filtered_array[0].long_name: "";
      currentCountry = country
      displayCountryInfo(country);

      if (place.geometry.viewport) {
        // Only geocodes have viewport.
        bounds.union(place.geometry.viewport)
      } else {
        bounds.extend(place.geometry.location)
      }
    })
    map.fitBounds(bounds)
  })
}
