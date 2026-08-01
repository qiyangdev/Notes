#import "@preview/ilm:2.1.1": blockquote

= Language Basics
== Syntax and Program Structure
=== Case sensitivity

ECMAScript is case-sensitive. This applies to variable names, function names,
keywords, and operators.

```js
const value = 1;
const Value = 2;

console.log(value); // 1
console.log(Value); // 2
```

`typeof` is a keyword, but `Typeof` can be used as an identifier. Using such a
name is legal but needlessly confusing.

=== Identifiers

An identifier names a variable, function, or parameter.

- The first character must be a letter, `_`, or `$`.
- Later characters may also include decimal digits.
- Unicode letters are permitted, though uncommon identifiers reduce readability.
- Keywords, reserved words, `true`, `false`, and `null` cannot be identifiers.

The chapter recommends camel case:

```js
let currentUser;
function calculateTotalPrice() {}
```

=== Comments

JavaScript supports single-line and block comments.

```js
// A single-line comment

/*
  A block comment
  spanning multiple lines
*/
```

Comments should explain intent, constraints, or non-obvious reasoning rather
than restating straightforward code.

=== Strict mode

Strict mode changes parsing and execution so that unsafe or ambiguous behavior
is rejected more aggressively.

```js
"use strict";
```

It may also be applied to one function:

#pagebreak()
```js
function parseInput(input) {
  "use strict";
  return Number(input);
}
```

Modules and class bodies are strict automatically. Modern build tools may also
insert the directive.

#blockquote[
  *Mental model*\
  Strict mode narrows the language. Instead of silently accepting several legacy
  behaviors, the runtime reports them as errors.
]

=== Statements, semicolons, and blocks

A semicolon terminates a statement. Automatic semicolon insertion can infer some
terminators, but the chapter recommends writing semicolons explicitly.

```js
const total = subtotal + tax;
```

Control-flow bodies should use braces even when they contain one statement:

```js
if (isReady) {
  start();
}
```

Braces make intent explicit and reduce errors when another line is added later.

=== Keywords and reserved words

Keywords have a defined grammatical role, such as `if`, `return`, `class`,
`typeof`, and `new`. Future reserved words are held back for possible language
use. They must not be used as bindings.

Strict mode adds further restrictions around names such as `eval` and
`arguments`.

== Variable Declarations

=== JavaScript variables are loosely typed

A variable is a named place for a value, not a permanently typed storage slot.
The value and its type may change over time.

```js
let result = "pending";
result = 42; // legal, though changing semantic type is often poor design
```

The language permits this, but stable variable meaning generally makes programs
easier to reason about.

=== `var`: function scope and hoisting

A `var` declaration is scoped to the containing function, not to the nearest
block.

```js
if (true) {
  var status = "ready";
}

console.log(status); // "ready"
```

The declaration is hoisted to the top of its function scope. Initialization is
not hoisted.

```js
function demo() {
  console.log(count); // undefined
  var count = 3;
}
```

The runtime behaves conceptually as though it had seen:

```js
function demo() {
  var count;
  console.log(count);
  count = 3;
}
```

Repeated `var` declarations in the same scope are allowed.

#blockquote([
  Assigning to an undeclared identifier can create a global binding in non-strict
  code. This is difficult to maintain and becomes a `ReferenceError` in strict
  mode.
])

=== `let`: block scope

`let` is scoped to the nearest block.

```js
if (true) {
  let token = "abc";
  console.log(token);
}

console.log(token); // ReferenceError
```

A binding cannot be redeclared in the same block. Nested blocks may reuse the
same spelling because they create different bindings.

```js
let level = 1;

if (true) {
  let level = 2;
  console.log(level); // 2
}

console.log(level); // 1
```

Mixing `var` and `let` does not make duplicate names legal in one scope.

=== Temporal dead zone

The engine knows that a `let` binding belongs to the block before execution
reaches its declaration, but the binding cannot be accessed until initialization.
The interval before initialization is the temporal dead zone.

