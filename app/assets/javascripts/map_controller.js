var geocoder;
var map;
var marker;
var first = true;
var last_event;
var decimals = 1000000;
var country_found = false;
var original_text;
var markersHash = new Array();
// var nz = new google.maps.LatLngBounds(new google.maps.LatLng(-48.3124000,164.9268000), new google.maps.LatLng(-34.1118000,180.0000000))


$(document).ready(function()
{

$.ajaxSetup({  
    'beforeSend': function (xhr) {xhr.setRequestHeader('Accept', 'text/javascript')}  
});


  $(".non_geo").hover(
    function () {
    	$(this).removeClass().addClass("non_geo_hover");
    }, 
    function () {
    	$(this).removeClass().addClass("non_geo");		
    }
  );
  $(".geo").hover(
    function () {
    	$(this).removeClass().addClass("geo_hover");
    }, 
    function () {
    	$(this).removeClass().addClass("geo");		
    }
  );
  $(".big_button").hover(
    function () {
    	$(this).removeClass().addClass("big_button_hover");
    }, 
    function () {
    	$(this).removeClass().addClass("big_button");		
    }
  );

  // Be carfult in the next line in case there are spaces before the bounds
  a = $("#bounds").html().split(" ");
  show_bounds = true
  if ($("#bounds").html() == "-20000000 000000000 50000000 360000000")
  {
    // Hide the square if the area is "world"
    show_bounds = false
  }
  sw = new google.maps.LatLng(parseFloat(a[0])/decimals, parseFloat(a[1])/decimals);
  ne = new google.maps.LatLng(parseFloat(a[2])/decimals, parseFloat(a[3])/decimals);

  var latlng;
  var bounds;
  var zoom_level;
  var ne;
  var sw;
  // var latlng = new google.maps.LatLng(35.6337281037138, 139.71843481063843);   // Japan
  latlng = new google.maps.LatLng(43.77, 11.25); // Italy
  zoom_level = 4;
  // var latlng = new google.maps.LatLng(48.85,2.35); // France
  //sw = new google.maps.LatLng(42, 4);
  //ne = new google.maps.LatLng(45, 18);

  bounds  = new google.maps.LatLngBounds(sw, ne);
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
  map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
  map.fitBounds(bounds);
  if (show_bounds) {boundingBox.setMap(map)}
  google.maps.event.addListener(map, 'zoom_changed', zoomChanged);

//  $.ajax({
//     type: "GET",
//     url: document.URL,
//     dataType: "script"
//   });


  var infowindow = new google.maps.InfoWindow({
      content: 'ciao'
  });

  // Create one infobubble that will be shared among all markers
  infoBubble2 = new InfoBubble({
    map: map,
    content: '<div class="phoneytext">Ciao</div>',
    // position: new google.maps.LatLng(-35, 151),
    shadowStyle: 1,
    padding: 0,
    backgroundColor: 'rgb(57,57,57)',
    borderRadius: 4,
    arrowSize: 10,
    borderWidth: 2,
    borderColor: '#2c2c2c',
    disableAutoPan: true,
    hideCloseButton: true,
    arrowPosition: 30,
    backgroundClassName: 'phoney',
    arrowStyle: 2,
    minWidth: 130,
    minHeight: 104
  });


// 120px; haight: 90px
  $.ajax({
    // url: document.URL.replace(/\?.*$/, "") + "?format=js",
    url: document.URL,
    cache: false,
    success: function(html){
      build_markers(html, map, infowindow);
    }
  });
});

