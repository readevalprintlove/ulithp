class Lisp
  def initialize(ext = {})
    # 関数適用の際に引数を
    # 評価する   => lambda
    # 評価しない => proc
    # また、Procオブジェクトの引数は、args(Array), contextの２つで統一されている(使わない場合は"_")
    @env = {
      :label => proc   { |(name,val), _| @env[name] = eval(val, @env) },
      :car   => lambda { |(list), _| list[0] },
      :cdr   => lambda { |(list), _| list.drop 1 },
      :cons  => lambda { |(e,cell), _| [e] + cell },
      :eq    => lambda { |(l,r), ctx| eval(l, ctx) == eval(r, ctx) },
      :if    => proc   { |(cond, thn, els), ctx| eval(cond, ctx) ? eval(thn, ctx) : eval(els, ctx) },
      :atom  => lambda { |(sexpr), _| sexpr.is_a?(Symbol) || sexpr.is_a?(Numeric) },
      :quote => proc   { |sexpr, _| sexpr[0] }
    }.merge(ext)
  end

  def apply(fn, args, ctx = @env)
    return ctx[fn].call(args, ctx) if ctx[fn].respond_to?(:call)

    # 独自定義の関数の場合 e.g.
    # ctx[fn] => [:lambda, [:x], [:car, :x]]
    # param_arg => [:x, [1, 2]]
    param_arg = ctx[fn][1].zip(args).flatten(1)
    self.eval(ctx[fn][2], ctx.merge(Hash[*param_arg]))
  end

  def eval(sexpr, ctx = @env)
    if ctx[:atom].call([sexpr], ctx)
      return ctx[sexpr] || sexpr
    end

    fn, *args = sexpr
    if ctx[fn].is_a?(Array) || (ctx[fn].respond_to?(:lambda?) && ctx[fn].lambda?)
      args = args.map { |a| self.eval(a, ctx) }
    end
    apply(fn, args, ctx)
  end
end