```js
console.log(score); // ReferenceError
let score = 10;
```

It is misleading to say that `let` is simply “not hoisted.” The binding is known,
but it is unavailable before the declaration executes.

=== Global declarations

At top level in a classic browser script:

- `var` creates a property on `window`;
- `let` and `const` create global lexical bindings but do not become properties of
  `window`.

```js
var appName = "Notes";
let buildNumber = 12;

console.log(window.appName);    // "Notes"
console.log(window.buildNumber); // undefined
```

=== Loop bindings

Using `let` for a loop counter keeps the counter inside the loop and creates a new
binding for each iteration where needed.

```js
for (let i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 0);
}

// 0, 1, 2
```

With `var`, each callback closes over the same function-scoped binding, which has
already reached its final value when the callbacks execute.

=== `const`: a non-reassignable binding

`const` has block scope and the same temporal-dead-zone behavior as `let`. It
must be initialized and cannot later be assigned another value.

```js
const port = 3000;
port = 4000; // TypeError
```

For objects, the binding is constant; the object is not automatically immutable.

```js
const user = {};
user.name = "Alice"; // allowed
```

A `const` binding cannot be used as a counter that is incremented, but it works
well for `for-in` and `for-of` iteration variables because each iteration receives a
fresh binding.

```js
for (const value of [10, 20, 30]) {
  console.log(value);
}
```

=== Declaration policy

The chapter recommends:

- avoid `var` in new code;
- use `const` by default;
- use `let` only when reassignment is part of the design.

#blockquote[
  *Practical rule*\
  Choose the narrowest scope and the strongest reassignment constraint that the
  program permits. This reduces the number of states a reader must consider.
]

== The ECMAScript Type System

=== The eight categories

The chapter describes seven primitive types and one complex type.

#table(
  columns: 2,
  table.header([*Category*], [*Purpose*]),
  [`Undefined`], [An uninitialized or absent binding value.],
  [`Null`], [An intentional empty object reference.],
  [`Boolean`], [`true` or `false`.],
  [`Number`], [IEEE-754 double-precision numeric values.],
  [`BigInt`], [Integers larger than the safe integer range of `Number`.],
  [`String`], [Immutable sequences of 16-bit code units.],
  [`Symbol`], [Unique, immutable property keys and protocol tokens.],
  [`Object`], [Collections of properties and behavior.],
)

=== The `typeof` operator

`typeof` returns a string describing the broad runtime category of a value.

#table(
  columns: 2,
  table.header([*Value category*], [*Result*]),
  [Undefined], [`"undefined"`],
  [Boolean], [`"boolean"`],
  [String], [`"string"`],
  [Number], [`"number"`],
  [BigInt], [`"bigint"`],
  [Symbol], [`"symbol"`],
  [Function], [`"function"`],
  [Object or `null`], [`"object"`],
)

Parentheses are optional because `typeof` is an operator:

```js
const message = "hello";

typeof message;   // "string"
typeof(message);  // "string"
```

The `typeof null` result is a historical quirk consistent with the chapter's
model of `null` as an empty object reference.

=== `undefined`

A declared but uninitialized `let` or `var` binding contains `undefined`.

```js
let response;
console.log(response); // undefined
```

A declared binding containing `undefined` is different from an undeclared
identifier. Reading the undeclared identifier throws, but `typeof` is safe in both
cases:

```js
let declared;

typeof declared;     // "undefined"
typeof notDeclared;  // "undefined"
```

Because both cases produce the same `typeof` result, initializing variables makes
program intent clearer.

The chapter advises against explicitly assigning `undefined`; it is mainly useful
as the language's marker for missing initialization.

=== `null`

`null` represents an intentionally empty object reference.

```js
let selectedNode = null;
```

Use it when a variable is expected eventually to hold an object but currently does
not.

```js
if (selectedNode !== null) {
  selectedNode.remove();
}
```

