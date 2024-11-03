import gleam/io
import gleam/list
import gleam/result

type Account {
  Account(id: String)
}

type User {
  User(id: String)
}

// arguments it takes, function it expects as next
type Effect(a, err) {
  FetchAccounts(Nil, fn(List(Account)) -> Program(a, err, Effect(a, err)))
  FetchUsers(Nil, fn(List(User)) -> Program(a, err, Effect(a, err)))
  SaveAccount(Account, fn(Nil) -> Program(a, err, Effect(a, err)))
}

type Program(a, err, deps) {
  Call(Effect(a, err))
  Failed(err)
  Done(a)
}

fn try(result: Result(a, err), next) {
  case result {
    Ok(a) -> next(a)
    Error(e) -> Failed(e)
  }
}

fn program_account() -> Program(Account, String, Effect(Account, String)) {
  Call(
    FetchAccounts(Nil, fn(accounts) {
      use first <- try(
        list.first(accounts) |> result.replace_error("First account not found"),
      )

      Done(first)
    }),
  )
}

// fn program_user() -> Program(User, String, Effect(User)) {
//   use users <- Call(FetchUsers(Nil))

//   use first <- try(
//     list.first(users) |> result.replace_error("First user not found"),
//   )

//   Done(first)
// }

fn execute_effect(effect: Effect(a, err)) -> Result(a, err) {
  case effect {
    FetchAccounts(_, next) -> {
      execute_fetch_accounts_real(next) |> execute
    }
    FetchUsers(_, next) -> {
      execute_fetch_users_real(next)
      |> execute
    }
    SaveAccount(_account, next) -> {
      // Save the account
      next(Nil) |> execute
    }
  }
}

fn execute(program: Program(a, err, Effect(a, err))) -> Result(a, err) {
  case program {
    Call(effect) -> execute_effect(effect)
    Done(a) -> Ok(a)
    Failed(e) -> Error(e)
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

  // let user = execute(program_user())
  // io.debug(user)

  io.println("Done")
}
