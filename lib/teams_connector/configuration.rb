# frozen_string_literal: true

module TeamsConnector
  class Configuration
    DEFAULT_TEMPLATE_DIR = %w[templates teams_connector].freeze

    attr_reader :default, :method, :enabled_environments
    attr_accessor :channels, :always_use_default, :template_dir, :color

    def initialize
      @default = nil
      @channels = {}
      @always_use_default = false
      @method = :direct
      @template_dir = DEFAULT_TEMPLATE_DIR
      @color = '3f95b5'
      @enabled_environments = []
    end

    def default=(channel)
      raise ArgumentError, "Desired default channel '#{channel}' is not configured" unless @channels.key?(channel)

      @default = channel
    end

    def method=(method)
      raise ArgumentError, "Method '#{method}' is not supported" unless %i[direct sidekiq testing].include? method
      raise ArgumentError, 'Sidekiq is not available' if method == :sidekiq && !defined? Sidekiq

      @method = method
    end

    def channel(name, url)
      @channels[name] = url
    end

    def enabled_environments=(enabled_environments)
      @enabled_environments = enabled_environments
    end

    def load_from_rails_credentials
      raise 'This method is only available in Ruby on Rails.' unless defined? Rails

      webhook_urls = Rails.application.credentials.teams_connector!
      webhook_urls.each do |entry|
        channel(entry[0], entry[1])
      end
    end

    def enabled_in_current_env?
      enabled_environments.empty? || enabled_environments.include?(environment)
    end

    def environment
      ENV['RAILS_ENV'] || 'development'
    end
  end
end
