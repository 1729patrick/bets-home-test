# Solution

## Architecture

The main focus was to ensure a clear separation of responsibilities, maintain clean code, prioritise quality, readability, and reusability, and make the system more scalable for future growth.

- `BetUpdater`: To optimise and simplify the implementation of new bets in the update method of the repository, I created an abstract class responsible for handling the updates of `Quality` and `Sell-In`. I then created concrete implementations of these protocols for edge cases such as `Total Score`, `Winning Team`, and `Player Performance`. These changes will facilitate the introduction of new types of bets in the future and improve the code's readability, quality, and maintainability.
- `OddsSortingStrategy`: As requested, I implemented an ordering functionality for the list. To achieve this, I applied the Strategy pattern and encapsulated the sorting logic in a separate class. This approach not only facilitated the addition of new sorting algorithms in the future, but also increased code flexibility and maintainability. Any new sorting implementation would only need to implement the `OddsSortingStrategy` protocol, reducing the impact on the existing codebase.
- `OddsViewModel`: I implemented the ViewModel pattern for the OddsViewController to separate the presentation logic from the data layer, as well as to improve testability. By using a ViewModel, I could easily mock the data layer and test the presentation layer independently, without having to rely on actual data. 
- `SceneDelegate`: The SceneDelegate was responsible for composing the `ViewController` by gathering all of its components and injecting them into it.

![architecture](https://user-images.githubusercontent.com/35247414/234326179-fe3ce8fa-88b8-4162-8653-2ef1664c7808.png)


## Unit Tests
- The project has 29 unit tests, mainly designed to ensure that the refactoring did not introduce any bugs or alter the behavior of `BetsCore`. Of these, 23 tests cover `BetsCore`, while the remaining 6 tests cover the View Controller and View Model of the `Bets` app.

## Steps

1. Before I started making any changes to the codebase, I took some time to understand it first. The first step was to look at the code structure and identify any patterns that were present. I tried to understand the purpose of each component and how it fit into the overall codebase. This helped me to avoid making mistakes that could break the existing functionality.
2. After understanding the project, I wrote a suite of unit tests to ensure that `BetsCore` logic remained intact. By doing so, I could verify that my changes didn't introduce any new bugs or regressions, and that the system continued to behave as expected.
3. Then I implemented the following enhancements:
    1. Add the `Quality` and `Sell-In` to the list.
    2. Sort items by `Sell-In`.
    3. Add a button to refresh the list.
4.  After that, I focused my efforts on refactoring the codebase to improve its overall quality. This included optimising the software architecture and implementing design patterns where appropriate, all with the goal of creating a more robust and scalable system.
5. Then, I wrote tests for both the ViewModel and the List View Controller. The ViewModel is relatively small, so the tests cover all of its components, but, there are additional possibilities to cover on the View Controller.
6. And finally, some more refactoring and some more tests.


<details>
  <summary><h3> Assignment Details</h3></summary>
  <p>
  
The application project you have been given is for a legacy application that calculates the real-time status of odds during a sporting event.

During an event, a bet on a particular aspect of the sport has two pieces of information that might change: its odds and its sell-in time. Essentially, these identify how advantageous the odd is and how much longer the odd will be valid for.

The legacy application retrieves the current version of odds from a server, calculates the new state for the odds and then displays them to the user. This is a bug fixing & refactoring task, where the goal is to restructure the project into a more easily maintainable app.

# What to fix
1. Items in list are only showing name, we need to show sell In and quality
as well.
2. Items need to be sorted by sell-in
3. Add a button that calls the updateOdds() function and update the list to
reflect the changes
4. Refactor the code in any way you see fit, to make it more maintainable.

# What we look for
1. Code quality and reusability
2. Software architecture knowledge.
3. Unit Testing (Optional)

# Time & Delivery
1. Kindly limit the development time to not more than 4 hours.
2. Make sure the project builds, even if the solution is not complete.

  </p>
</details>
