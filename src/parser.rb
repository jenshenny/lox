require_relative "expr"
require "byebug"

class Parser
  class ParseError < RuntimeError; end

  def initialize(tokens)
    @tokens = tokens
    @current = 0
  end

  def parse
    expression
  rescue ParseError
    nil
  end

  private

  def expression
    equality
  end

  def equality
    expr = comparison

    while match(:BANG_EQUAL, :EQUAL_EQUAL)
      operator = previous
      right = comparison
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def comparison
    expr = term

    while match(:GREATER, :GREATER_EQUAL, :LESS, :LESS_EQUAL)
      operator = previous
      right = term
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def term
    expr = factor

    while match(:MINUS, :PLUS)
      operator = previous
      right = factor
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def factor
    expr = unary

    while match(:SLASH, :STAR)
      operator = previous
      right = unary
      expr = Expr::Binary.new(expr, operator, right)
    end

    expr
  end

  def unary
    if match(:BANG, :MINUS)
      operator = previous
      right = unary
      return Expr::Unary.new(operator, right)
    end

    primary
  end

  def primary
    return Expr::Literal.new(false) if match(:FALSE)
    return Expr::Literal.new(true) if match(:TRUE)
    return Expr::Literal.new(nil) if match(:NIL)

    if match(:NUMBER, :STRING)
      return Expr::Literal.new(previous.literal)
    end

    if match(:LEFT_PAREN)
      expr = expression
      consume(:RIGHT_PAREN, "Expect ')' after expression.");
      return Expr::Grouping.new(expr);
    end

    raise error(peek, "Expect expression")
  end

  def match(*types)
    types.each do |type|
      if check(type)
        advance
        return true
      end
    end

    false
  end

  def consume(type, message)
    return advance if check(type)

    raise error(peek, message)
  end

  def check(type)
    return false if end?
    peek.type == type
  end

  def advance
    @current += 1 unless end?
    previous
  end

  def end?
    peek.type == :EOF
  end

  def peek
    @tokens[@current]
  end

  def previous
    @tokens[@current - 1]
  end

  def error(token, message)
    Lox.error(token, message)
    return ParseError.new
  end

  def synchonize
    advance

    while !end?
      return if previous.type == :SEMICOLON

      case peek.type
      when :CLASS
      when :FUN
      when :VAR
      when :FOR
      when :IF
      when :WHILE
      when :PRINT
      when :RETURN
        return
      end
    end
  end
end
