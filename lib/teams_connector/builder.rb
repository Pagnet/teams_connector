# frozen_string_literal: true

module TeamsConnector
  class Builder
    attr_accessor :type, :content

    def initialize
      yield self
    end

    def self.text(text)
      TeamsConnector::Builder.new { |entry| entry.text text }
    end

    def text(text)
      @type = :text
      @content = text
    end

    def self.container(&block)
      TeamsConnector::Builder.new { |entry| entry.container(&block) }
    end

    def container
      @type = :container
      @content = []
      yield @content
    end

    def self.facts(&block)
      TeamsConnector::Builder.new { |entry| entry.facts(&block) }
    end

    def facts
      @type = :facts
      @content = {}
      yield @content
    end

    def self.mentions(params = [])
      TeamsConnector::Builder.new { |entry| entry.mentions(params) }
    end

    def mentions(params)
      @type = :mentions
      @content = params
    end

    def result
      case @type
      when :container then result_container
      when :facts then result_facts
      when :text then result_text
      when :mentions then result_mentions
      else
        raise TypeError, "The type #{@type} is not supported by the TeamsConnector::Builder"
      end
    end

    private

    def result_container
      {
        type: 'Container',
        items: @content.map(&:result)
      }
    end

    def result_facts
      {
        type: 'FactSet',
        facts: @content.map { |fact| { title: fact[0], value: fact[1] } }
      }
    end

    def result_text
      {
        type: 'TextBlock',
        text: @content
      }
    end

    def result_mentions
      {
        msteams: {
          entities: @content.map { |mention| mention_builder(mention) }
        }
      }
    end

    def mention_builder(mention)
      {
        type: 'mention',
        text: "<at>#{mention[:name]}</at>",
        mentioned: {
          id: mention[:email]
        }
      }
    end
  end
end
