pub type Program(a, err, deps) {
  Call(deps)
  Failed(err)
  Done(a)
}

// type Effect(a, err) =
//   fn() -> Program(a, err)

pub fn execute(
  program: Program(a, err, deps),
  execute_dependency: fn(deps) -> Program(a, err, deps),
) -> Result(a, err) {
  case program {
    Call(effect) -> execute_dependency(effect) |> execute(execute_dependency)
    Done(a) -> Ok(a)
    Failed(e) -> Error(e)
  }
}