Loose equality considers `null` and `undefined` equal:

```js
null == undefined;  // true
null === undefined; // false
```

Their uses remain different: `undefined` generally indicates absence of
initialization, while `null` intentionally represents no object.

=== Boolean conversion and truthiness

`Boolean(value)` converts any value to `true` or `false`. Flow-control conditions
perform the same conversion automatically.

#pagebreak()
#table(
  columns: 3,
  table.header([*Type*], [*Truthy examples*], [*Falsy values*]),
  [Boolean], [`true`], [`false`],
  [String], [Any nonempty string], [Empty string `""`],
  [Number], [Any nonzero number, including infinity], [`0`, `-0`, `NaN`],
  [BigInt], [Any nonzero BigInt], [`0n`],
  [Object], [Every object], [`null`],
  [Undefined], [None], [`undefined`],
)

```js
if ("ready") {
  console.log("runs");
}
```

#blockquote[
  A truthiness check cannot distinguish among all falsy values. Use an exact
  comparison when `0`, an empty string, `null`, and `undefined` have different
  meanings.
]

== Numbers and Numeric Conversion

=== `Number` representation

JavaScript uses IEEE-754 double-precision format for ordinary numbers. One type
therefore represents integers, floating-point values, infinities, and `NaN`.

Numeric literals may be written in several bases:

```js
const decimal = 42;
const binary = 0b101010;
const octal = 0o52;
const hexadecimal = 0x2a;
```

All participate in arithmetic as numeric values; the literal notation does not
create a different numeric type.

=== Floating-point precision

Floating-point values are not exact decimal fractions in all cases.

```js
0.1 + 0.2; // 0.30000000000000004
```

Avoid exact equality tests for computed floating-point results.

```js
const EPSILON = 1e-10;
const approximatelyEqual =
  Math.abs((0.1 + 0.2) - 0.3) < EPSILON;
```

The chapter emphasizes that this is a consequence of IEEE-754 arithmetic, not a
JavaScript-only defect.

=== Numeric separators

Underscores improve readability and do not affect the value.

```js
const population = 1_000_000;
const mask = 0b1111_0000;
const precise = 1_000.000_001;
```

A separator cannot begin or end a literal, sit next to the decimal point, or
follow the leading zero of a legacy-style literal.

=== Range and infinity

`Number.MIN_VALUE` and `Number.MAX_VALUE` describe the finite range supported by
the numeric representation. Overflow produces `Infinity` or `-Infinity`.

```js
const overflow = Number.MAX_VALUE + Number.MAX_VALUE;
isFinite(overflow); // false
```

An infinite result cannot behave like an ordinary finite value in later
calculations, so large-scale numeric work should check range assumptions.

=== `NaN`

`NaN` means that a numeric operation failed to produce a meaningful number.

Key properties:

- arithmetic involving `NaN` usually produces `NaN`;
- `NaN` is not equal to any value, including itself.

```js
NaN === NaN; // false
```

The global `isNaN()` function first attempts numeric conversion, then reports
whether the converted value is `NaN`.

```js
isNaN("10");   // false: converts to 10
isNaN("blue"); // true: converts to NaN
isNaN(true);    // false: converts to 1
```

This coercing behavior should be kept in mind when interpreting the result.

=== `Number()` conversion

`Number(value)` accepts any value and follows broad conversion rules.

#table(
  columns: 2,
  table.header([*Input*], [*Result*]),
  [`true` / `false`], [`1` / `0`],
  [`null`], [`0`],
  [`undefined`], [`NaN`],
  [Empty string], [`0`],
  [Numeric string], [Corresponding number],
  [Invalid numeric string], [`NaN`],
)

```js
Number("42");     // 42
Number("");       // 0
Number(null);     // 0
Number(undefined); // NaN
```

The unary plus operator performs the same conversion.

=== `parseInt()`

`parseInt()` is designed for strings containing integer text. It scans from the
start and stops at the first invalid character.

