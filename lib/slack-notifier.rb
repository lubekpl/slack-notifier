require 'net/http'
require 'uri'
require 'json'

require File.expand_path('../slack-notifier/default_http_client', __FILE__)
require File.expand_path('../slack-notifier/link_formatter', __FILE__)

module Slack
  class Notifier
    attr_reader :endpoint, :default_payload

    def initialize webhook_url, options={}
      @endpoint        = URI.parse webhook_url
      @default_payload = options
    end

    def ping message, options={}
      message      = LinkFormatter.format(message)
      payload      = default_payload.merge(options).merge(:text => message)
      client       = payload.delete(:http_client) || http_client
      http_options = payload.delete(:http_options)

      params = { :payload => payload.to_json }
      params[:http_options] = http_options if http_options

      client.post endpoint, params
    end

    def http_client
      default_payload.fetch :http_client, DefaultHTTPClient
    end

    def channel
      default_payload[:channel]
    end

    def channel= channel
      default_payload[:channel] = channel
    end

    def username
      default_payload[:username]
    end

    def username= username
      default_payload[:username] = username
    end

    HTML_ESCAPE_REGEXP = /[&><]/
    HTML_ESCAPE = { '&' => '&amp;',  '>' => '&gt;',   '<' => '&lt;' }

    def escape(text)
      text.gsub(HTML_ESCAPE_REGEXP, HTML_ESCAPE)
    end
  end
end
