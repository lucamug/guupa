decimals = 1000000;
$(document).ready(function()
{
  // latlng = new google.maps.LatLng(43.77, 11.25); // Italy
  latlng = new google.maps.LatLng($("#post_map_lat").html()/decimals, $("#post_map_lng").html()/decimals); // Italy
  zoom_level = 13;
  var mapOptions = {
      center: latlng,
      zoom: zoom_level,
      streetViewControl: false,
      mapTypeControl: true,
      panControl: false,
      zoomControl: true,
      zoomControlOptions: {
          style: google.maps.ZoomControlStyle.SMALL,
          position: google.maps.ControlPosition.LEFT_TOP
      },
      scaleControl: false,
      scaleControlOptions: {
          position: google.maps.ControlPosition.RIGHT_BOTTOM
      },
      mapTypeId: google.maps.MapTypeId.ROADMAP
  };

  map = new google.maps.Map(document.getElementById("map_area"), mapOptions);
  var markerOptions = {
    position: latlng, 
    map: map, 
    icon: "/icons/marker_bulb_combined.png",
    title: "",
    visible: true,
    draggable: false
  };
  var marker = new google.maps.Marker(markerOptions);   
});

