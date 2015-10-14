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

function xinspect(o,i)
{
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
