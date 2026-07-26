#import "/common/reading-note.typ": pseudocode-list
#import "@preview/ilm:2.1.1": blockquote

= Introduction to Algorithm Design

Algorithm design begins before implementation. First define the problem
precisely, then propose a method, challenge it with counterexamples, and
finally justify why it is correct. A method that often works is not
necessarily an algorithm that always works.

== Algorithms, Heuristics, and Correctness

=== Core Definitions

#let core-definitions-table = table(
  align: left,
  columns: (1.15fr, 3.2fr),
  [*Term*], [*Meaning*],
  [Problem], [A general computational task defined by its allowed inputs and required outputs.],
  [Instance], [One concrete input belonging to the problem's allowed input set.],
  [Algorithm], [A finite procedure that produces a correct result for every valid input instance.],
  [Heuristic], [A practical method that may produce good answers but provides no universal correctness guarantee.],
  [Proof of correctness],
  [A precise argument showing that every valid input is mapped to an output satisfying the specification.],

  [Counterexample], [A valid input on which a claimed algorithm produces an incorrect or suboptimal result.],
)

#figure(caption: [Core Definitions], core-definitions-table)

=== Robot Tour Optimization

*Problem specification*

- *Input:* a set $S$ of $n$ points in the plane.
- *Output:* a shortest closed tour that visits every point in $S$.

This is an *instance* of the traveling salesperson problem. Two natural methods
illustrate the danger of intuitive reasoning:

#let three-methods-of-robot-tour-table = table(
  align: left,
  columns: 3,
  [*Method*], [*Status*], [*Why*],
  [Nearest neighbor],
  [Heuristic],
  [A locally short move can force expensive moves later. The starting point and tie-breaking rule can also change the result.],

  [Closest pair], [Heuristic], [Repeatedly joining nearby endpoints can create a globally poor tour.],
  [Enumerate all tours],
  [Correct algorithm],
  [It checks every permutation and returns the least expensive tour, but requires factorial work.],
)

#figure(caption: "Three methods", three-methods-of-robot-tour-table)

The exhaustive method considers $n!$ orderings. Its correctness comes from
complete coverage of the solution space, not from efficiency.

=== Movie Scheduling

*Problem specification*

- *Input:* a set $I$ of intervals on a line.
- *Output:* a largest subset of mutually non-overlapping intervals.

The objective is to maximize the *number* of accepted jobs, assuming all jobs
have equal value.

#let strategies-table = table(
  align: (left, center, left),
  columns: 3,
  [*Strategy*], [*Correct?*], [*Reason*],
  [Earliest starting job], [No], [One early, long interval can block many later intervals.],
  [Shortest job], [No], [One short interval can overlap two compatible intervals, reducing the final count.],
  [Enumerate all subsets], [Yes], [Every one of the $2^n$ subsets is checked, but the method is exponential.],
  [Earliest finishing job], [Yes], [It leaves at least as much remaining time as any other possible first choice.],
)

#figure(caption: "Three strategies for movie scheduling", strategies-table)

The greedy algorithm is:

#pseudocode-list[
  + *procedure* OptimalScheduling($I$)
    + $S <- emptyset$
    + *while* $I$ is not empty *do*
      + choose the interval $j$ with the earliest finishing time
      + add $j$ to $S$
      + remove $j$ and every interval that overlaps $j$ from $I$
    + *end while*
    + *return* $S$
  + *end procedure*
]

==== Why Earliest Finish Is Safe

Let $x$ be the interval with the earliest finishing time. Consider an optimal
schedule whose first selected interval is $y$.

Because $x$ finishes no later than $y$, replacing $y$ with $x$ cannot invalidate
any interval scheduled after $y$. The replacement preserves the number of
selected intervals. Therefore, at least one optimal solution contains $x$.
After selecting $x$, the same reasoning applies to the remaining compatible
intervals.

This is an *exchange argument*: transform an arbitrary optimal solution so
that it agrees with the greedy choice without making it worse.

== Specifying and Expressing a Problem

=== Input Domain and Output Property

A usable problem specification answers two questions:

1. Which inputs are valid?
2. Which properties must the output satisfy?

Changing either part can change the problem completely. For example, earliest
finish solves ordinary interval scheduling, but it does not automatically solve
a generalized version in which one job occupies several separated intervals.