function build_markers(returned_data, map, infowindow)
{
  b = eval( returned_data );
  for ( var i = b.length-1; i >= 0; --i )
  {
    var lat = b[i][0]*100/decimals
    var lng = b[i][1]*100/decimals
    var id  = b[i][2]
    var icon = "/icons/marker_bulb_combined.png"
    // var randomnumber=Math.floor(Math.random()*4)
    // if (randomnumber == 1)
    // {
    //   icon = "/icons/marker_l.png"
    // }
    // if (randomnumber == 2)
    // {
    //   icon = "/icons/marker_h.png"
    // }
    
    var marker = new google.maps.Marker({
      position: new google.maps.LatLng( lat, lng ),
      // animation: google.maps.Animation.DROP,
      icon: icon,
      map: map,
      post_id: "" + id
    });   

//    google.maps.event.addListener(marker, 'click', function() {
//      infowindow.open(map,this);
//    });

    google.maps.event.addListener(marker, 'click', function() {
      infoBubble2.setContent('<div class="phoneytext"></div>');
      infoBubble2.open(map,this);
//      infoBubble2.close();
      url = $("#uri_current_area").html() + "/posts/" + this.post_id
      $.ajax({
        // url: document.URL.replace(/\?.*$/, "") + "?format=js",
        url: url,
        cache: false,
        success: function(returned_data){
          eval (returned_data)
          // infoBubble2.close();
//          alert(html)
          infoBubble2.setContent(html);
          infoBubble2.open();
        }
      });
    });
    google.maps.event.addListener(map, 'click', function() {
      infoBubble2.close();
    });

    markersHash[id] = marker
  }   
  //  markersHash[174].icon = "/icons/green.png"
  // markersHash[174].setAnimation(google.maps.Animation.DROP);
//  markersHash[174].icon = "/icons/small_black.png"
//  markersHash[44].icon = "/icons/small_black.png"
//  markersHash[770].icon = "/icons/small_black.png"

 var foot = new google.maps.MarkerImage('/icons/foot.png',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(30, 30),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(28, 43));
 var plane = new google.maps.MarkerImage('/icons/plane.png',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(30, 30),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(28, 43));
 var up = new google.maps.MarkerImage('/icons/up.png',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(30, 30),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(2, 43));
 var down = new google.maps.MarkerImage('/icons/down.png',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(30, 30),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(2, 43));

//  var marker = new google.maps.Marker({
//    position: markersHash[174].position,
//    // animation: google.maps.Animation.DROP,
//    icon: foot,
//    map: map,
//    title: "test"
//  });   
//
//  var marker = new google.maps.Marker({
//    position: markersHash[174].position,
//    // animation: google.maps.Animation.DROP,
//    icon: up,
//    map: map,
//    title: "test"
//  });   
//
//  var marker = new google.maps.Marker({
//    position: markersHash[733].position,
//    // animation: google.maps.Animation.DROP,
//    icon: down,
//    map: map,
//    title: "test"
//  });   
//  var marker = new google.maps.Marker({
//    position: markersHash[733].position,
//    // animation: google.maps.Animation.DROP,
//    icon: plane,
//    map: map,
//    title: "test"
//  });   
//  var marker = new google.maps.Marker({
//    position: markersHash[174].position,
//    // animation: google.maps.Animation.DROP,
//    icon: "/icons/heart.png",
//    map: map,
//    title: "test"
//  });   
//  var marker = new google.maps.Marker({
//    position: markersHash[44].position,
//    // animation: google.maps.Animation.DROP,
//    icon: "/icons/broken.png",
//    map: map,
//    title: "test"
//  });   
//  var marker = new google.maps.Marker({
//    position: markersHash[770].position,
//    // animation: google.maps.Animation.DROP,
//    icon: "/icons/plane.png",
//    map: map,
//    title: "test"
//  });   

  //for (var i = 0; i < myArray.length; i++) {
	//  alert('key is: ' + i + ', value is: ' + myArray[i]);
  //}
}

