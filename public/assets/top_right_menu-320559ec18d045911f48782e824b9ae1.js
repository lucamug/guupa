// http://javascript-array.com/scripts/jquery_simple_drop_down_menu/#Example
// http://javascript-array.com/scripts/simple_drop_down_menu/
// http://stackoverflow.com/questions/5369393/css-to-align-drop-down-to-the-right
function jsddm_open(){jsddm_canceltimer(),jsddm_close(),ddmenuitem=$(this).find("ul").eq(0).css("visibility","visible")}function jsddm_close(){ddmenuitem&&ddmenuitem.css("visibility","hidden")}function jsddm_timer(){closetimer=window.setTimeout(jsddm_close,timeout)}function jsddm_canceltimer(){closetimer&&(window.clearTimeout(closetimer),closetimer=null)}var timeout=500,closetimer=0,ddmenuitem=0;$(document).ready(function(){$("#jsddm > li").bind("mouseover",jsddm_open),$("#jsddm > li").bind("mouseout",jsddm_timer)}),document.onclick=jsddm_close