class Logger
  def addv(*msgs)
    unless @logdev.nil?
      @logdev.writev(*msgs)
    end
  end
  
  def blank_slate
    @logdev.blank_slate
  end
  
  class LogDevice
    def writev(*messages)
      @mutex.synchronize do
        if @shift_age and @dev.respond_to?(:stat)
          begin
            check_shift_log
          rescue
            raise Logger::ShiftingError.new("Shifting failed. #{$!}")
          end
        end
        @dev.writev(*messages)
      end
    end  
    
    def blank_slate
      @dev.truncate(0)
    end    
  end
end