# Practice 9 Notes

## Level 1 — Lift it up

The cart state was stored in `Shell`, above `MaterialApp`.

Data was passed down through constructors and actions were passed up through callbacks.

When the total price was added to the badge, I had to update the constructors and parameters between the owner and the badge.

Files touched:
- `main.dart`
- `books_screen.dart`
- `cart_badge.dart`

One Add tap rebuilt `BooksScreen` and all book rows because `setState` was called in `Shell`.

## Level 3 — Provider errors

### watch inside a callback

Using:

`context.watch<Cart>().add(book)`

inside `onPressed` is wrong because `watch` is for subscribing during build.

The correct version is:

`context.read<Cart>().add(book)`

### read inside build

Using:

`context.read<Cart>().count`

inside `build` does not subscribe to changes.

The app still runs, but the badge does not update.

The correct version is:

`context.watch<Cart>().count`

or, for a smaller subscription:

`context.select<Cart, int>((cart) => cart.count)`

## Level 4 — Rebuilds

With `watch`, the badge rebuilt after every `notifyListeners()`, including quantity changes.

With `select`, the badge depends only on `count`.

Changing quantity does not change `count`, so the badge does not rebuild.

Removing a book changes `count`, so the badge rebuilds once.

## Where does it live?

### Cart

Provided state.

The cart is used by multiple routes and screens, so it is stored in a `ChangeNotifier` and provided above `MaterialApp`.

### Search text

Ephemeral state.

Search text belongs only to the search field or Books screen and does not need to be shared across the whole app.

### Whether the total section is expanded

Ephemeral state.

This is local UI state for the Cart screen only.

### Theme mode

Lifted or provided state.

Theme mode affects the whole application, so it should live high in the widget tree.