```js
parseInt("120px", 10); // 120
parseInt("", 10);      // NaN
parseInt("ff", 16);    // 255
```

Always passing a radix makes the intended base explicit.

=== `parseFloat()`

`parseFloat()` scans a decimal floating-point representation and stops at the
first invalid character.

```js
parseFloat("18.75kg"); // 18.75
parseFloat("7.2.3");   // 7.2
parseFloat("0xA");     // 0
```

It does not accept a radix because it parses decimal floating-point text.

=== `BigInt`

`BigInt` is for integers beyond `Number.MAX_SAFE_INTEGER`. Create one with an `n`
suffix or the `BigInt()` function.

```js
const id = 9_007_199_254_740_993n;
const parsed = BigInt("9007199254740993");
```

Important restrictions:

- `Number` and `BigInt` cannot be mixed in arithmetic or bitwise operations;
- `BigInt` cannot represent fractions;
- `Math` methods do not accept `BigInt`;
- division truncates the remainder;
- unary `+` and unsigned right shift `>>>` are unsupported.

```js
10n + 5n; // 15n
10n / 3n; // 3n
10n + 5;  // TypeError
```

Explicit conversion may lose precision when a large `BigInt` becomes a `Number`.

```js
Number(9_007_199_254_740_993n);
// precision may be lost
```

`BigInt.asIntN()` and `BigInt.asUintN()` clamp a value to a chosen number of bits.
Because the representation uses two's complement, the resulting value may change
sign or magnitude.

=== BigInt and JSON

`JSON.stringify()` does not serialize `BigInt` directly. A replacer can convert it
to text, and a reviver can reconstruct it.

```js
const data = { id: 1234n };

const json = JSON.stringify(data, (_key, value) =>
  typeof value === "bigint" ? value.toString() : value
);

const restored = JSON.parse(json, (key, value) =>
  key === "id" ? BigInt(value) : value
);
```

== Strings, Templates, and Symbols

=== String literals

Strings may use single quotes, double quotes, or backticks. The opening and
closing delimiters must match.

```js
const first = "Alice";
const last = 'Jones';
const label = `User: ${first} ${last}`;
```

Escape sequences represent newlines, tabs, quotes, backslashes, hexadecimal
characters, and Unicode code points.

```js
const message = "first line\nsecond line";
const sigma = "\u03A3";
```

The `length` property counts 16-bit code units. It may not equal the number of
user-perceived characters for all Unicode text.

=== String immutability

Strings cannot be modified in place. An apparent update creates another string and
reassigns the binding.

```js
let language = "Java";
language = language + "Script";
```

The original string value does not mutate.

=== Converting to a string

Most values provide `toString()`.

```js
(10).toString();   // "10"
true.toString();   // "true"
(10).toString(2);  // "1010"
```

`null` and `undefined` do not provide an instance `toString()` method. `String()`
handles every value safely.

```js
String(null);      // "null"
String(undefined); // "undefined"
```

Adding an empty string also causes conversion, but an explicit `String()` call often
communicates intent more clearly.

=== Template literals

Backtick-delimited templates preserve line breaks and support interpolation.

```js
const user = "Alice";
const count = 3;

const summary = `${user} has ${count} tasks.`;
```

An interpolation may contain any JavaScript expression. The result is converted to
a string.

```js
const total = `${2 + 3}`; // "5"
```

Templates preserve all whitespace between the backticks, including leading
newlines and indentation.

=== Tagged templates

A tag function receives:

- an array containing the literal string segments;
- one argument for each evaluated interpolation.

```js
function inspect(strings, ...values) {
  return strings
    .map((part, index) => part + (values[index] ?? ""))
    .join("");
}

const value = inspect`Result: ${2 + 3}`;
```

For _n_ interpolations, the tag receives _n + 1_ literal segments. A tag may return
any value; it defines the interpretation of the template.

`String.raw` exposes escape sequences without interpreting them.