Avoid two specification traps:

- *Undefined objectives:* "Find the best route" is meaningless until "best"
  means shortest, fastest, cheapest, fewest turns, or another measurable goal.
- *Compound objectives:* combining several goals can produce a different and
  substantially harder optimization problem. State priorities or constraints
  explicitly.

=== Choosing a Level of Description

Algorithms may be described in English, pseudocode, diagrams, or executable
code. Choose the highest-level notation that still makes the decisive idea
precise.

#let three-level-description-of-algo-table = table(
  align: left,
  columns: 3,
  [*Form*], [*Strength*], [*Risk*],
  [English], [Natural and idea-focused], [Can be ambiguous],
  [Pseudocode], [Balances clarity and precision], [Can hide a vague idea behind formal-looking syntax],
  [Real code], [Executable and exact], [Implementation details may obscure the algorithmic insight],
)

#figure(caption: "Three level description of algorithms", three-level-description-of-algo-table)

#blockquote[
  If the central idea is difficult to see in the description, the notation is probably too low-level.
]

== Finding Counterexamples

A single valid counterexample disproves a universal correctness claim. A good
counterexample has two properties:

- *Verifiability:* compute the proposed method's result and exhibit a better or correct result.
- *Simplicity:* remove all details that are not necessary to trigger failure.

=== Counterexample Search Strategy

+ *Think small.* Start with the smallest non-trivial instance.
+ *Enumerate small cases.* List all structural possibilities when $n$ is small.
+ *Attack the weak decision.* Identify the irreversible choice made by the heuristic.
+ *Create a tie.* Remove the information on which a greedy rule depends.
+ *Use extremes.* Combine very large and very small, near and far, early and late.
+ *Minimize the witness.* Once failure is found, simplify the instance.

=== Counterexample Template

#pseudocode-list[
  + Claimed method:
  + Input instance:
  + Decision made by the method:
  + Method's output:
  + Better or correct output:
  + Why this disproves the claim:
]

==== Example: Shortest Job First

Consider three intervals:

$A = [0, 4]$, $B = [3, 5]$, and $C = [4, 8]$.

Under the convention that intervals sharing an endpoint are compatible, $A$
and $C$ can both be selected. If $B$ is the shortest interval, shortest-job-first
selects $B$ and removes both $A$ and $C$, producing one job instead of the
optimal two. The exact coordinates can be adjusted to match a different
endpoint-overlap convention.

#blockquote[
  *Testing is not proof*\
  Passing many test cases increases confidence but does not prove a universal
  statement. Testing searches for failures; a correctness proof explains why
  failure is impossible for every valid input.
]

== Proving Correctness

=== Basic Proof Structure

A clear proof contains:

#pseudocode-list[
  + a precise statement of the claim;
  + explicit assumptions;
  + a logical chain from the assumptions to the claim;
  + treatment of boundary cases.
]

Avoid phrases such as _obviously correct_ when the essential reasoning has not
been stated.

=== Induction and Recursion

Recursion and mathematical induction express the same structural idea:

- a *base case* handles the smallest input;
- a *reduction* converts a larger input into one or more smaller inputs;
- an *inductive hypothesis* assumes correctness for the smaller inputs;
- an *inductive step* uses that assumption to prove correctness for the larger input.

==== Insertion Sort Proof Sketch

*Claim:* after iteration $i$, the prefix $A[0 dots i]$ is sorted and contains
exactly the elements originally found in that prefix.

- *Base case:* a one-element prefix is sorted.
- *Inductive hypothesis:* after iteration $i - 1$, the prefix
  $A[0 dots i - 1]$ is sorted.
- *Step:* insert $A[i]$ into its correct position by shifting every larger
  prefix element one place to the right. The resulting prefix remains a
  permutation of its original elements and is sorted.
- *Boundary cases:* the inserted value may be smaller than every prefix value,
  greater than every prefix value, or equal to an existing value.

==== Common Induction Errors

- choosing a base case that does not cover the first recursive call;
- ignoring minimum, maximum, empty, or singleton inputs;
- assuming correctness only for $n - 1$ when the recursion uses any smaller value;
- assuming that adding one item preserves the structure of an optimal solution;
- proving termination but not correctness, or correctness but not termination.

When a recursive call may use any size below $n$, use *strong induction*: assume
the claim holds for every size smaller than $n$.