function processSVData(data, status) {
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


function zoomChanged()
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

function handleEnter (field, event) // from http://www.dynamicdrive.com/dynamicindex16/disableenter.htm
{
  var keyCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
  if (keyCode == 13)
  {
    geocode();
    event.preventDefault();
  }
}

function geocode()
{
  var address = $("#issue_address_by_user").val();
  if (address != "")
  {
    geocoder.geocode({'address': address, 'partialmatch': true, 'language': 'en'}, geocodeResult);
  }
}

function geocodeResult(results, status)
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
    codeLatLng(pos, map);

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

function codeLatLng(latlng, map_local)
{
//  zoom = map_local.getZoom();
//  codeLatLng
  // Query the Google map api to get data about that position. After the data is
  // parsed, it format the result in parsed_result that will be processed
  // by Ruby in "isser.rb", the method "process_data_from_map_api"
  if (geocoder)
  {
    // In the following line, the language does not work because it has been deleted.
    geocoder.geocode({'latLng': latlng, 'language': 'en'}, function(results, status)
    {
      var output = [];
      output.push("lat:" + r2(latlng.lat()));
      output.push("lng:" + r2(latlng.lng()));
      output.push("b:" + viewport_or_bound_to_string(map_local.getBounds()));
      output.push("z:" + map_local.getZoom());
      if (status == google.maps.GeocoderStatus.OK)
      {
        var parsed_result = parse_results(results);
        if (parsed_result['country']     != undefined) { output.push("c:" + remove_column_and_semi_column(parsed_result['country']["name"]))                           }
        if (parsed_result[3]             != undefined) { output.push("3:" + parsed_result[3]["name"] + "(" + parsed_result[3]["bounds"] + ")")                         }
        if (parsed_result[4]             != undefined) { output.push("4:" + parsed_result[4]["name"] + "(" + parsed_result[4]["bounds"] + ")")                         }
        if (parsed_result[5]             != undefined) { output.push("5:" + parsed_result[5]["name"] + "(" + parsed_result[5]["bounds"] + ")")                         }
        if (parsed_result['postal_code'] != undefined) { output.push("p:" + parsed_result['postal_code']["name"] + "(" + parsed_result['postal_code']["bounds"] + ")") }
        if (parsed_result['address']     != undefined) { output.push("a:" + remove_column_and_semi_column(parsed_result['address']['name']))                           }
        $("#address_from_api").html(parsed_result['address']['name']);
//        $("#geocode_info").html("<pre>" + xinspect_1(results) + '\n' + xinspect(results) + "</pre>");
      } 
      else
      {
        $("#address_from_api").html(original_text + " (" + status + ")");
      }
      $("#issue_api_data").val(output.join("; "));
    });
  }
}

function remove_column_and_semi_column(text)
{
  // This function need to be done
  return text;
}

function search_country(sub_result)
{
  // This part is necessary because sometime the country is not available in the list.
  for (var i = sub_result.length - 1; i >= 0; i--)
  {
    for(var ii in sub_result[i]["types"])
    {
      if (sub_result[i]["types"][ii] != 'political')
      {
        if (sub_result[i]["types"][ii] == 'country')
        {
          country_found = true;
          return sub_result[i]['long_name']
        }
      }
    }
  }
  return false;
}

function parse_results(results)
{
  var myResult = [];
  myResult['skipped'] = [];
  var re = /locality|administrative/;
  country_found = false;
  level = 3
  for (var i = results.length - 1; i >= 0; i--)
  {
    for(var ii in results[i]["types"])
    {
      if (results[i]["types"][ii] != 'political')
      {
        if (!country_found) 
        {
          var country = search_country(results[i]["address_components"]);
          if( country )
          {
            myResult['country'] = [];
            myResult['country']["name"]   = country;
          }
        }
        if (results[i]["types"][ii] == 'postal_code')
        {
          myResult['postal_code'] = [];
          myResult['postal_code']["name"]   = results[i]["address_components"][0]["long_name"];
          myResult['postal_code']["bounds"] = return_bounds(results[i]["geometry"]);
        }
        else if ((level < 6) && (results[i]["types"][ii].match(re)))
        {
          myResult[level] = [];
          myResult[level]["name"]   = results[i]["address_components"][0]["long_name"];
          myResult[level]["bounds"] = return_bounds(results[i]["geometry"]);
          myResult[level]["type"]   = results[i]["types"][ii];
          level ++;
        }
        else if (i == 0)
        {
          // This is here only to avoid i==0 going amongs skipped
        }
        else
        {
          myResult['skipped'].push("Type: " + results[i]["types"][ii] + " (" + results[i]["formatted_address"] + ")" );
        }
        if (i == 0)
        {
          myResult['address'] = new Array();
          myResult['address']["name"]     = results[i]["formatted_address"];
          myResult['address']["bounds"]   = return_bounds(results[i]["geometry"]);
          myResult['address']["type"]     = results[i]["types"][ii];
        }
      }
    }
  }    
  return myResult;
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


function xinspect_1(results)
{
  var parsedResult = parse_results(results);
  var simpleParsedResult = simple_parse_results(results);
  var str = '';
  str = str + 'length ' + results.length + '\n';
  str = str + "\n\n\n" + xinspect(parsedResult) + "\n\n\n";
  str = str + simpleParsedResult;
  return 'START_INSPECT\n' + str + 'END_INSPECT\n';
}

function return_bounds(object)
{
  if(typeof object["viewport"] != undefined) {return viewport_or_bound_to_string(object["viewport"])}
  if(typeof object["bounds"]   != undefined) {return viewport_or_bound_to_string(object["bounds"])}
  return undefined;
}

function viewport_or_bound_to_string(bv)
{
  // "getSouthWest" this.ta.b,this.ma.d
  // "getNorthEast" this.ta.d,this.ma.b
  a = bv.toUrlValue().split(",");
  return r2(a[0]) + " " + r2(a[1]) + " " + r2(a[2]) + " " + r2(a[3]);
}

function r2(value)
{
  return Math.round(value*decimals);
}



function xinspect(o,i){
  if(typeof i == 'undefined') i = '';
  if(i.length > 50) return '[MAX ITERATIONS]';
  var r = [];
  var str = '';
  for(var p in o)
  {
    var t = typeof o[p];
    if (t == 'object')
    {
      r.push("\n" + i + '"' + p + '" (' + t + ') =>');
      r.push('\n' + xinspect(o[p], i + '    '));
    }
    else
    {
      r.push(i + '"' + p + '" (' + t + ') => ' + o[p]);
    }
  }
  return r.join('\n');
}