```js
String.raw`line one\nline two`;
// "line one\\nline two"
```

=== Symbols

A symbol is a unique, immutable primitive commonly used as an object property key.

```js
const first = Symbol("id");
const second = Symbol("id");

first === second; // false
```

The optional description helps debugging but does not define identity.

`Symbol()` is not a constructor and cannot be called with `new`.

=== Global symbol registry

`Symbol.for(key)` finds or creates a symbol in a runtime-wide registry.

```js
const a = Symbol.for("app.id");
const b = Symbol.for("app.id");

a === b; // true
Symbol.keyFor(a); // "app.id"
```

A locally created `Symbol("app.id")` remains distinct from a registry symbol with
the same description.

=== Symbols as properties

Symbols can be used anywhere a computed property key is accepted.

```js
const internalId = Symbol("internalId");

const record = {
  name: "Alice",
  [internalId]: 17,
};
```

Symbol-keyed properties are not returned by `Object.getOwnPropertyNames()`.
Use `Object.getOwnPropertySymbols()` or `Reflect.ownKeys()` when they must be
included.

=== Well-known symbols

ECMAScript provides well-known symbols that expose protocol hooks. The chapter
introduces several:

#table(
  columns: 2,
  table.header([*Symbol*], [*Protocol or behavior*]),
  [`Symbol.iterator`], [Defines default synchronous iteration used by `for-of`.],
  [`Symbol.asyncIterator`], [Defines asynchronous iteration used by `for await-of`.],
  [`Symbol.hasInstance`], [Customizes `instanceof`.],
  [`Symbol.isConcatSpreadable`], [Controls flattening by `Array.prototype.concat()`.],
  [`Symbol.match`], [Customizes behavior used by `String.prototype.match()`.],
  [`Symbol.replace`], [Customizes behavior used by `String.prototype.replace()`.],
  [`Symbol.search`], [Customizes behavior used by `String.prototype.search()`.],
  [`Symbol.split`], [Customizes behavior used by `String.prototype.split()`.],
  [`Symbol.species`], [Selects the constructor for derived objects.],
  [`Symbol.toPrimitive`], [Controls object-to-primitive conversion.],
  [`Symbol.toStringTag`], [Changes the tag used by `Object.prototype.toString()`.],
  [`Symbol.unscopables`], [Excludes names from `with` environment bindings.],
)

These symbols are ordinary symbol values stored on the global `Symbol` function,
but language operations consult them at defined points.

=== The `Object` type

`Object` is the base complex type. A plain object may be created with a constructor
or, more commonly, an object literal.

```js
const first = new Object();
const second = {};
```

Common inherited operations include:

- `constructor`;
- `hasOwnProperty()`;
- `isPrototypeOf()`;
- `propertyIsEnumerable()`;
- `toLocaleString()`;
- `toString()`;
- `valueOf()`.

Browser host objects are supplied by the environment and are not defined solely by
ECMA-262, so their inheritance behavior may not always match ordinary objects.

== Operators and Coercion

=== General conversion model

Many JavaScript operators accept operands of several types. For objects, an operator
may request a primitive through `valueOf()` or `toString()`. The exact conversion
depends on the operator.

This flexibility is powerful but creates edge cases. Operator use should therefore be
based on known operand types.

=== Prefix and postfix increment or decrement

Prefix forms update the binding before the surrounding expression uses the value.
Postfix forms use the old value, then update the binding.

```js
let a = 2;
const before = ++a; // a = 3, before = 3

let b = 2;
const after = b++;  // after = 2, b = 3
```

These operators convert strings, Booleans, and objects to numbers before applying
the update, which can also change the type stored in the variable.

```js
let value = "2";
value++;
console.log(value); // 3, now a number
```

=== Unary plus and minus

Unary plus performs the same conversion as `Number()`.

```js
+"12";    // 12
+true;    // 1
+"blue";  // NaN
```

Unary minus performs numeric conversion and then negates the result.

