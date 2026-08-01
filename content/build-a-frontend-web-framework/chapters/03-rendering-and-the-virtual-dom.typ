#import "@preview/ilm:2.1.1": blockquote

= Rendering and the Virtual DOM

== Separation of Concerns

=== The Original Coupling

In the vanilla TODO application, one body of code is responsible for several distinct concerns:

- initializing application state;
- creating HTML elements through the Document API;
- attaching event listeners;
- applying business rules;
- updating state after an event;
- manually synchronizing the DOM with the changed state.

This mixes two abstraction levels:

#table(
  columns: 2,
  [*Level*], [*Responsibility*],
  [Application], [Express domain behavior: adding, editing, and removing TODO items.],
  [Framework / DOM], [Translate the desired view into browser nodes and keep those nodes synchronized.],
)

=== The Desired Boundary

The application should describe the desired view. The framework should interpret that description and perform the required DOM operations.

#align(center)[
  #block[
    #text(weight: "bold")[Application state]
    #h(7pt) -> #h(7pt)
    #text(weight: "bold")[View function]
    #h(7pt) -> #h(7pt)
    #text(weight: "bold")[Virtual DOM]
    #h(7pt) -> #h(7pt)
    #text(weight: "bold")[Framework renderer]
    #h(7pt) -> #h(7pt)
    #text(weight: "bold")[Browser DOM]
  ]
]

Figure 3.2 in the chapter visualizes this boundary: application code initializes state, describes the view, and reacts to events by changing state; framework code draws the view with the Document API and updates the DOM when state changes.

=== Why the Separation Matters

#table(
  columns: 2,
  [*Benefit*], [*Reason*],
  [Developer productivity], [Application developers write less low-level DOM code and can focus on domain behavior.],
  [Maintainability], [Business rules and rendering mechanics are no longer interleaved.],
  [Framework performance], [DOM manipulation can be centralized and optimized by the framework implementation.],
)

#blockquote[
  *Mental model*\
  Treat the virtual DOM like an architectural blueprint. A blueprint specifies the structure to build without containing the step-by-step construction procedure. In the same way, a virtual tree specifies the view without directly calling the Document API.
]

== The Virtual DOM

=== Definition

#blockquote[
  *Virtual DOM.*\
  A JavaScript-based, in-memory tree of lightweight virtual nodes that represents the structure and relevant properties of the browser DOM.
]

The real DOM is maintained by the browser engine. Its nodes are feature-rich objects with many properties and methods. A virtual node contains only the data the framework needs to create and later update the corresponding view.

A useful virtual representation must preserve:

- the type of each node;
- the HTML tag for element nodes;
- attributes and event handlers;
- parent-child hierarchy;
- the order of siblings;
- text content.

Without hierarchy and relative position, the framework could not reconstruct the intended HTML unambiguously.

=== Example: HTML to Virtual DOM

The following HTML describes a login form:

```html
<form action="/login" class="login-form">
  <input type="text" name="user" />
  <input type="password" name="pass" />
  <button>Log in</button>
</form>
```

A corresponding virtual DOM can be represented with plain objects:

#pagebreak()
```js
{
  type: 'element',
  tag: 'form',
  props: { action: '/login', class: 'login-form' },
  children: [
    {
      type: 'element',
      tag: 'input',
      props: { type: 'text', name: 'user' },
      children: []
    },
    {
      type: 'element',
      tag: 'input',
      props: { type: 'password', name: 'pass' },
      children: []
    },
    {
      type: 'element',
      tag: 'button',
      props: { on: { click: () => login() } },
      children: [
        { type: 'text', value: 'Log in' }
      ]
    }
  ]
}
```

Figure 3.3 presents the same structure as a tree: the `form` is the root, the two inputs and the button are ordered children, and the button owns a text child. This tree view is important because later algorithms operate on structure, not on an HTML string.

=== Virtual DOM Is a Data Model, Not the DOM

The virtual DOM does not render anything by itself. It is a description consumed by later framework code.

#table(
  columns: 2,
  [*Virtual node*], [*Browser node*],
  [Plain JavaScript object], [Object managed by the browser engine],
  [Cheap to create and inspect], [Feature-rich and comparatively heavy],
  [Contains rendering data], [Participates in layout, paint, events, and browser APIs],
  [No visual output by itself], [Represents content in the document],
)

#blockquote[
  *Important distinction*\
  The chapter introduces the virtual DOM as a declarative representation. It does not claim that every framework must use one. The book chooses this architecture because it exposes the mechanics that later support mounting and reconciliation.
]

== Virtual Node Types

