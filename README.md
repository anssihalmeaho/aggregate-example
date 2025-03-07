# aggregate-example
Example of Aggregator pattern usage.

Aggregate is a pattern in Domain-Driven Design (DDD).
It's cluster of domain objects (or data items) that can be treated as a single unit.
Aggregate provides one interface by which it can be operated (so-called Aggregate root).
Aggregate guarantees consistency between items inside its boundary (transactional consistency).

This example may not be thought as Aggregate in most strict sense of DDD pattern as
interface doesn't represent "one thing" conceptually but is logically kind of
"collection" of things.
Anyway it shows how one object can serve as "root" or "gateway" for accessign data inside it
and also guarantees that view to data is always consitent from outside.

## Data storing inside the aggregate
In this example data is stored to several "collections" (all included in one map/consistent variable in memory).
It's also demonstrated how some parts of data can be replicated to several locations in datastructure 
for efficient access to it.
Replicated parts can be safely used as aggregator object handles consistency and transactional access to those.

## Example code
Example is storage for kind of **users** and **chat groups** (or **topics**).
One user can be part of many chat groups and chat group can have many users.

Aggregate interface provides ways to:

* write users and groups
* add users to goups
* read users and groups
* read users of each group
* read groups of each user

## Installing
Fetch repository with `--recursive` option (so that needed submodules are included):

```
git clone --recursive https://github.com/anssihalmeaho/aggregate-example.git
```

## Running example
Run example with [FunL interpreter (funla)](https://github.com/anssihalmeaho/funl).

Run:

```
funla chatgroups.fnl
```

Output is:

```
'
list(
        '
Groups: '
        list(
                'Movie Fans'
                'Old Music'
                'Comics'
        )
        '
Users: '
        list(
                'Bob'
                'Alice'
                'Jim'
        )
        '
Users by Group: '
        map(
                'Movie Fans'
                list(
                        'Bob'
                        'Alice'
                )
                'Old Music'
                list(
                        'Alice'
                        'Jim'
                )
                'Comics'
                list(
                        'Jim'
                        'Bob'
                )
        )
        '
Groups by User: '
        map(
                'Bob'
                list(
                        'Movie Fans'
                        'Comics'
                )
                'Jim'
                list(
                        'Old Music'
                        'Comics'
                )
                'Alice'
                list(
                        'Movie Fans'
                        'Old Music'
                )
        )
)'
```

## Run unit tests for aggregate
You can run tests for aggregate object.

Run test:

```
funla -mod chatstore -name test chatstore.fnl
```

Output is:

```
'PASSED'
```
