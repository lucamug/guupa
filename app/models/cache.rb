class Cache
  def self.all
    return @cache
  end
  def self.reset_all
    @cache = nil
    return @cache
  end
  def self.get(name)
    @cache       ||= {}
    cache = @cache[name] ||= {}
    cache[:initialized_on] ||= Time.now
    cache[:initialized_by] ||= caller[0]
    cache[:memory_object]  ||= {}
    cache[:last_access_on]   = Time.now
    cache[:last_access_by]   = caller[0]
    return cache[:memory_object]
  end
  def self.reset(name)
    cache = self.my_cache_initialize(name)
    cache[:memory_object]  = {}
    cache[:reset_on]  = Time.now
    cache[:reset_by]  = caller[0]
    return cache[:memory_object]
  end
end

