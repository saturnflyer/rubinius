require 'mspec/capture'

class OutputMatcher
  def initialize(stdout, stderr)
    @out = stdout
    @err = stderr
  end
  
  def matches?(proc)
    @saved_out = $stdout
    @saved_err = $stderr
    @stdout = $stdout = CaptureOutput.new
    @stderr = $stderr = CaptureOutput.new
    
    proc.call
    
    unless @out.nil?
      case @out
      when String
        return false unless $stdout == @out
      when Regexp
        return false unless $stdout =~ @out
      end
    end
    
    unless @err.nil?
      case @err
      when String
        return false unless $stderr == @err
      when Regexp
        return false unless $stderr =~ @err
      end
    end

    return true
  ensure
    $stdout = @saved_out
    $stderr = @saved_err
  end
  
  def failure_message
    expected_out = "\n"
    actual_out = "\n"
    unless @out.nil?
      expected_out << "  $stdout: #{@out.dump}\n"
      actual_out << "  $stdout: #{@stdout.chomp.dump}\n"
    end
    unless @err.nil?
      expected_out << "  $stderr: #{@err.dump}\n"
      actual_out << "  $stderr: #{@stderr.chomp.dump}\n"
    end
    ["Expected:#{expected_out}", "     got:#{actual_out}"]
  end
  
  def negative_failure_message
    out = ""
    out << "  $stdout: #{@stdout.chomp.dump}\n" unless @out.nil?
    out << "  $stderr: #{@stderr.chomp.dump}\n" unless @err.nil?
    ["Expected output not to be:\n", out]
  end
end

class Object
  def output(stdout=nil, stderr=nil)
    OutputMatcher.new(stdout, stderr)
  end
end
