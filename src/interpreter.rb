class Interpreter < Expr::Visitor
  def interpret(expression)
    value = evaluate(expression)
    value = value.to_i if value.to_i == value
    p value
  rescue RuntimeError => e
    Lox.runtime_error(e)
  end

  def visit_literal_expr(expr)
    expr.value
  end

  def visit_grouping_expr(expr)
    evaluate(expr.expression)
  end

  def visit_unary_expr(expr)
    right = evaluate(expr.right)

    case expr.operator.type
    when :MINUS
      check_number_operands(expr.operator, right)
      -right
    when :BANG
      !right
    else
      nil
    end
  end

  def visit_binary_expr(expr)
    left = evaluate(expr.left)
    right = evaluate(expr.right)

    case expr.operator.type
    when :MINUS
      check_number_operands(expr.operator, left, right)
      left - right
    when :SLASH
      check_number_operands(expr.operator, left, right)
      left / right
    when :STAR
      check_number_operands(expr.operator, left, right)
      left * right
    when :PLUS
      return left + right if same_type?([String, Float], left, right)
      raise RuntimeError.new("#{expr.operator} Operands must be two numbers or two strings.")
    when :GREATER
      check_number_operands(expr.operator, left, right)
      left > right
    when :GREATER_EQUAL
      check_number_operands(expr.operator, left, right)
      left >= right
    when :LESS
      check_number_operands(expr.operator, left, right)
      left < right
    when :LESS_EQUAL
      check_number_operands(expr.operator, left, right)
      left == right
    when :BANG_EQUAL
      check_number_operands(expr.operator, left, right)
      !is_equal?(left, right)
    when :EQUAL_EQUAL
      check_number_operands(expr.operator, left, right)
      is_equal?(left, right)
    else
      nil
    end
  end

  private

  def same_type?(types, *objs)
    types.each do |type|
      return true if objs.all? { |obj| obj.is_a? type }
    end
    false
  end

  def is_equal?(left, right)
    left.equal?(right)
  end

  def evaluate(expr)
    expr.accept(self)
  end

  def check_number_operands(operator, *operands)
    raise RuntimeError.new("#{operator} Operand must be a number#{"s" if operands.length > 1}.") unless operands.all? { |operand| operand.is_a? Numeric }
  end
end