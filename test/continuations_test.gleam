import continuations.{type Program, continue_if_ok, done, execute, yield}
import gleam/io
import gleam/list
import gleam/result
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub type Account {
  Account(id: String)
}

pub type User {
  User(id: String)
}

type AccountProgram =
  Program(Account, String, AccountDependencies)

type AccountDependencies {
  FetchAccounts(String, fn(Result(List(Account), String)) -> AccountProgram)
  SaveAccount(Account, fn(Nil) -> AccountProgram)
}

fn execute_account_dependency(dependency: AccountDependencies) -> AccountProgram {
  case dependency {
    FetchAccounts(client_id, next) -> {
      execute_fetch_accounts_real(client_id) |> next
    }
    SaveAccount(_account, next) -> {
      Nil |> next
    }
  }
}

fn execute_fetch_accounts_real(client_id) {
  Ok([Account("r1"), Account("r2")])
}

fn account_program() -> AccountProgram {
  let fetch = FetchAccounts("1", _)
  use accounts_result <- yield(fetch)

  use accounts <- continue_if_ok(accounts_result)

  use first <- continue_if_ok(
    list.first(accounts) |> result.replace_error("First account not found"),
  )

  done(first)
}

type UserProgram =
  Program(User, String, UserDependencies)

type UserDependencies {
  FetchUser(String, fn(Result(User, String)) -> UserProgram)
}

fn execute_user_dependency(dependency: UserDependencies) -> UserProgram {
  case dependency {
    FetchUser(user_id, next) -> {
      execute_fetch_user_real(user_id) |> next
    }
  }
}

fn execute_fetch_user_real(user_id: String) -> Result(User, String) {
  Error("User not found")
}

fn user_program() -> UserProgram {
  use user_result <- yield(FetchUser("1", _))
  use user <- continue_if_ok(user_result)

  done(user)
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let account = account_program() |> execute(execute_account_dependency)
  io.debug(account)

  let user = user_program() |> execute(execute_user_dependency)
  io.debug(user)
}
