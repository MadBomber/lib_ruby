require 'active_support/cache'
require 'forwardable'

class Cache
  extend Forwardable
  @@cache = nil

  def_delegator :@@cache, :cleanup ,     :'self.cleanup'
  def_delegator :@@cache, :clear ,       :'self.clear'
  def_delegator :@@cache, :decrement,    :'self.decrement'
  def_delegator :@@cache, :delete,       :'self.delete'
  def_delegator :@@cache, :delete_matched , :'self.delete_matched'
  def_delegator :@@cache, :exist? ,      :'self.exist?'
  def_delegator :@@cache, :fetch,        :'self.fetch'
  def_delegator :@@cache, :fetch_multi , :'self.fetch_multi'
  def_delegator :@@cache, :increment,    :'self.increment'
  def_delegator :@@cache, :instrument,   :'self.instrument'
  def_delegator :@@cache, :instrument= , :'self.instrument='
  def_delegator :@@cache, :key_matcher , :'self.key_matcher'
  def_delegator :@@cache, :mute ,        :'self.mute'
  def_delegator :@@cache, :read,        :'self.read'
  def_delegator :@@cache, :read_multi , :'self.read_multi'
  def_delegator :@@cache, :silence! ,   :'self.silence!'
  def_delegator :@@cache, :write ,      :'self.write'

  class << self
    def setup(store='MemoryStore', options={})
      @@cache = "ActiveSupport::Cache::#{store}".constantize.new(options)
    end
    alias :new :setup
    alias :init :setup
    alias :initialize :setup

    def cache
      @@cache
    end
  end
end # class Cache

