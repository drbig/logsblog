#!/usr/bin/env ruby
#

%w{ rubygems color }.each { |g| require g }

luma = ARGV.shift.to_f || 0.8
satu = ARGV.shift.to_f || 0.7

STDIN.each_line do |line|
  if color = line.match(/(\#[0-9a-f]+)/i)
    html_color = color.captures.first
    rgb = Color::RGB.from_html(html_color)
    STDERR.puts "#{color} -> #{rgb.brightness}"
    rgb = rgb.adjust_brightness(luma)
    rgb = rgb.adjust_saturation(satu)
    puts line.gsub(html_color, rgb.html)
  else
    puts line
  end
end