=== Proof by Contradiction

The pattern is:

+ assume the claim is false;
+ derive logical consequences of that assumption;
+ reach a statement known to be false;
+ conclude that the original claim is true.

The contradiction must be explicit and must follow from the assumption. This
proof style later becomes useful for graph algorithms such as minimum spanning
trees.

== Modeling the Problem

Modeling translates application-specific language into precise mathematical
objects and known computational problems.

#pagebreak()

#let common-problem-model = table(
  align: left,
  columns: (1.05fr, 2fr, 1.75fr),
  [*Object*], [*Typical signals*], [*Examples*],
  [Permutation], [arrangement, tour, ordering, sequence], [visit order, sorting order],
  [Subset], [selection, group, committee, cluster], [accepted jobs, chosen features],
  [Tree], [hierarchy, ancestry, taxonomy, dominance], [file tree, syntax tree],
  [Graph], [network, connection, relationship, circuit], [roads, dependencies, social links],
  [Points], [locations, positions, sites, records], [coordinates, spatial samples],
  [Polygon], [region, boundary, shape], [country border, collision region],
  [String], [text, pattern, label, characters], [search term, DNA sequence],
)

#figure(caption: "", common-problem-model)

=== Modeling Workflow

*From Real Requirements to an Algorithm*

+ Define valid inputs and the exact objective.
+ Identify a standard combinatorial object.
+ Map domain constraints into the model.
+ Solve small examples by hand.
+ Compare the model's answers with stakeholder expectations.
+ Select or design an algorithm.
+ Implement and test.

The lottery case study demonstrates a costly modeling failure: the
implementation solved the formalized covering problem, but the formalization
covered more combinations than the real requirement demanded. Small manual
examples would have exposed the mismatch before implementation.

#blockquote[
  *Model validation question*\
  If the algorithm solved the model perfectly, would the result necessarily
  solve the user's real problem?
]

=== Recursive Views of Common Objects

Many combinatorial objects are naturally decomposable:

- remove one element from a permutation or subset;
- remove a leaf from a tree;
- remove a vertex from a graph;
- split a point set with a line;
- split a polygon with a chord;
- remove one character from a string.

Every recursive definition also needs a base object, such as an empty string,
an empty subset, a single vertex, or a triangle.

== Estimation

Estimation is disciplined approximation. It is useful for judging feasibility,
running time, storage, throughput, and scale before detailed implementation.

A strong estimate:

- decomposes the unknown quantity into simpler factors;
- states assumptions and units;
- uses quantities that are known, measurable, or reasonably approximated;
- checks the result with an independent method;
- focuses on the correct order of magnitude rather than false precision.

Useful approaches include volume, weight, rate, capacity, and analogy. When
independent estimates disagree by several orders of magnitude, revisit the
assumptions.

=== Estimation Template

#pseudocode-list[
  + *procedure* EstimateQuantity($Q$)
    + define the quantity $Q$ to estimate

    + *Method 1*
      + state the assumptions
      + calculate an estimate $E_1$

    + *Method 2*
      + choose an independent estimation approach
      + state the assumptions
      + calculate an estimate $E_2$

    + compare $E_1$ with $E_2$
    + determine a plausible range containing both estimates
    + identify the largest source of uncertainty
    + perform a sanity check against known values

    + *return* the plausible range
  + *end procedure*
]

== Exercise Solutions

=== 1-5: Counterexamples for Knapsack Heuristics

The task is to give, for each proposed greedy rule, an ordered set $S$ and a
target $T$ such that the rule fails even though some subset sums exactly to
$T$. Each item may be used at most once.

*Part (a): First Fit in the Given Order*

Choose

$ S = (6, 4, 5), quad T = 9. $

The algorithm scans from left to right:

- It accepts $6$.
- It rejects $4$ because $6 + 4 > 9$.
- It rejects $5$ because $6 + 5 > 9$.

The algorithm finishes with total $6$, but the subset ${4, 5}$ has total $9$.
Therefore, first fit is not correct.

*Part (b): Smallest to Largest*

Choose

$ S = {1, 3, 4}, quad T = 7. $

After sorting, the order is $1, 3, 4$:

- The algorithm accepts $1$, then $3$, reaching $4$.
- It rejects $4$ because $4 + 4 > 7$.

