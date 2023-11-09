#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

def add_rule(rules, host)
    rx_host = host.sub('.', '\.')
    filter = "^[^:]+:\/\/+([^:\/]+\\.)?#{rx_host}[:\/]"

    rule = {
        "action" => {
            "type" => "block"
        },
        "trigger" => {
            "url-filter" => filter,
            "url-filter-is-case-sensitive" => true,
            "load-type" => ["third-party"]
        }
    }

    rules << rule
end

rules = []
#host = "foobar.com"
uri = URI.parse("http://pgl.yoyo.org/adservers/serverlist.php?hostformat=nohtml")
response = Net::HTTP.get_response(uri)

response.body.each_line do |host|
    add_rule(rules, host.chomp)
end

puts rules.to_json
