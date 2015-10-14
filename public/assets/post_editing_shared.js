function parse_google_result(a,b,c,d){var e=[],f=undefined,g=undefined;e.push("lat:"+round_value(c.lat())),e.push("lng:"+round_value(c.lng())),d!=undefined&&(e.push("b:"+viewport_or_bound_to_string(d.getBounds())),e.push("z:"+d.getZoom()));if(b==google.maps.GeocoderStatus.OK){var h=parse_results(a);h["normal_country"]!=undefined?e.push("c:"+remove_column_and_semi_column(h.normal_country.name)+"("+h.normal_country.bounds+")"):h["simple_country"]!=undefined&&e.push("c:"+remove_column_and_semi_column(h.simple_country.name)),h[3]!=undefined&&e.push("3:"+h[3].name+"("+h[3].bounds+")"),h[4]!=undefined&&e.push("4:"+h[4].name+"("+h[4].bounds+")"),h[5]!=undefined&&e.push("5:"+h[5].name+"("+h[5].bounds+")"),h["postal_code"]!=undefined&&e.push("p:"+h.postal_code.name+"("+h.postal_code.bounds+")"),h["address"]!=undefined&&e.push("a:"+remove_column_and_semi_column(h.address.name)),e.push("v: 1.0"),f=h.address.name}else g=b;return{output:e,address:f,error:g}}function parse_results(a){var b=[];b.skipped=[];var c=/locality|administrative/;simple_country_found=!1,level=3;for(var d=a.length-1;d>=0;d--)for(var e in a[d].types)if(a[d]["types"][e]!="political"){if(!simple_country_found){var f=search_country(a[d].address_components);f&&(b.simple_country=[],b.simple_country.name=f,simple_country_found=!0)}a[d]["types"][e]=="postal_code"?(b.postal_code=[],b.postal_code.name=a[d].address_components[0].long_name,b.postal_code.bounds=return_bounds(a[d].geometry)):a[d]["types"][e]=="country"?(b.normal_country=[],b.normal_country.name=a[d].address_components[0].long_name,b.normal_country.bounds=return_bounds(a[d].geometry)):level<6&&a[d].types[e].match(c)?(b[level]=[],b[level].name=a[d].address_components[0].long_name,b[level].bounds=return_bounds(a[d].geometry),b[level].type=a[d].types[e],level++):d!=0&&b.skipped.push("Type: "+a[d].types[e]+" ("+a[d].formatted_address+")"),d==0&&(b.address=new Array,b.address.name=a[d].formatted_address,b.address.bounds=return_bounds(a[d].geometry),b.address.type=a[d].types[e])}return b}function round_value(a){return Math.round(a*decimals)}function search_country(a){for(var b=a.length-1;b>=0;b--)for(var c in a[b].types)if(a[b]["types"][c]!="political"&&a[b]["types"][c]=="country")return a[b].long_name;return!1}function return_bounds(a){return typeof a["viewport"]!=undefined?viewport_or_bound_to_string(a.viewport):typeof a["bounds"]!=undefined?viewport_or_bound_to_string(a.bounds):undefined}function viewport_or_bound_to_string(b){return a=b.toUrlValue().split(","),round_value(a[0])+" "+round_value(a[1])+" "+round_value(a[2])+" "+round_value(a[3])}function remove_column_and_semi_column(a){return a}