It fails at total $4$, although ${3, 4}$ fills the knapsack exactly. Therefore,
choosing the smallest available item first is not correct.

*Part (c): Largest to Smallest*

Choose

$ S = {6, 5, 4}, quad T = 9. $

In descending order:

- The algorithm accepts $6$.
- It rejects $5$ and $4$, because either would make the sum exceed $9$.

It fails at total $6$, although ${5, 4}$ sums to $9$. Therefore, choosing the
largest available item first is not correct.

#blockquote[
  A locally feasible choice can destroy the combination needed for an exact
  global sum. One counterexample is sufficient to disprove a universal
  correctness claim.
]

=== 1-8: Correctness of Recursive Multiplication

For a fixed integer $c >= 2$, the algorithm is:

#pagebreak()
#pseudocode-list[
  + *procedure* Multiply($y$, $z$)
    + *if* $z = 0$ *then*
      + *return* $0$
    + *end if*
    + *return* Multiply(
      $c dot y$,
      $floor.l z / c floor.r$,
    ) $+ y (z mod c)$
  + *end procedure*
]

We prove that `Multiply(y, z)` returns $y z$ for all natural numbers $y$ and
$z$.

*Termination*

If $z > 0$, then

$ 0 <= floor(z/c) < z $

because $c >= 2$. Thus, the second argument strictly decreases until it reaches
$0$. The recursion terminates.

*Correctness Proof by Strong Induction on $z$*

*Base case.* If $z = 0$, the algorithm returns $0 = y dot 0$.

*Induction hypothesis.* Assume that for every natural number $k < z$ and every
natural number $a$, `Multiply(a, k)` returns $a k$.

*Induction step.* Let

$ q = floor(z/c), quad r = z mod c. $

By Euclidean division,

$ z = c q + r, quad 0 <= r < c. $

Since $q < z$, the induction hypothesis applies to the recursive call:

$ "Multiply"(c y, q) = (c y) q. $

Therefore, the returned value is

$
  (c y) q + y r
  = y(c q + r)
  = y z.
$

Hence, by strong induction, the algorithm correctly multiplies $y$ and $z$ for
all natural numbers and every integer constant $c >= 2$.

=== 1-10: Correctness of Bubble Sort

The algorithm repeatedly scans the active prefix $A[1 dots i]$, swapping
adjacent inverted pairs.

*Inner-Loop Lemma*

After the inner loop finishes for a fixed $i$, the maximum element of
$A[1 dots i]$ is stored at position $i$.

*Proof.* At iteration $j$, the larger of $A[j]$ and $A[j+1]$ is placed at
position $j+1$. Consequently, after processing position $j$, the maximum of
the original prefix $A[1 dots j+1]$ is at position $j+1$. When $j = i-1$, the
maximum of $A[1 dots i]$ is at $A[i]$.

*Outer-Loop Invariant*

Immediately before the iteration with index $i$:

+ the suffix $A[i+1 dots n]$ is sorted;
+ it contains the $n-i$ largest input elements; and
+ every element of $A[1 dots i]$ is no greater than every element of the
  suffix.

*Initialization.* Before the first iteration, $i=n$. The suffix is empty, so all
three properties hold vacuously.

*Maintenance.* By the inner-loop lemma, the maximum element of the active
prefix is moved to $A[i]$. It is no greater than the already placed elements in
$A[i+1 dots n]$, so $A[i dots n]$ is sorted and contains the $n-i+1$ largest
elements. The invariant is therefore true for the next outer-loop iteration.

*Termination.* After the iteration with $i=1$, the entire array
$A[1 dots n]$ is sorted.

Every operation is an adjacent swap, so no element is added, removed, or
changed. The final array is therefore a sorted permutation of the input.
Bubble sort is correct.

=== 1-11: Correctness of Euclid's Algorithm

Let $x > y > 0$. By Euclidean division, there exist integers $q$ and $r$ such
that

$ x = q y + r, quad r = x mod y, quad 0 <= r < y. $

We prove

$ "gcd"(x, y) = "gcd"(y, r). $

*Common-Divisor Equivalence*

Suppose $d$ divides both $x$ and $y$. Since

$ r = x - q y, $

$d$ also divides $r$. Thus, every common divisor of $x$ and $y$ is a common
divisor of $y$ and $r$.

Conversely, suppose $d$ divides both $y$ and $r$. Since