The runtime defines three node categories:

```js
export const DOM_TYPES = {
  TEXT: 'text',
  ELEMENT: 'element',
  FRAGMENT: 'fragment',
}
```

Using named constants reduces repeated string literals and makes type-based dispatch less error-prone in later framework code.

#table(
  columns: 3,
  [*Type*], [*Required data*], [*Purpose*],
  [`text`], [`value`], [Represents textual content. It has no tag, attributes, or child nodes.],
  [`element`], [`tag`, `props`, `children`], [Represents a regular HTML element and its ordered subtree.],
  [`fragment`], [`children`], [Groups multiple virtual nodes without adding a semantic wrapper element.],
)

=== Element Nodes

An element virtual node records:

- `tag`: the HTML tag name;
- `props`: attributes and event listeners;
- `children`: an ordered list of child virtual nodes;
- `type`: `DOM_TYPES.ELEMENT`.

The factory is named `h()`, short for *hyperscript*:

```js
export function h(tag, props = {}, children = []) {
  return {
    tag,
    props,
    children: mapTextNodes(withoutNulls(children)),
    type: DOM_TYPES.ELEMENT,
  }
}
```

Default values make `h('div')` equivalent to `h('div', {}, [])`.

=== Text Nodes

Text nodes contain only a type and a value:

```js
export function hString(str) {
  return {
    type: DOM_TYPES.TEXT,
    value: str,
  }
}
```

This explicit representation gives the renderer a uniform node model. Later, mounting code can dispatch on `vdom.type` instead of handling raw strings throughout the runtime.

=== Fragment Nodes

A fragment is a virtual grouping node:

```js
export function hFragment(vNodes) {
  return {
    type: DOM_TYPES.FRAGMENT,
    children: mapTextNodes(withoutNulls(vNodes)),
  }
}
```

A fragment does not correspond to a visible wrapper element. It exists so that a component can return multiple siblings while preserving the tree invariant that a returned subtree has one root virtual node.

#blockquote[
  *Fragment vs. DocumentFragment*\
  The chapter mentions the browser's `DocumentFragment`, but the virtual fragment introduced here is a framework data structure. At this stage it is simply an object with a `children` array; it is not a browser `DocumentFragment` instance.
]

== Child Normalization

The node factories normalize their children at creation time. This keeps later mounting and reconciliation code simpler because it receives a consistent tree.

=== Removing Nullish Children

Conditional rendering can produce `null`:

```js
h('div', {}, [
  h('input', { type: 'text' }),
  value.length > 2
    ? h('button', {}, ['Add'])
    : null,
])
```

A null child means that no node should be rendered. The utility removes both `null` and `undefined`:

```js
export function withoutNulls(arr) {
  return arr.filter((item) => item != null)
}
```

The loose comparison is deliberate here: `item != null` is false for both `null` and `undefined`, while preserving other falsy values.

#blockquote[
  *Common mistake*\
  Do not replace this check with a generic truthiness filter such as `filter(Boolean)` unless the framework intentionally wants to discard every falsy child. A generic truthiness filter would also remove values such as `0` and the empty string.
]

=== Mapping Strings to Text Nodes

Writing every textual child as `hString(...)` would be repetitive. The runtime therefore maps string children automatically:

```js
function mapTextNodes(children) {
  return children.map((child) =>
    typeof child === 'string' ? hString(child) : child
  )
}
```

This allows the concise form:

```js
h('div', {}, ['Hello ', 'world!'])
```

instead of:

```js
h('div', {}, [
  hString('Hello '),
  hString('world!'),
])
```

=== Normalization Pipeline

For element and fragment nodes, child processing follows this order:

#blockquote()[
  Raw child values -> remove `null` / `undefined` -> convert strings to text nodes -> store normalized children
]

This is a small example of a broader framework design principle: normalize flexible user input at the boundary, then keep the internal representation strict.

== Constructing a Virtual Tree

With the factories, the login form becomes:

```js
h('form', { class: 'login-form', action: 'login' }, [
  h('input', { type: 'text', name: 'user' }),
  h('input', { type: 'password', name: 'pass' }),
  h('button', { on: { click: login } }, ['Log in']),
])
```

This form is more concise than manually assembling nested objects, while still exposing the structure directly. JSX and template compilers provide friendlier authoring syntax in production frameworks, but they ultimately need a representation that the runtime can process.

=== What the Tree Encodes

The example stores all information necessary for later rendering:

- `form` is the root;
- `input`, `input`, and `button` are ordered siblings;
- each input has different properties;
- the button has a click handler in `props.on`;
- the button owns the text `Log in`.

