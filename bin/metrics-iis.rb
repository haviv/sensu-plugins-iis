#! /usr/bin/env ruby
#


require 'sensu-plugin/metric/cli'
require 'socket'
require 'csv'

#
# IIS Current Connections Metric
#
class IISMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child, ',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.iis"

  option :site,
         short: '-s sitename',
         default: '_Total'




def run
    
  IO.popen("typeperf -sc 1 \"Web Service(#{config[:site]})\\Current\ Connections\"  \"Web Service(#{config[:site]})\\Total Get Requests\" \"Web Service(#{config[:site]})\\Get Requests/sec\" \"Web Service(#{config[:site]})\\Total Get Requests\" \"Web Service(#{config[:site]})\\Total Post Requests\" \"Web Service(#{config[:site]})\\Post Requests/sec\"  ") do |io|
  #puts "typeperf -sc 1 \"Web Service(#{config[:site]})\\Current\ Connections\"  \"Web Service(#{config[:site]})\\Total Get Requests\" \"Web Service(#{config[:site]})\\Get Requests/sec\" \"Web Service(#{config[:site]})\\Total Get Requests\" \"Web Service(#{config[:site]})\\Total Post Requests\" \"Web Service(#{config[:site]})\\Post Requests/sec\"  "
  #IO.popen("cat /Users/haviv.rosh/work/sensu/wmi/type_perf_iis_output.txt") do |io|
    CSV.parse(io.read, headers: true) do |row|
      row.each do |k, v|
          next unless v && k
          break if v.start_with? 'Exiting'

          path = k.split('\\')
          ifz = path[3]
          metric = path[4]
          next unless ifz && metric
          ifz_name = ifz.tr('.', ' ')
          value = format('%.2f', v.to_f)
          name = [config[:scheme], config[:site], ifz_name, metric].join('.').tr(' ', '_').tr('{}', '').tr('[]', '')
          output name, value
      end
    end 
  end
  ok
  end
end