$ x = q y + r, $
x
$d$ also divides $x$. Thus, every common divisor of $y$ and $r$ is a common
divisor of $x$ and $y$.

The two pairs have exactly the same set of common divisors, so their greatest
common divisors are equal.

*Termination and Base Case*

Each recursive step replaces $(x,y)$ by $(y, x mod y)$, whose second component
is strictly smaller than $y$. Eventually the second component becomes $0$.
At that point,

$ "gcd"(a, 0) = a. $

Therefore, repeated use of the equality preserves the greatest common divisor
until the base case is reached. Euclid's algorithm is correct.

=== 1-19: Edges in a Tree

*Claim.* Every tree with $n >= 1$ vertices has exactly $n-1$ edges.

We prove the claim by induction on $n$.

*Base case.* A tree with one vertex has no edges. Since $0 = 1-1$, the claim
holds.

*Induction hypothesis.* Assume every tree with $n-1$ vertices has exactly
$n-2$ edges.

*Induction step.* Let $T$ be a tree with $n >= 2$ vertices. Every finite tree
with at least two vertices has a leaf, meaning a vertex of degree one. Remove
a leaf $v$ and its unique incident edge.

The remaining graph:

- is connected, because no path between two remaining vertices needs the leaf;
- is acyclic, because removing a vertex cannot create a cycle; and
- has $n-1$ vertices.

It is therefore a tree. By the induction hypothesis, it has $n-2$ edges.
Restoring $v$ and its one incident edge gives

$ (n-2) + 1 = n-1 $

edges. Hence every tree with $n$ vertices has exactly $n-1$ edges.

=== 1-29: Estimating Sorting Time

The algorithm sorts $1,000$ items in one second. Let $T(n)$ denote its running
time.

*Part (a): Quadratic Growth*

If $T(n)$ is proportional to $n^2$, then

$
  T(10000) / T(1000)
  = (10000 / 1000)^2
  = 10^2
  = 100.
$

Therefore,

$ T(10000) = 100 " seconds". $

*Part (b): $n log n$ Growth*

If $T(n)$ is proportional to $n log n$, then

$
  T(10000) / T(1000)
  = (10000 log 10000) / (1000 log 1000)
  = 10 dot 4/3
  = 40/3.
$

The logarithm base does not matter because it cancels in the ratio. Therefore,

$ T(10000) = 40/3 " seconds" approx 13.33 " seconds". $

#blockquote[
  *Interpretation*\
  Increasing the input size by a factor of ten increases quadratic work by a
  factor of 100, but increases $n log n$ work by only about 13.33.
]

=== 1-30: TSP Heuristics

The two heuristics from Section 1.1 are:

- *Nearest neighbor:* repeatedly visit the nearest unvisited point.
- *Closest pair:* repeatedly connect the nearest pair of endpoints belonging
  to different chains, then close the final chain into a cycle.

Neither heuristic guarantees an optimal tour.

*TypeScript Implementation*

