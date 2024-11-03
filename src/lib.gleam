pub type Program(a, err, deps) {
  Done(a)
  Failed(err)
  Yield(deps)
}

// type Effect(a, err) =
//   fn() -> Program(a, err)

pub fn execute(
  program: Program(a, err, deps),
  execute_dependency: fn(deps) -> Program(a, err, deps),
) -> Result(a, err) {
  case program {
    Done(a) -> Ok(a)
    Failed(e) -> Error(e)
    Yield(effect) -> execute_dependency(effect) |> execute(execute_dependency)
  }
}

// fn(fn(List(Account)) -> Program(a, b, Dependency(a, b))) -> Dependency(a, b)
pub fn yield(effect, rest) {
  Yield(effect(rest))
}
