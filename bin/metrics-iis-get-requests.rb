#! /usr/bin/env ruby
#
# metrics-iis-get-requests.rb
#
# DESCRIPTION:
#
# OUTPUT:
#  metric data
#
# PLATFORMS:
#   iis
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# NOTES:
#  Tested on iis 2012RC2.
#
# LICENSE:
#   Yohei Kawahara <inokara@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'

#
# IIS Get Requests
#
class IisGetRequests < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.iis_get_requests"

  option :site,
         short: '-s sitename',
         default: '_Total'

  def run
    io = IO.popen("typeperf -sc 1 \"Web Service(#{config[:site]})\\Get\ Requests\/sec\"")
    get_requests = io.readlines[2].split(',')[1].delete('"').to_f

    output [config[:scheme], config[:site]].join('.'), get_requests
    ok
  end
end
