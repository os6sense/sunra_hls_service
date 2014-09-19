
require 'rb-inotify'

# Watches a file for changes via ionotify
class FileMonitor
  def self.add_watch(path_and_filename, &block)
    puts "adding watch"
    @notifier = INotify::Notifier.new
    @notifier.watch(path_and_filename.to_s, :modify) do
      puts "notified"
      yield
    end
  end

  def self.run
    @notifier.run
  end

  def self.process
    @notifier.process
  end

  def self.stop
    @notifier.stop
  end
end