Event listeners do not appear as HTML text. They will be attached programmatically when the virtual node is mounted.

== Components as Pure View Functions

=== First Definition of a Component

In this chapter's first framework version, a component is a pure function that:

- receives application state or part of it as input;
- produces no side effects;
- returns a virtual DOM subtree;
- returns the same result for the same input.

Later chapters extend components with local state and lifecycle behavior. For Chapter 3, however, keeping components pure makes the state-to-view relationship explicit.

#blockquote[
  *Props.*\
  The data passed into a component from outside. In this first version, props may be the whole application state or only the subset needed by that component.
]

=== The View as a Function of State

The central relation is:

#blockquote[
  view = f(state)
]

When state changes, the framework reevaluates the view function to create a new virtual tree. Figure 3.5 illustrates this with the TODO list: adding `Water the plants` to state adds a corresponding virtual `li`, which should eventually produce a new DOM element.

A simple component can express this mapping:

```js
function TodosList(todos) {
  return h(
    'ul',
    {},
    todos.map((todo) => h('li', {}, [todo]))
  )
}
```

Calling:

```js
TodosList(['Walk the dog', 'Water the plants'])
```

produces a virtual `ul` with two ordered `li` children. The framework later turns that description into real DOM.

#blockquote[
  *Why purity helps*\
  A pure component is easy to reevaluate, inspect, and test. It does not manually mutate the document. It only calculates a description from its input.
]

== Composing Views

=== Decomposition

A large view function becomes difficult to understand. Pure functions can be composed, so the application view can be divided into smaller components.

The TODO application can first be separated into:

- `CreateTodo(state)`: the form for creating a TODO;
- `TodoList(state)`: the list of existing TODO items.

The top-level component composes them:

```js
function App(state) {
  return hFragment([
    h('h1', {}, ['My TODOs']),
    CreateTodo(state),
    TodoList(state),
  ])
}
```

The fragment is required because `App()` produces multiple siblings and has no semantic wrapper element.

=== Nested Composition

`TodoList()` can map state into repeated `TodoItem()` components:

#pagebreak()
```js
function TodoList(state) {
  return h(
    'ul',
    {},
    state.todos.map((todo, index) =>
      TodoItem(todo, index, state.editingIdxs)
    )
  )
}
```

A TODO item can choose a different subtree according to state:

```js
function TodoItem(todo, index, editingIdxs) {
  const isEditing = editingIdxs.has(index)

  return h('li', {}, [
    isEditing
      ? TodoInEditMode(todo, index)
      : TodoInReadMode(todo, index),
  ])
}
```

This illustrates three useful operations:

- *mapping*: an array of state values becomes a list of child components;
- *conditional rendering*: state selects one of two subtrees;
- *composition*: parent components assemble child results into a larger virtual tree.

=== Component Hierarchy

Figure 3.9 visualizes the resulting hierarchy:

```text
App(state)
└── Fragment
    ├── <h1>
    │   └── "My TODOs"
    ├── CreateTodo(state)
    └── TodoList(state)
        └── <ul>
            ├── TodoItem(...)
            │   └── TodoInEditMode(...) OR TodoInReadMode(...)
            ├── TodoItem(...)
            └── ...
```

The diagram highlights several rules:

- component names use PascalCase;
- props flow into components from outside;
- a dynamic array creates a dynamic list of child components;
- a component returns one root virtual node;
- a fragment supplies that root when no real wrapper element is desired.

== Runtime Files Produced in Chapter 3

The relevant source layout is:

```text
runtime/
└── src/
    ├── utils/
    │   └── arrays.js
    ├── h.js
    └── index.js
```

A compact implementation is:

```js
// utils/arrays.js
export function withoutNulls(arr) {
  return arr.filter((item) => item != null)
}
```

```js
// h.js
import { withoutNulls } from './utils/arrays'

export const DOM_TYPES = {
  TEXT: 'text',
  ELEMENT: 'element',
  FRAGMENT: 'fragment',
}

export function h(tag, props = {}, children = []) {
  return {
    tag,
    props,
    children: mapTextNodes(withoutNulls(children)),
    type: DOM_TYPES.ELEMENT,
  }
}

export function hString(str) {
  return {
    type: DOM_TYPES.TEXT,
    value: str,
  }
}

export function hFragment(vNodes) {
  return {
    type: DOM_TYPES.FRAGMENT,
    children: mapTextNodes(withoutNulls(vNodes)),
  }
}

function mapTextNodes(children) {
  return children.map((child) =>
    typeof child === 'string' ? hString(child) : child
  )
}
```