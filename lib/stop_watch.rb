class StopWatch
  def take_time(note = "")
    @times ||= []
    @times.push [Time.now.to_f, note]
  end
  def analize
    start_time = @times[0][0]
    end_time = @times[-1][0]
    total_time = end_time - start_time
    previous_time = start_time
    html = "<table>"
    @times.each do |time|
      partial_time = time[0] - previous_time
      percentage = (100 * partial_time) / total_time
      html += "<tr><td>#{"%07d" % (partial_time * 1000000).to_i}</td><td>#{"%03d%" % percentage}</td><td><img src='/assets/0/background.png' height='20px' width='#{(percentage * 3).to_i}px'</td><td>#{time[1]}</td></tr>"
      previous_time = time[0]
    end
    html += "\n<tr><td>#{"%07d" % (total_time * 1000000).to_i}</td><td>#{"%03d%" % 100}</td></tr>"
    html += "</table>"
  end      
end

# Usage

# t = StopWatch.new
# t.take_time("My new stopwatch")
# sleep 0.3
# t.take_time("Slept 0.3")
# sleep 0.1
# t.take_time("Slept 0.1")
# sleep 0.2
# t.take_time("Slept 0.2")
# t.take_time("Stop")
# t.analize

