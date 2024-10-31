import gleam/io
import gleam/list
import gleam/result

type Account {
  Account(id: String)
}

type User {
  User(id: String)
}

type Program(a, err) {
  FetchAccounts(Nil, fn(List(Account)) -> Program(a, err))
  FetchUsers(Nil, fn(List(User)) -> Program(a, err))
  SaveAccount(Account, fn(Nil) -> Program(a, err))
  Failed(err)
  Done(a)
}

// type ApiInstructions(a) {
//   FetchAccounts(Nil, fn(List(Account)) -> a)
//   FetchUsers(Nil, fn(List(User)) -> a)
// }

fn try(result: Result(a, err), next) {
  case result {
    Ok(a) -> next(a)
    Error(e) -> Failed(e)
  }
}

fn program_account() -> Program(Account, String) {
  use accounts <- FetchAccounts(Nil)

  use first <- try(
    list.first(accounts) |> result.replace_error("First account not found"),
  )

  Done(first)
}

fn program_user() -> Program(User, String) {
  use users <- FetchUsers(Nil)

  use first <- try(
    list.first(users) |> result.replace_error("First user not found"),
  )

  Done(first)
}

fn execute(program: Program(a, String)) -> Result(a, String) {
  case program {
    Done(a) -> Ok(a)
    Failed(e) -> Error(e)
    FetchAccounts(_, next) -> {
      execute_fetch_accounts_real(next) |> execute
    }
    FetchUsers(_, next) -> {
      execute_fetch_users_real(next)
      |> execute
    }
    SaveAccount(account, next) -> {
      // Save the account
      execute(next(Nil))
    }
  }
}

fn execute_fetch_accounts_real(next) {
  next([Account("r1"), Account("r2")])
}

fn execute_fetch_users_real(next) {
  next([User("r1"), User("r2")])
}

pub fn main() {
  let account = program_account() |> execute
  io.debug(account)

  let user = execute(program_user())
  io.debug(user)

  io.println("Done")
}