```js
-"12"; // -12
-false; // -0
```

=== Bitwise operators

Bitwise operators convert ordinary numbers to 32-bit integers, perform the
operation, and convert the result back to a JavaScript `Number`.

Consequences include:

- values outside the 32-bit range are truncated;
- `NaN` and infinity behave as zero in bitwise operations;
- negative values use two's-complement representation.

#table(
  columns: 3,
  table.header([*Operator*], [*Name*], [*Effect*]),
  [`~x`], [NOT], [Flips every bit; numerically similar to `-x - 1`.],
  [`a & b`], [AND], [Bit is `1` only when both input bits are `1`.],
  [`a | b`], [OR], [Bit is `1` when either input bit is `1`.],
  [`a ^ b`], [XOR], [Bit is `1` when exactly one input bit is `1`.],
  [`x << n`], [Left shift], [Shifts left and fills on the right with zero bits.],
  [`x >> n`], [Signed right shift], [Shifts right while preserving the sign bit.],
  [`x >>> n`], [Unsigned right shift], [Shifts right and fills left bits with zeros.],
)

Unsigned right shift can turn a negative 32-bit value into a large positive number.

=== Logical NOT

`!` converts its operand to Boolean and negates it. `!!` converts to the direct
Boolean equivalent.

```js
!"ready";  // false
!!"ready"; // true
!!0;       // false
```

=== Logical AND

`a && b` evaluates left to right.

- If `a` is falsy, the expression returns `a` without evaluating `b`.
- Otherwise, it evaluates and returns `b`.

```js
const label = user && user.name;
```

This is short-circuit evaluation. The result is not necessarily a Boolean.

=== Logical OR

`a || b` also evaluates left to right.

- If `a` is truthy, it returns `a` without evaluating `b`.
- Otherwise, it evaluates and returns `b`.

```js
const theme = savedTheme || "light";
```

This traditional default-value pattern also replaces valid falsy values such as `0`
and `""`, which may be undesirable.

=== Multiplication, division, remainder, and exponentiation

The multiplicative operators convert nonnumeric operands with `Number()` and apply
special rules for `NaN`, zero, and infinity.

```js
6 * 7;    // 42
12 / 4;   // 3
26 % 5;   // 1
3 ** 2;   // 9
```

Division by zero and operations involving infinity do not necessarily throw. They
may return `Infinity`, `-Infinity`, or `NaN` depending on the operands.

=== Addition

Addition has two modes:

- numeric addition when both operands are numeric after the required conversions;
- string concatenation when either operand is a string.

```js
5 + 5;   // 10
5 + "5"; // "55"
```

Evaluation proceeds left to right.

```js
const a = 5;
const b = 10;

"Sum: " + a + b;     // "Sum: 510"
"Sum: " + (a + b);   // "Sum: 15"
```

#blockquote([
  The `+` operator is the most common source of accidental coercion because it is
  both arithmetic addition and string concatenation.
])

=== Subtraction

Subtraction is numeric. Strings, Booleans, `null`, and `undefined` are converted with
numeric conversion rules.

```js
5 - "2";  // 3
5 - true; // 4
5 - "";   // 5
5 - null; // 5
```

=== Relational comparison

`<`, `>`, `<=`, and `>=` compare numbers numerically. When both operands are
strings, comparison is based on corresponding character codes rather than natural
language sorting.

```js
"23" < "3"; // true: string comparison
"23" < 3;   // false: numeric conversion
```

Uppercase and lowercase letters have different code-point ranges, so a direct string
comparison is not a locale-aware alphabetical sort.

Any relational comparison involving `NaN` returns `false`.

=== Loose equality

`==` and `!=` convert operands according to equality rules before comparison.
Examples from the chapter's conversion model include:

```js
"5" == 5;          // true
false == 0;        // true
null == undefined; // true
NaN == NaN;        // false
```

Objects compare equal only when both operands refer to the same object.

