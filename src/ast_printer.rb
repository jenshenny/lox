require_relative "expr"
require_relative "token"

class AstPrinter < Expr::Visitor
  def print(expr)
    expr.accept(self)
  end

  def visit_binary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.left, expr.right)
  end

  def visit_grouping_expr(expr)
    parenthesize("group", expr.expression)
  end

  def visit_literal_expr(expr)
    expr.value&.to_s
  end

  def visit_unary_expr(expr)
    parenthesize(expr.operator.lexeme, expr.right)
  end

  def parenthesize(name, *exprs)
    s = "(#{name}"
    exprs.each do |expr|
      s += " #{expr.accept(self)}"
    end
    s += ")"
  end
end

# printer = AstPrinter.new
# expression = Expr::Binary.new(
#   Expr::Unary.new(Token.new(:MINUS, "-", nil, 1), Expr::Literal.new(123)),
#   Token.new(:STAR, "*", nil, 1),
#   Expr::Grouping.new(Expr::Literal.new(45.67)))

# puts printer.print(expression)