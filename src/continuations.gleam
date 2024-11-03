import gleam/io
import gleam/list
import gleam/result
import lib.{type Program, Done, Failed, execute, yield}

type Account {
  Account(id: String)
}

type User {
  User(id: String)
}

// arguments it takes, function it expects as next
type DependencyAccount {
  FetchAccounts(
    String,
    fn(List(Account)) -> Program(Account, String, DependencyAccount),
  )
  SaveAccount(Account, fn(Nil) -> Program(Account, String, DependencyAccount))
}

// type Dependency(a, err) {
//   FetchAccounts(
//     String,
//     fn(List(Account)) -> Program(a, err, Dependency(a, err)),
//   )
//   FetchUsers(Nil, fn(List(User)) -> Program(a, err, Dependency(a, err)))
//   SaveAccount(Account, fn(Nil) -> Program(a, err, Dependency(a, err)))
// }

fn try(result: Result(a, err), next) {
  case result {
    Ok(a) -> next(a)
    Error(e) -> Failed(e)
  }
}

fn program_account() -> Program(Account, String, DependencyAccount) {
  let fetch = FetchAccounts("1", _)
  use accounts <- yield(fetch)

  use first <- try(
    list.first(accounts) |> result.replace_error("First account not found"),
  )

  Done(first)
}

// fn program_user() -> Program(User, String, Dependency(User)) {
//   use users <- Yield(FetchUsers(Nil))

//   use first <- try(
//     list.first(users) |> result.replace_error("First user not found"),
//   )

//   Done(first)
// }

fn execute_effect(
  effect: DependencyAccount,
) -> Program(Account, String, DependencyAccount) {
  case effect {
    FetchAccounts(client_id, next) -> {
      execute_fetch_accounts_real(client_id) |> next
    }
    SaveAccount(_account, next) -> {
      Nil |> next
    }
  }
}

fn execute_fetch_accounts_real(client_id) {
  [Account("r1"), Account("r2")]
}

fn execute_fetch_users_real() {
  [User("r1"), User("r2")]
}

pub fn main() {
  let account = program_account() |> execute(execute_effect)
  io.debug(account)

  // let user = execute(program_user())
  // io.debug(user)

  io.println("Done")
}
