MODULES = {
  'growl' => ['Growl', 'message'],
  'libnotify' => ['Libnotify', 'body'],
}

module Notifier

  def self.load_modules
    MODULES.each do|requirement, values|
      begin
        require requirement
      rescue LoadError
        next
      else
        @mo = Kernel.const_get values[0]
        @field_name = values[1]
        break
      end
    end
  end

  def self.mo
    if @mo.nil?
      load_modules
    end
    @mo
  end

  def self.installed?
    mo rescue false
  end

  def notify message=nil, options={}
    return unless installed?
    options.merge! @field_name => message if message
    begin
      @mo.notify message, options
    rescue
      @mo.show options
    end
  end
  module_function :notify

  def alert message=nil, options={}
    options['body'] = message
    @mo.show options
  end

  def self.new *args, &block
    return unless installed?
    @mo.new *args, &block
  end
end

if __FILE__ == $0
  n = Notifier.new
  act, file = 100, 200
  puts n.show "#{act} #{file}", :title => 'LESS', :summary => 'Fiyah'
end
