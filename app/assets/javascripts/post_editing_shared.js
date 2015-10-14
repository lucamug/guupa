function parse_google_result(results, status, latlng, map) // Parameters are always local variables
{
  var output = [];
  var address = undefined;
  var error = undefined;
  output.push("lat:" + round_value(latlng.lat()));
  output.push("lng:" + round_value(latlng.lng()));
  if (map != undefined)
  {
    output.push("b:" + viewport_or_bound_to_string(map.getBounds()));
    output.push("z:" + map.getZoom());
  }
  if (status == google.maps.GeocoderStatus.OK)
  {
    var parsed_result = parse_results(results);
    if (parsed_result['normal_country'] != undefined)
    {
      output.push("c:" + remove_column_and_semi_column(parsed_result['normal_country']["name"]) + "(" + parsed_result['normal_country']["bounds"] + ")")                           
    }
    else if (parsed_result['simple_country'] != undefined)
    {
      output.push("c:" + remove_column_and_semi_column(parsed_result['simple_country']["name"]))                           
    }
    if (parsed_result[3]             != undefined) { output.push("3:" + parsed_result[3]["name"] + "(" + parsed_result[3]["bounds"] + ")")                         }
    if (parsed_result[4]             != undefined) { output.push("4:" + parsed_result[4]["name"] + "(" + parsed_result[4]["bounds"] + ")")                         }
    if (parsed_result[5]             != undefined) { output.push("5:" + parsed_result[5]["name"] + "(" + parsed_result[5]["bounds"] + ")")                         }
    if (parsed_result['postal_code'] != undefined) { output.push("p:" + parsed_result['postal_code']["name"] + "(" + parsed_result['postal_code']["bounds"] + ")") }
    if (parsed_result['address']     != undefined) { output.push("a:" + remove_column_and_semi_column(parsed_result['address']['name']))                           }
    output.push("v: 1.0")
    address = parsed_result['address']['name'];
  } 
  else
  {
    error = status;
  }
  // About returning multiple values: http://javascript.about.com/library/blmultir.htm
  return {output: output, address: address, error: error};
}

function parse_results(results)
{
  // To understand this part, check at what Google Api return. Example
  // Working_example_with_marker.html in the public/google_maps folder
  var myResult = [];
  // myResult['simple_country'] = false;
  // myResult['normal_country'] = false;
  myResult['skipped'] = [];
  // Following are the type that I usually care.
  var re = /locality|administrative/;
  simple_country_found = false;
  level = 3
  for (var i = results.length - 1; i >= 0; i--)
  {
    for(var ii in results[i]["types"])
    {
      // Types can be more then one
      // 'political' is skipped because it always goes with anothe more
      // significant type
      if (results[i]["types"][ii] != 'political')
      {
        if (!simple_country_found) 
        {
          var country = search_country(results[i]["address_components"]);
          if( country )
          {
            myResult['simple_country'] = [];
            myResult['simple_country']["name"]   = country;
            simple_country_found = true;
          }
        }

        if (results[i]["types"][ii] == 'postal_code')
        {
          myResult['postal_code'] = [];
          myResult['postal_code']["name"]   = results[i]["address_components"][0]["long_name"];
          myResult['postal_code']["bounds"] = return_bounds(results[i]["geometry"]);
        }
        else if (results[i]["types"][ii] == 'country')
        {
          myResult['normal_country'] = [];
          myResult['normal_country']["name"]   = results[i]["address_components"][0]["long_name"];
          myResult['normal_country']["bounds"] = return_bounds(results[i]["geometry"]);
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
function round_value(value)
{
  return Math.round(value*decimals);
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
          // country_found = true;
          return sub_result[i]['long_name']
        }
      }
    }
  }
  return false;
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
  return round_value(a[0]) + " " + round_value(a[1]) + " " + round_value(a[2]) + " " + round_value(a[3]);
}
function remove_column_and_semi_column(text)
{
  // This function need to be done
  return text;
}

