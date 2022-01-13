class Scanner
  KEYWORDS = {
    and: :AND,
    class: :CLASS,
    else: :ELSE,
    false: :FALSE,
    for: :FOR,
    fun: :FUN,
    if: :IF,
    nil: :NIL,
    or: :OR,
    print: :PRINT,
    return: :RETURN,
    super: :SUPER,
    this: :THIS.
    true: :TRUE,
    var: :VAR,
    while: :WHILE
  }

  def initialize(source)
    @source = source
    @tokens = []
    @start = 0
    @current = 0
    @line = 1
  end

  def scan_tokens
    while !at_end?
      @start = @current
      scan_token
    end

    tokens << Token.new(:EOF, "", nil, @line)
  end

  private

  def at_end?
    @current >= @source.length
  end

  def advance
    @current += 1
    @source[@current]
  end

  def add_token(type)
    add_token(type, nil)
  end

  def add_token(type, literal)
    text = @source[@start..@current]
    @tokens << Token.new(type, text, literal, @line)
  end

  def match(expected)
    return false if at_end?
    return false if @source[@current] != expected
    @current += 1
    true
  end

  def peek
    return '\0' if at_end?
    @source[@current]
  end

  def peek_next
    return '\0' if @current + 1 >= @source.length
    @source[@current + 1]
  end

  def string
    while (peek != '"' && !at_end?)
      @line += if peek == "\n"
      advance
    end

    if at_end?
      Lox.error(@line, "Unterminated string")
      return
    end

    advance

    value = source[(@start + 1)..(@current - 1)]
    add_token(:STRING, value)
  end

  def digit?(c)
    c =~ /[0-9]/
  end

  def number
    advance while digit?(peek)

    if peek == '.' && digit?(peek_next)
      advance
      advance while digit?(peek)
    end
    
    add_token(:NUMBER, @source[@start..@current].to_f)
  end

  def indentifier
    advance while alphanumeric?(peek)

    text = @source[@start..@current]
    type = KEYWORDS[text.to_sym] || :IDENTIFIER
    add_token(type)
  end

  def alpha?(c)
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
  end

  def alphanumeric?(c)
    alpha?(c) || digit?(c)
  end

  def scan_token
    c = advance
    case c
    when '('
      add_token(:LEFT_PAREN)
    when ')'
      add_token(:RIGHT_PAREN)
    when '{'
      add_token(:LEFT_BRACE)
    when '}'
      add_token(:RIGHT_BRACE)
    when ','
      add_token(:COMMA)
    when '.'
      add_token(:DOT)
    when '-'
      add_token(:MINUS)
    when '+'
      add_token(:PLUS)
    when ';'
      add_token(:SEMICOLON)
    when '*'
      add_token(:STAR)
    when '!'
      add_token(match('=') ? :BANG_EQUAL : :BANG)
    when '='
      add_token(match('=') ? :EQUAL_EQUAL : :BANG)
    when '<'
      add_token(match('=') ? :LESS_EQUAL : :BANG)
    when '>'
      add_token(match('=') ? :GREATER_EQUAL : :BANG)
    when '/'
      if match('/')
        advance while (peek != '\n' && !at_end?)
      else
        add_token(:SLASH)
      end
    when ' '
    when '\r'
    when '\t'
    when '\n'
      @line += 1
    when '"'
      string
    else
      if digit?(c)
        number
      elsif alpha?
        indentifier
      else
        Lox.error(@line, "Unexpected character")
      end
    end 
  end
end
