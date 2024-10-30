import gleam/io
import gleam/list
import gleam/result

type Account {
  Account(id: String)
}

type Program(a, err) {
  FetchAccounts(Nil, fn(List(Account)) -> Program(a, err))
  SaveAccount(Account, fn(Nil) -> Program(a, err))
  Failed(err)
  Done(a)
}

fn try(result: Result(a, err), next) {
  case result {
    Ok(a) -> next(a)
    Error(e) -> Failed(e)
  }
}

fn program() -> Program(List(Account), String) {
  use accounts <- FetchAccounts(Nil)

  use first <- try(
    list.first(accounts) |> result.replace_error("First account not found"),
  )

  Done(accounts)
}

fn execute(program: Program(a, String)) -> Result(a, String) {
  case program {
    Done(a) -> Ok(a)
    Failed(e) -> Error(e)
    FetchAccounts(_, next) -> {
      let accounts = [Account("1"), Account("2")]
      execute(next(accounts))
    }
    SaveAccount(account, next) -> {
      // Save the account
      execute(next(Nil))
    }
  }
}

pub fn main() {
  let accounts = execute(program())
  io.debug(accounts)
  io.println("Hello from continuations!")
}
