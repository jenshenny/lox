class Token
  attr_reader :type, :lexeme, :literal, :line

  def initialize(type, lexeme, literal, line)
    @type = type
    @lexeme = lexeme
    @literal = literal
    @line = line
  end

  def to_s
    # print null for dart tests
    "#{@type} #{@lexeme} #{@literal || "null"}"
  end
end
