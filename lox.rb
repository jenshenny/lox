class Lox
  def initialize
    @had_error = false
  end

  def main(args)
    if args.length > 1
      puts "Usage: rlox [script]"
      exit(64)
    elsif args.length == 1
      run_file(args.first)
    else
      run_prompt
    end
  end

  def self.error(line, message)
    self.report(line, "", message)
  end

  # private

  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    tokens.each { |token| puts token }
  end

  def run_file(path)
    run(File.read(path))
    exit(65) if @had_error
  end

  def run_prompt
    while true
      print "> "
      line = gets&.chomp
      break if line.nil? || line.downcase == "exit"
      # puts line
      run(line)
      @had_error = false
    end
  end

  def self.report(line, where, message)
    puts "[line #{line}] Error#{where}: #{message}"
    @had_error = true
  end
end

l = Lox.new
l.run_prompt