=== Strict equality

`===` and `!==` do not convert operand types.

```js
"5" === 5; // false
5 === 5;   // true
```

The chapter recommends strict equality to preserve type integrity and avoid hidden
conversion.

=== Conditional operator

The ternary operator selects one of two values.

```js
const max = left > right ? left : right;
```

It is an expression, so it works well for concise value selection. Deeply nested
ternaries reduce readability.

=== Nullish coalescing

`a ?? b` returns `b` only when `a` is `null` or `undefined`. Otherwise, it returns
`a`.

```js
0 || 10;  // 10
0 ?? 10;  // 0

"" || "default"; // "default"
"" ?? "default"; // ""
```

Use `??` when the fallback should apply only to missing values, not to every falsy
value.

=== Assignment operators

Compound assignments combine an operation with reassignment.

```js
count += 1;
power **= 2;
flags |= mask;
```

Logical and nullish compound forms update conditionally:

```js
options.timeout ??= 5000;
cache ||= createCache();
ready &&= validate();
```

They are shorthand and do not inherently improve runtime performance.

=== Comma operator

The comma operator evaluates multiple expressions and returns the last value.

```js
const result = (1, 2, 3); // 3
```

Its most common appearance is in declaration lists. Using it for complex expression
sequencing usually harms clarity.

== Flow-Control Statements

=== `if`

The condition may be any expression. JavaScript converts it to Boolean.

```js
if (score >= 90) {
  grade = "A";
} else if (score >= 80) {
  grade = "B";
} else {
  grade = "C";
}
```

Braces are recommended for every branch.

=== `do-while`

A `do-while` loop tests its condition after executing the body, so the body runs at
least once.

```js
let attempts = 0;

do {
  attempts += 1;
} while (attempts < 3);
```

Use it when one execution is required before the continuation test.

=== `while`

A `while` loop checks before the body. The body may never execute.

#pagebreak()
```js
let index = 0;

while (index < items.length) {
  process(items[index]);
  index += 1;
}
```

=== Classic `for`

A classic `for` loop groups initialization, condition, and update.

```js
for (let i = 0; i < items.length; i++) {
  process(items[i]);
}
```

Each part is optional. Omitting all three creates an infinite loop.

```js
for (;;) {
  runNextTask();
}
```

Anything expressible with `for` can also be written with `while`; `for` simply keeps
loop mechanics together.

=== `for-in`

`for-in` enumerates non-symbol enumerable property names of an object.

```js
for (const key in configuration) {
  console.log(key, configuration[key]);
}
```

It is about property names, not iterable values. The chapter cautions that property
order should not be treated as universally predictable.

If the expression is `null` or `undefined`, the body is not executed.

=== `for-of`

`for-of` consumes values produced by an iterable.

```js
for (const value of [2, 4, 6]) {
  console.log(value);
}
```

The order is the order produced by the iterable's iterator. A non-iterable operand
causes an error.

The asynchronous extension, `for await-of`, consumes async iterables and is covered
more fully later in the book.

#blockquote[
  *Distinction*\
  `for-in` asks, “Which enumerable string keys does this object expose?”\
  `for-of` asks, “Which values does this iterable produce?”
]

=== Labels, `break`, and `continue`

A label names a statement, most commonly an outer loop.

```js
outer:
for (let row = 0; row < 3; row++) {
  for (let column = 0; column < 3; column++) {
    if (row === 1 && column === 1) {
      break outer;
    }
  }
}
```

- `break` exits a loop immediately.
- `continue` skips the remainder of the current iteration.
- A labeled form can target an outer loop.

Labels are powerful but can make control flow harder to debug. Use descriptive
labels and shallow nesting.

=== `with`

`with` temporarily treats an object's properties as possible bindings.

```js
with (location) {
  console.log(hostname);
}
```

It is forbidden in strict mode and is widely considered poor practice because it
makes name resolution ambiguous, harms optimization, and complicates debugging.

