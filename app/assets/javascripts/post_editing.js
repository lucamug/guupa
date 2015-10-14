// Global variables
decimals = 1000000;
// Start
$(document).ready(function()
{
  var first = true;
  // Be carfult in the next line in case there are spaces before the bounds
  var a = $("#bounds").html().split(" ");
  var show_bounds = true
  if ($("#bounds").html() == "-20000000 000000000 50000000 360000000")
  {
    // Hide the square if the area is "world"
    show_bounds = false
  }
  var sw = new google.maps.LatLng(parseFloat(a[0])/decimals, parseFloat(a[1])/decimals);
  var ne = new google.maps.LatLng(parseFloat(a[2])/decimals, parseFloat(a[3])/decimals);
  var existing_marker = false
  var latlng;
  var bounds;
  var zoom_level;
  var ne;
  var sw;
  if ( $("#post_map_lat").html() != "" && $("#post_map_lng").html() != "" )
  {
    // A marker is already been set
    latlng = new google.maps.LatLng($("#post_map_lat").html()/decimals, $("#post_map_lng").html()/decimals); // Italy
    zoom_level = $("#post_map_zoom").html() * 1;
    existing_marker = true
  }
  var bounds  = new google.maps.LatLngBounds(sw, ne);
  var boundingBoxPoints = [
      ne, new google.maps.LatLng(ne.lat(), sw.lng()),
      sw, new google.maps.LatLng(sw.lat(), ne.lng()), ne
   ];
  var boundingBox = new google.maps.Polyline({
            path: boundingBoxPoints,
            strokeColor: 'brown',
            strokeOpacity: 0.6,
            strokeWeight: 1
         });
  var geocoder = new google.maps.Geocoder();
  var mapOptions = {
      center: latlng,
      zoom: zoom_level,
      streetViewControl: false,
      mapTypeControl: true,
      panControl: false,
      zoomControl: true,
      zoomControlOptions: {
          style: google.maps.ZoomControlStyle.LARGE,
          position: google.maps.ControlPosition.LEFT_TOP
      },
      scaleControl: true,
      scaleControlOptions: {
          position: google.maps.ControlPosition.RIGHT_BOTTOM
      },
      mapTypeId: google.maps.MapTypeId.TERRAIN
  };
  var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  if (!existing_marker) {map.fitBounds(bounds)}
  if (show_bounds) {boundingBox.setMap(map)}
  var markerOptions = {
    position: latlng, 
    map: map, 
    title: "Hello World!",
    visible: true,
    draggable: true
  };
  var marker = new google.maps.Marker(markerOptions);   
  google.maps.event.addListener(map, 'click', function(me){
    if (first)
    {
      first = false
      marker.setVisible(true);
    }
    marker.setPosition(me.latLng);
    // map.panTo(me.latLng);
    codeLatLng(me.latLng, map, geocoder);
    //sv.getPanoramaByLocation(me.latLng, 50, processSVData);
  });
  google.maps.event.addListener(marker, 'dragend', function(me){
    codeLatLng(me.latLng, map, geocoder);
    //sv.getPanoramaByLocation(me.latLng, 50, processSVData);
  });
  google.maps.event.addListener(map, 'zoom_changed', function(){zoomChanged(map)});
  $("#post_address_by_user").keypress(function() {return handleEnter(this, event, geocoder, map, marker, first)})
  $("#find_button").click(             function() {my_geocode(                     geocoder, map, marker, first)})
});

function codeLatLng(latlng, map, geocoder)
{
  // Query the Google map api to get data about that position. After the data is
  // parsed, it format the result in parsed_result that will be processed
  // by Ruby in "isser.rb", the method "process_data_from_map_api"
  if (geocoder)
  {
    // In the following line, the language does not work because it has been deleted
    // by Google developers.
    geocoder.geocode({'latLng': latlng, 'language': 'en'}, function(results, status)
    {
      var a = parse_google_result(results, status, latlng, map)
      if (a.address != undefined)
      {
        $("#address_from_api").html(a.address);
      }
      else
      {
        $("#address_from_api").html(a.error);
      }
      $("#post_map_data").val(a.output.join("; "));
    });
  }
}

function processSVData(data, status)
{
  if (status == google.maps.StreetViewStatus.OK)
  {
    panorama.setVisible(true);
    panorama.setPano(data.location.pano);
    panorama.setPov({
      heading: 270,
      pitch: 0,
      zoom: 1
    });
  } 
  else 
  {
    panorama.setVisible(false);
  }
}


function zoomChanged(map)
{
  if ((map.getMapTypeId() == "roadmap") && (map.getZoom() < 13))
  {
    map.setMapTypeId("terrain");
  }
  else if ((map.getMapTypeId() == "terrain") && (map.getZoom() >= 13))
  {
    map.setMapTypeId("roadmap");
  }
}

function handleEnter(field, event, geocoder, map, marker, first) // from http://www.dynamicdrive.com/dynamicindex16/disableenter.htm
{
  var keyCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
  if (keyCode == 13)
  {
    my_geocode(geocoder, map, marker, first);
    event.preventDefault();
  }
}

function my_geocode(geocoder, map, marker, first)
{
  var address = $("#post_address_by_user").val();
  if (address != "")
  {
    geocoder.geocode({'address': address, 'partialmatch': true, 'language': 'en'}, function(results, status)
    {
      geocodeResult(results, status, geocoder, map, marker, first)
    });
  }
}

function geocodeResult(results, status, geocoder, map, marker, first)
{
  if (status == 'OK' && results.length > 0)
  {
    var latLng = results[0].geometry.viewport.getCenter();
    map.setZoom(11);
    //map.panTo(results[0].geometry.viewport)
    map.fitBounds(results[0].geometry.viewport); // This is just to set the right zoom level
    map.setCenter(results[0].geometry.location)  // This is to re-center the map
    pos = results[0].geometry.location;
    marker.setPosition(pos);
    if (first)
    {
      first = false
      marker.setVisible(true);
    }
    codeLatLng(pos, map, geocoder);
    // click_on_the_map(null,latLng_v2)
  }
  else
  {
    alert("Address not found: " + status);
  }
}



function round(value)
{
  return Math.round(value*decimals)/decimals;
}


function simple_parse_results(results)
{
  var str = '';
  for(var object in results)
  {
    for(var type in results[object]["types"])
    {
      if (results[object]["types"][type] != 'political')
      {
        var formatted_address = ""
        if (object == 0)
        {
          formatted_address = " (" + results[object]["formatted_address"] + ") ";
        }
        str = str
        + object
        + " " 
        + results[object]["types"][type]
        + ": " 
        + results[object]["address_components"][0]["long_name"]
        + formatted_address
        + results[object]["geometry"]["bounds"]
        + "\n";
      }
    }
  }
  return str;
}


