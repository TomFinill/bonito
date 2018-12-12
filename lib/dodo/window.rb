# frozen_string_literal: true

require 'dodo/happening'
require 'dodo/moment'
require 'securerandom'
require 'timecop'

module Dodo
  class Window < Happening
    attr_reader :happenings

    def initialize(duration, parent = nil, repeat: 1, &block)
      @parent = parent
      @happenings = []
      @total_child_duration = 0
      super duration
      repeat.times { instance_eval(&block) }
    end

    def unused_duration
      duration - @total_child_duration
    end

    def over(duration, repeat: 1, &block)
      self.class.new(duration, self, repeat: repeat, &block).tap do |window|
        self << window
      end
    end

    def please(&block)
      Moment.new(&block).tap { |moment| self << moment }
    end

    def repeat(times: 2, over: duration, &block)
      over(over, repeat: times, &block)
    end

    def simultaneously(over:, &block)
      Container.new.tap do |container|
        container.also(after: 0, over: over, &block)
        self << container
      end
    end

    def enum(starting_offset, opts = {})
      WindowEnumerator.new self, starting_offset, opts
    end

    def crammed(*)
      [self]
    end

    def <<(happening)
      tap do
        @total_child_duration += happening.duration
        if @total_child_duration > duration
          raise WindowDurationExceeded, "#{@total_child_duration} > #{duration}"
        end

        @happenings << happening
      end
    end

    alias use <<
  end

  class DodoException < StandardError
  end

  class WindowDurationExceeded < DodoException
  end

  def self.over(duration, &block)
    Window.new duration, &block
  end

  class WindowEnumerator
    include Enumerable

    def initialize(window, starting_offset, opts = {})
      @window = window
      @starting_offset = starting_offset
      @opts = opts
    end

    def each
      return to_enum(:each) unless block_given?

      happenings_with_offsets do |happening, offset|
        happening.enum(offset, @opts).map do |moment|
          yield moment
        end
      end
    end

    def cram
      @cram ||= @opts.fetch(:scale) {  @opts.fetch(:cram) { 1 } }.ceil
    end

    def stretch
      @stretch ||= @opts.fetch(:scale) { @opts.fetch(:stretch) { 1 } }
    end

    private

    def crammed_happenings
      @crammed_happenings ||= @window.happenings.map do |happening|
        happening.crammed(factor: cram)
      end.flatten
    end

    def offsets
      @offsets ||= crammed_happenings.map do
        SecureRandom.random_number(@window.unused_duration)
      end.sort
    end

    def happenings_with_offsets
      consumed_duration = 0
      crammed_happenings.zip(offsets).each do |happening, offset|
        yield happening, @starting_offset + (stretch * (offset + consumed_duration))
        consumed_duration += happening.duration
      end
    end
  end
end
