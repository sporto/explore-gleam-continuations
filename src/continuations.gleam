import gleam/io
import gleam/list
import gleam/result
import lib.{type Program, continue_if_ok, done, execute, yield}

type Account {
  Account(id: String)
}

type User {
  User(id: String)
}

type AccountProgram =
  Program(Account, String, AccountDependency)

type AccountDependency {
  FetchAccounts(String, fn(Result(List(Account), String)) -> AccountProgram)
  SaveAccount(Account, fn(Nil) -> AccountProgram)
}

fn account_dependency_execute(dependency: AccountDependency) -> AccountProgram {
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
  Program(User, String, UserDependency)

type UserDependency {
  FetchUser(String, fn(Result(User, String)) -> UserProgram)
}

fn user_dependency_execute(dependency: UserDependency) -> UserProgram {
  case dependency {
    FetchUser(user_id, next) -> {
      execute_fetch_user_real(user_id) |> next
    }
  }
}

fn execute_fetch_user_real(user_id: String) -> Result(User, String) {
  Error("User not found")
}

fn user_program() -> Program(User, String, UserDependency) {
  use user_result <- yield(FetchUser("1", _))
  use user <- continue_if_ok(user_result)

  done(user)
}

pub fn main() {
  let account = account_program() |> execute(account_dependency_execute)
  io.debug(account)

  let user = user_program() |> execute(user_dependency_execute)
  io.debug(user)

  io.println("Done")
}
