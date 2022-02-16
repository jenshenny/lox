require_relative 'scanner'
require_relative 'parser'
require_relative 'ast_printer'
require_relative 'interpreter'

class Lox
  def initialize
    @had_error = false
    @runtime_error = false
  end

  def self.main(args)
    lox = Lox.new
    if args.length > 1
      puts "Usage: rlox [script]"
      exit(64)
    elsif args.length == 1
      lox.run_file(args.first)
    else
      lox.run_prompt
    end
  end

  def self.error(line, message)
    self.report(line, "", message)
  end

  def run_file(path)
    run(File.read(path))
    exit(65) if @had_error
    exit(70) if @runtime_error
  end

  def run_prompt
    while true
      print "> "
      line = gets&.chomp
      break if line.nil? || line.downcase == "exit"
      run(line)
      @had_error = false
    end
  end

  def self.runtime_error(error)
    puts error.message
    runtime_error = true
  end

  private

  def run(source)
    scanner = Scanner.new(source)
    tokens = scanner.scan_tokens

    # tokens.each { |token| puts token }

    parser = Parser.new(tokens)
    expression = parser.parse

    return if @had_error

    # puts AstPrinter.new.print(expression)

    Interpreter.new.interpret(expression)
  end

  def self.report(line, where, message)
    puts "[line #{line}] Error#{where}: #{message}"
    @had_error = true
  end

  def self.error(token, message)
    if token.type == :EOF
      report(token.line, " at end", message)
    else
      report(token.line, " at '" + token.lexeme + "'", message)
    end
  end
end