=== `switch`

`switch` selects a branch using strict equality.

```js
switch (status) {
  case "idle":
    showIdle();
    break;
  case "loading":
    showSpinner();
    break;
  default:
    showUnknown();
}
```

Without `break`, execution falls through into the next case. The chapter recommends
explicit `break` statements unless fallthrough is intentional.

Case labels may be values or expressions, and JavaScript `switch` is not limited to
numbers.

== Function Fundamentals

=== Declaration and invocation

A function groups statements that can be invoked repeatedly.

```js
function greet(name, message) {
  console.log(`Hello ${name}, ${message}`);
}

greet("Alice", "welcome back");
```

This chapter introduces only the basic form. A later chapter covers functions in
depth.

=== Return values

A function does not declare a fixed return type in JavaScript. `return` immediately
ends execution and optionally supplies a result.

```js
function sum(left, right) {
  return left + right;
}

const total = sum(5, 10);
```

Code after an executed `return` statement is unreachable.

```js
function example() {
  return 1;
  console.log("never runs");
}
```

A function may have multiple return paths.

```js
function absoluteDifference(a, b) {
  if (a < b) {
    return b - a;
  }

  return a - b;
}
```

A bare `return` exits the function and produces `undefined`.

```js
function process(value) {
  if (value == null) {
    return;
  }

  console.log(value);
}
```

If execution reaches the end without any `return`, the function also returns
`undefined`.

=== Return consistency

The chapter recommends designing a function either to return a useful value on all
normal paths or not to return a meaningful value at all. A function that unpredictably
switches between a value and `undefined` is harder to use and debug.

=== Strict-mode function restrictions

In strict mode:

- a function cannot be named `eval` or `arguments`;
- a parameter cannot be named `eval` or `arguments`;
- duplicate parameter names are not allowed.

Violations are syntax errors.

== High-Value Pitfalls

=== Pitfall matrix

#table(
  columns: 3,
  table.header([*Pitfall*], [*Why it happens*], [*Preferred response*]),
  [`var` leaking from blocks], [`var` is function-scoped.], [Use `const` or `let`.],
  [Access before a `let` declaration], [The binding is in the temporal dead zone.], [Declare before use.],
  [`typeof null === "object"`], [Historical language behavior.], [Check explicitly for `null`.],
  [`NaN === NaN` is false], [`NaN` is unequal to every value.], [Use an appropriate `NaN` check.],
  [`0.1 + 0.2` mismatch], [Binary floating-point cannot represent every decimal exactly.], [Use tolerances for computed comparisons.],
  [`5 + "5"` becomes `"55"`], [`+` switches to concatenation when a string participates.], [Know operand types or convert explicitly.],
  [`value || fallback` loses `0`], [`||` falls back for every falsy value.], [Use `??` for nullish defaults.],
  [`for-in` over an array], [`for-in` enumerates property names.], [Use `for-of` for array values.],
  [Mutating a `const` object], [`const` protects the binding, not object contents.], [Freeze explicitly when immutability is required.],
  [Missing `break` in `switch`], [Execution falls through.], [Add `break` unless fallthrough is deliberate.],
)

=== Predict before running

Use the following snippets as retrieval practice.

```js
let a;
console.log(typeof a);
console.log(typeof missing);
```

Expected result: both `typeof` expressions produce `"undefined"`, even though one
binding exists and the other does not.

```js
const values = [null, undefined, 0, ""];
console.log(values.map((value) => value || "default"));
console.log(values.map((value) => value ?? "default"));
```

Expected distinction: `||` replaces all four values; `??` replaces only `null` and
`undefined`.

```js
for (var i = 0; i < 3; i++) {
  setTimeout(() => console.log(i), 0);
}
```

Expected result: the callbacks observe the same binding after the loop, so they print
its final value.

```js
console.log("20" < "3");
console.log("20" < 3);
```

Expected result: the first is a string-code comparison; the second converts the
string to a number.