```ts
type Point = {
  id: number;
  x: number;
  y: number;
};

function distance(a: Point, b: Point): number {
  return Math.hypot(a.x - b.x, a.y - b.y);
}

function tourLength(tour: Point[]): number {
  let total = 0;

  for (let i = 0; i < tour.length; i++) {
    total += distance(tour[i], tour[(i + 1) % tour.length]!);
  }

  return total;
}

function nearestNeighbor(points: Point[]): Point[] {
  if (points.length <= 1) return [...points];

  // Use points[0] as the initial point.
  const unvisited = new Set(
    points.slice(1).map((_, index) => index + 1),
  );
  const tour = [points[0]!];
  let current = 0;

  while (unvisited.size > 0) {
    let next = -1;
    let bestDistance = Infinity;

    for (const candidate of unvisited) {
      const candidateDistance = distance(
        points[current]!,
        points[candidate]!,
      );

      if (candidateDistance < bestDistance) {
        bestDistance = candidateDistance;
        next = candidate;
      }
    }

    tour.push(points[next]!);
    unvisited.delete(next);
    current = next;
  }

  return tour;
}

function closestPair(points: Point[]): Point[] {
  let chains: Point[][] = points.map((point) => [point]);

  while (chains.length > 1) {
    let best = {
      distance: Infinity,
      a: -1,
      b: -1,
      aAtStart: false,
      bAtStart: false,
    };

    for (let a = 0; a < chains.length; a++) {
      for (let b = a + 1; b < chains.length; b++) {
        const chainA = chains[a]!;
        const chainB = chains[b]!;

        const endpointsA: Array<[Point, boolean]> = [
          [chainA[0]!, true],
          [chainA[chainA.length - 1]!, false],
        ];
        const endpointsB: Array<[Point, boolean]> = [
          [chainB[0]!, true],
          [chainB[chainB.length - 1]!, false],
        ];

        for (const [pointA, aAtStart] of endpointsA) {
          for (const [pointB, bAtStart] of endpointsB) {
            const candidateDistance = distance(pointA, pointB);

            if (candidateDistance < best.distance) {
              best = {
                distance: candidateDistance,
                a,
                b,
                aAtStart,
                bAtStart,
              };
            }
          }
        }
      }
    }

    // Orient the selected endpoint of A at the right side.
    const left = best.aAtStart
      ? [...chains[best.a]!].reverse()
      : [...chains[best.a]!];

    // Orient the selected endpoint of B at the left side.
    const right = best.bAtStart
      ? [...chains[best.b]!]
      : [...chains[best.b]!].reverse();

    const merged = [...left, ...right];

    chains = chains.filter(
      (_, index) => index !== best.a && index !== best.b,
    );
    chains.push(merged);
  }

  return chains[0] ?? [];
}
```

The nearest-neighbor implementation takes $O(n^2)$ time. The direct
closest-pair implementation above takes $O(n^3)$ time because it rescans
candidate chain endpoints after each merge.

*A Better Heuristic: Best Seed Plus 2-opt*

First take the shorter tour produced by the two original heuristics. Then apply
2-opt: replace two tour edges $(a,b)$ and $(c,d)$ by $(a,c)$ and $(b,d)$ whenever
the replacement shortens the tour. Reversing the segment between the new edges
preserves a valid cycle.

```ts
function twoOpt(tour: Point[]): Point[] {
  const result = [...tour];
  let improved = true;

  while (improved) {
    improved = false;

    for (let i = 0; i < result.length - 1 && !improved; i++) {
      for (let k = i + 2; k < result.length; k++) {
        // These are the same edge of the cycle.
        if (i === 0 && k === result.length - 1) continue;

        const a = result[i]!;
        const b = result[(i + 1) % result.length]!;
        const c = result[k]!;
        const d = result[(k + 1) % result.length]!;

        const oldCost = distance(a, b) + distance(c, d);
        const newCost = distance(a, c) + distance(b, d);

        if (newCost < oldCost) {
          const reversed = result.slice(i + 1, k + 1).reverse();
          result.splice(i + 1, reversed.length, ...reversed);
          improved = true;
          break;
        }
      }
    }
  }

  return result;
}

function improvedTour(points: Point[]): Point[] {
  const nearest = nearestNeighbor(points);
  const closest = closestPair(points);

  const seed =
    tourLength(nearest) <= tourLength(closest)
      ? nearest
      : closest;

  return twoOpt(seed);
}
```

Each accepted 2-opt move strictly reduces the tour length, so the procedure
terminates. It reaches a 2-opt local optimum, not necessarily the global
optimum.

*Reproducible Experiment*

The following results use 100 independently generated point sets for each
size. Coordinates are uniformly distributed in the square
$[0,1000] times [0,1000]$. A seeded pseudo-random generator is used, and
nearest neighbor always starts at point $0$.

#table(
  align: left,
  columns: 5,
  [*$n$*], [*Trials*], [*Nearest neighbor*], [*Closest pair*], [*Best seed + 2-opt*],
  [20], [100], [4580.12], [4358.18], [3950.44],
  [50], [100], [7014.91], [6672.88], [5928.52],
  [100], [100], [9698.19], [9085.96], [8104.09],
)

In these random Euclidean instances, closest pair beat nearest neighbor in
$64$, $72$, and $83$ of the $100$ trials for $n=20$, $50$, and $100$,
respectively. Thus, closest pair performed better on this particular input
distribution.

The improved heuristic was never worse than either original heuristic: it
starts from the shorter original tour and accepts only length-reducing moves.
However, these measurements are empirical, not a proof that closest pair or
2-opt always has a particular approximation quality.
