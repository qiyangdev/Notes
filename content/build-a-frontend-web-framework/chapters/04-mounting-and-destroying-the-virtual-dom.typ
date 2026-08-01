#import "@preview/ilm:2.1.1": blockquote
#import "/common/reading-note.typ": pseudocode-list

= Mounting and Destroying the Virtual DOM

== Mounting as a Tree Transformation

=== Definition

#blockquote[
  *Mounting.*\
  The process of creating real DOM nodes from virtual nodes and attaching them to a parent in the browser document.
]

`mountDOM()` receives two values:

- `vdom`: the virtual node or virtual subtree to mount;
- `parentEl`: the real DOM element that will own the mounted output.

Figure 4.1 presents the operation as a transformation from a virtual tree plus a parent element into a real tree attached beneath that parent.

#blockquote[
  #text(weight: "bold")[Virtual node tree]
  #h(8pt) + #h(8pt)
  #text(weight: "bold")[Parent DOM element]
  #h(8pt) -> #h(8pt)
  #text(weight: "bold")[Mounted DOM subtree]
]

=== Prefer a Dedicated Host Element

The chapter often mounts examples directly into `document.body`, but warns against using the body as the application root in real projects. Third-party code may also add body children. A reconciliation algorithm that assumes ownership of every body child can then make incorrect decisions.

A safer application shell is:

```html
<body>
  <div id="app"></div>
</body>
```

```js
const host = document.getElementById('app')
mountDOM(vdom, host)
```

#blockquote[
  *Ownership rule*\
  A renderer should mutate only the DOM region it owns. The host element forms an explicit ownership boundary between the framework and the rest of the page.
]

== Runtime References Stored on Virtual Nodes

Mounting does more than create visible HTML. It enriches the virtual tree with references to runtime resources.

=== The `el` Reference

Every mounted virtual node receives an `el` property.

For text and element nodes, `el` points to the corresponding real DOM node:

```js
vdom.el = textNode
```

or

```js
vdom.el = element
```

Figures 4.2 and 4.4 show the virtual tree connected to its real DOM counterparts through these references.

The reference serves two future responsibilities:

- destruction can find and remove the node without searching the document;
- reconciliation can find the exact DOM node that corresponds to a virtual node.

=== The `listeners` Reference

Element virtual nodes may also receive a `listeners` property. It maps event names to the handler functions that were actually registered:

```js
vdom.listeners = {
  click: registeredClickHandler,
  mouseover: registeredMouseoverHandler,
}
```

Figure 4.3 emphasizes that an element virtual node records both its DOM node and its listeners.

The browser requires the same handler reference when removing a listener:

```js
el.removeEventListener('click', registeredClickHandler)
```

Creating a new function with equivalent source code is insufficient because it is a different function object.

=== Mounted-State Invariant

The chapter uses a simple convention:

```text
vdom has an el property     -> the node is mounted
vdom has no el property     -> the node is not mounted
```

This is not a formal browser rule. It is an invariant designed by the framework.

#blockquote[
  *Design significance*\
  The virtual tree becomes a runtime data structure after mounting. Before mounting it describes the desired view. After mounting it also carries links to the resources that realize that view.
]

== Type-Based Dispatch

The same three node types introduced in Chapter 3 require three different mounting strategies.

```js
import { DOM_TYPES } from './h'

export function mountDOM(vdom, parentEl) {
  switch (vdom.type) {
    case DOM_TYPES.TEXT: {
      createTextNode(vdom, parentEl)
      break
    }
    case DOM_TYPES.ELEMENT: {
      createElementNode(vdom, parentEl)
      break
    }
    case DOM_TYPES.FRAGMENT: {
      createFragmentNodes(vdom, parentEl)
      break
    }
    default: {
      throw new Error(`Can't mount DOM of type: ${vdom.type}`)
    }
  }
}
```

=== Why a Dispatcher Is Useful

`mountDOM()` owns the common entry point, while specialized functions own node-specific behavior.

#table(
  columns: 3,
  [*Virtual type*], [*Mounting function*], [*Primary operation*],
  [`text`], [`createTextNode()`], [Create one browser `Text` node and append it.],
  [`element`],
  [`createElementNode()`],
  [Create an `HTMLElement`, configure it, recursively mount its children, and append it.],

  [`fragment`],
  [`createFragmentNodes()`],
  [Mount each child into the same parent because the fragment has no real DOM node.],
)

The default branch fails loudly. A misspelled or unsupported type should not silently produce a partially mounted tree.

=== Recursive Structure

The dispatcher is recursive because both element and fragment nodes contain children:

#pagebreak()
#pseudocode-list[
  + mount element
    + create real element
    + *for* each child
      + *mount* child into element
    + *append* element to parent
]

#pseudocode-list[
  + *mount* fragment
    + *for* each child
      + *mount* child into fragment's parent
]

The tree structure of the virtual DOM directly determines the recursive call structure.

== Mounting Text Nodes

Text nodes are the simplest case. They have no attributes, classes, styles, event listeners, or children.

```js
function createTextNode(vdom, parentEl) {
  const { value } = vdom
  const textNode = document.createTextNode(value)
  vdom.el = textNode
  parentEl.append(textNode)
}
```

== Operation Sequence

+ Read the virtual node's `value`.
+ Create a real browser text node.
+ Save the real node in `vdom.el`.
+ Append the text node to the supplied parent.

#table(
  columns: 2,
  [*Virtual representation*], [*Real DOM operation*],
  [`{ type: TEXT, value: "Hello" }`], [`document.createTextNode("Hello")`],
  [`vdom.el`], [Reference to the created `Text` object],
  [`parentEl`], [Receives the node through `append()`],
)

=== Why Not Use `innerHTML`?

The chapter builds the tree with node-level Document API operations. This preserves explicit node identity and gives the runtime direct references to each created object. Those references are needed by destruction and reconciliation.

#blockquote[
  *Practical interpretation*\
  The framework does not merely generate equivalent markup. It constructs a graph of real node objects whose identity is linked to the virtual tree.
]

== Mounting Fragment Nodes

=== A Fragment Has No Corresponding Element

A virtual fragment groups siblings but is not itself mounted as an HTML element. The runtime mounts every child directly into the supplied parent.

```js
function createFragmentNodes(vdom, parentEl) {
  const { children } = vdom
  vdom.el = parentEl
  children.forEach((child) => mountDOM(child, parentEl))
}
```

For a fragment, `vdom.el` does *not* point to a node created for the fragment. It points to the parent that owns the fragment's children.

Figure 4.5 visualizes this distinction: the fragment's heading and paragraph children are inserted into the body, while the fragment records the body as its `el` reference.

=== Nested Fragments

Nested fragments flatten into the same parent DOM level:

```text
Fragment A
├── <h1>
└── Fragment B
    ├── <p>
    └── Fragment C
        └── <a>
```

If the root fragment is mounted into `host`, all three fragment `el` properties point to `host`. Figure 4.6 shows this shared-parent relationship.

#blockquote[
  *Critical fragment invariant*\
  A fragment owns its children but does not own the parent element referenced by `vdom.el`.
]

That invariant becomes essential during destruction. Removing the fragment's `el` would remove a parent that may belong to the application shell or another system.

== Virtual Fragment vs. `DocumentFragment`

The browser provides a real `DocumentFragment` class, but this chapter's implementation does not create one. The virtual fragment is only a runtime grouping abstraction.

#table(
  columns: 3,
  [*Concept*], [*Representation*], [*Behavior in this chapter*],
  [Virtual fragment], [Plain virtual-node object], [Recursively mounts children into an existing parent.],
  [`DocumentFragment`], [Browser DOM object], [Mentioned for context but not used by the implementation.],
)

== Mounting Element Nodes

Element nodes are the central case because they combine tag creation, properties, events, descendants, and parent attachment.

A typical element virtual node is:

```js
{
  type: DOM_TYPES.ELEMENT,
  tag: 'button',
  props: {
    class: 'btn',
    on: {
      click: () => console.log('clicked'),
    },
  },
  children: [
    { type: DOM_TYPES.TEXT, value: 'Click me' },
  ],
}
```

=== Complete Mounting Sequence

The chapter describes five steps:

+ Create the browser element with `document.createElement(tag)`.
+ Apply attributes and register event listeners.
+ Save the browser element in `vdom.el`.
+ Recursively mount the children into the new element.
+ Append the completed element to its parent.

```js
import { setAttributes } from './attributes'
import { addEventListeners } from './events'

function createElementNode(vdom, parentEl) {
  const { tag, props, children } = vdom
  const element = document.createElement(tag)

  addProps(element, props, vdom)
  vdom.el = element

  children.forEach((child) => mountDOM(child, element))
  parentEl.append(element)
}

function addProps(el, props, vdom) {
  const { on: events, ...attrs } = props
  vdom.listeners = addEventListeners(events, el)
  setAttributes(el, attrs)
}
```

=== Why Children Are Mounted Before the Element Is Appended

The function constructs the entire element subtree while the new element is detached, then appends the root element once. The chapter presents this ordering as part of the mounting algorithm:

```text
create element
  -> configure element
  -> record reference
  -> recursively create descendants
  -> append completed element
```

The important invariant is that after `createElementNode()` returns, the virtual subtree and real subtree correspond structurally.

=== Unknown Tags

`document.createElement()` returns an `HTMLUnknownElement` for an unrecognized tag. The chapter treats that result as an application developer error and does not add special validation.

== Event Listener Management

=== Register One Listener

The lowest-level wrapper registers a handler and returns the registered function:

```js
export function addEventListener(eventName, handler, el) {
  el.addEventListener(eventName, handler)
  return handler
}
```

Returning the function looks redundant in Chapter 4, but it creates an abstraction point. Later framework versions may wrap or bind the original handler and therefore register a different function object.

=== Register an Event Map

Virtual-node events are represented as an object:

```js
{
  mouseover: onMouseover,
  click: onClick,
  dblclick: onDoubleClick,
}
```

`addEventListeners()` registers each entry and returns a new map of the actual listeners:

```js
export function addEventListeners(listeners = {}, el) {
  const addedListeners = {}

  Object.entries(listeners).forEach(([eventName, handler]) => {
    const listener = addEventListener(eventName, handler, el)
    addedListeners[eventName] = listener
  })

  return addedListeners
}
```

=== Why Return a New Map?

At this point, the input handlers and registered handlers are identical. It might seem sufficient to return the input object. The chapter intentionally avoids that shortcut because later versions can transform handlers before registration.

#blockquote[
  *Abstraction lesson*
  A small wrapper is justified when it defines a stable boundary for behavior that will become more complex. The Chapter 4 event module is designed for future extension, not merely for the current three-line implementation.
]

=== Text Nodes and Events

Although a browser `Text` node inherits from `EventTarget`, the chapter notes that listeners attached directly to text nodes are not useful in practice. Events and attributes are therefore associated with element nodes, not text nodes.

== Applying Attributes and Properties

The `props` object mixes several categories:

- event listeners under `on`;
- classes under `class`;
- inline styles under `style`;
- regular element properties and attributes;
- `data-*` attributes.

`addProps()` separates events from the remaining attributes. `setAttributes()` then separates `class` and `style` from ordinary entries.

```js
export function setAttributes(el, attrs) {
  const { class: className, style, ...otherAttrs } = attrs

  if (className) {
    setClass(el, className)
  }

  if (style) {
    Object.entries(style).forEach(([prop, value]) => {
      setStyle(el, prop, value)
    })
  }

  for (const [name, value] of Object.entries(otherAttrs)) {
    setAttribute(el, name, value)
  }
}
```

=== DOM Properties and Rendered Attributes

The chapter frames DOM manipulation in terms of JavaScript objects. An `HTMLElement` instance exposes properties that commonly correspond to rendered HTML attributes:

```js
paragraph.id = 'article-intro'
```

The browser reflects that value in markup:

```html
<p id="article-intro"></p>
```

This correspondence is useful but not universal.

=== The Input `value` Caveat

The `value` property of an input represents its current runtime value. It is not necessarily reflected as an updated `value` attribute in the serialized HTML.

```js
input.value = 'edited text'
```

The visible control changes, but inspecting the markup may not show a matching updated attribute. The chapter uses this as a warning that DOM properties and HTML attributes are related but not identical concepts.

#table(
  columns: 2,
  [*Concept*], [*Meaning*],
  [HTML attribute], [Value represented in markup, often used as an initial/default value.],
  [DOM property], [Current value stored on a live browser object.],
)

== Class Handling

An element does not expose a `class` property. The relevant APIs are `className` and `classList`.

The framework accepts either a string or an array:

```js
h('div', { class: 'panel selected' })
```

```js
h('div', { class: ['panel', 'selected'] })
```

The implementation clears existing classes before applying the new form:

```js
function setClass(el, className) {
  el.className = ''

  if (typeof className === 'string') {
    el.className = className
  }

  if (Array.isArray(className)) {
    el.classList.add(...className)
  }
}
```

=== Why Clear First?

Clearing `className` ensures that `setClass()` establishes the complete requested class state rather than accumulating stale classes from previous calls.

#blockquote[
  *API design choice*\
  The public virtual-node API accepts a convenient union of string and string array. The renderer normalizes both forms through a single class-setting function.
]

== Style Handling

The live `style` property is a `CSSStyleDeclaration`. JavaScript property names are used to set CSS values:

```js
element.style.color = 'red'
element.style.fontFamily = 'Georgia'
```

The browser serializes them into a style attribute such as:

```html
<p style="color: red; font-family: Georgia;"></p>
```

The chapter implements one function for setting and one for future removal:

```js
export function setStyle(el, name, value) {
  el.style[name] = value
}

export function removeStyle(el, name) {
  el.style[name] = null
}
```

The style object supplied by a virtual node therefore uses JavaScript-style property names:

```js
h('p', {
  style: {
    color: 'red',
    fontFamily: 'Georgia',
  },
}, ['Hello'])
```

`removeStyle()` is not required by the initial mount path, but it anticipates later patching logic.

== Regular Attributes and `data-*`

The remaining entries are passed one at a time to `setAttribute()`:

```js
export function setAttribute(el, name, value) {
  if (value == null) {
    removeAttribute(el, name)
  } else if (name.startsWith('data-')) {
    el.setAttribute(name, value)
  } else {
    el[name] = value
  }
}

export function removeAttribute(el, name) {
  el[name] = null
  el.removeAttribute(name)
}
```

=== Rules

#table(
  columns: 3,
  [*Input case*], [*Operation*], [*Reason in this implementation*],
  [`value == null`], [`removeAttribute()`], [Nullish values mean the property should be removed.],
  [`name` starts with `data-`],
  [`el.setAttribute(name, value)`],
  [Custom data attributes are written through the attribute API.],

  [All other names], [`el[name] = value`], [The live DOM property is assigned directly.],
)

`removeAttribute()` performs both operations:

- set the live property to `null`;
- remove the serialized attribute.

This keeps both sides from retaining a stale value where the APIs permit it.

== End-to-End Mounting Example

Given:

```js
const vdom = h('section', {}, [
  h('h1', {}, ['My Blog']),
  h('p', {}, ['Welcome to my blog!']),
])

mountDOM(vdom, document.body)
```

The mounted document is conceptually:

```html
<body>
  <section>
    <h1>My Blog</h1>
    <p>Welcome to my blog!</p>
  </section>
</body>
```

The virtual tree is also enriched:

```text
<section>.el -----------------> HTMLSectionElement
├── <h1>.el -----------------> HTMLHeadingElement
│   └── Text.el -------------> Text("My Blog")
└── <p>.el ------------------> HTMLParagraphElement
    └── Text.el -------------> Text("Welcome to my blog!")
```

This correspondence is the major output of the chapter: real structure plus a direct mapping from every virtual node to the resource that realizes it.

== Destroying the DOM

=== Definition

#blockquote[
  *Destroying.*
  The process of removing the DOM produced by a mounted virtual node and cleaning the runtime references owned by that virtual node.
]

`destroyDOM()` is the inverse lifecycle operation of `mountDOM()`:

```text
mountDOM:   virtual node -> DOM resources + references
destroyDOM: mounted virtual node -> resources removed + references deleted
```

Figure 4.7 presents a mounted virtual tree entering `destroyDOM()` and an empty host region after destruction.

=== Type-Based Destruction

```js
import { removeEventListeners } from './events'
import { DOM_TYPES } from './h'

export function destroyDOM(vdom) {
  const { type } = vdom

  switch (type) {
    case DOM_TYPES.TEXT: {
      removeTextNode(vdom)
      break
    }
    case DOM_TYPES.ELEMENT: {
      removeElementNode(vdom)
      break
    }
    case DOM_TYPES.FRAGMENT: {
      removeFragmentNodes(vdom)
      break
    }
    default: {
      throw new Error(`Can't destroy DOM of type: ${type}`)
    }
  }

  delete vdom.el
}
```

The final `delete vdom.el` applies to all node types. Element-specific destruction also deletes `vdom.listeners`.

Figure 4.8 illustrates both effects: the visible nodes are removed, and the `el` links disappear from the virtual tree.

== Destroying Text Nodes

A text virtual node owns exactly one real text node:

```js
function removeTextNode(vdom) {
  const { el } = vdom
  el.remove()
}
```

After the specialized function removes the node, `destroyDOM()` deletes `vdom.el`.

The postcondition is:

```text
text DOM node is detached
virtual text node has no el reference
```

== Destroying Element Nodes

An element virtual node owns:

- its real element;
- all DOM resources created for its child virtual nodes;
- the event listeners registered by the framework.

```js
function removeElementNode(vdom) {
  const { el, children, listeners } = vdom

  el.remove()
  children.forEach(destroyDOM)

  if (listeners) {
    removeEventListeners(listeners, el)
    delete vdom.listeners
  }
}
```

=== Cleanup Responsibilities

1. Detach the root element.
2. Recursively destroy every child virtual node so their references are cleared.
3. Remove registered event listeners from the element.
4. Delete the virtual node's listener map.
5. Let the outer `destroyDOM()` delete `vdom.el`.

Even though removing the parent detaches the visible descendant DOM at once, recursive destruction is still necessary because each child virtual node retains its own `el` reference.

#blockquote[
  *Important distinction*\
  Removing a subtree from the document and cleaning the framework's object graph are separate operations. The DOM may already be detached while stale JavaScript references still remain.
]

== Removing Event Listeners

The cleanup function receives the map stored during mounting:

```js
export function removeEventListeners(listeners = {}, el) {
  Object.entries(listeners).forEach(([eventName, handler]) => {
    el.removeEventListener(eventName, handler)
  })
}
```

The mounting and removal APIs are deliberately symmetrical:

#table(
  columns: 2,
  [*Mount*], [*Destroy*],
  [`addEventListener(name, handler)`], [`removeEventListener(name, handler)`],
  [Store returned handlers in `vdom.listeners`], [Read stored handlers from `vdom.listeners`],
  [Create external browser relationship], [Remove external browser relationship],
)

Without the stored function identity, reliable removal would not be possible.

== Destroying Fragment Nodes

A fragment owns its children, not its `el` parent:

```js
function removeFragmentNodes(vdom) {
  const { children } = vdom
  children.forEach(destroyDOM)
}
```

The implementation intentionally does not call:

```js
vdom.el.remove()
```

The referenced `el` may be the application's root container, the document body, or a node created by another system. Figure 4.9 warns that removing it would remove DOM outside the fragment's ownership.

=== Fragment Destruction Rule

#pseudocode-list[
+ Destroy every fragment child.
+ Do not destroy the fragment's parent reference.
+ Delete only the fragment's own el property afterward.
]

#blockquote[
  *Ownership is more important than reachability*\
  A runtime reference tells the framework where nodes are mounted, but it does not automatically imply ownership of the referenced object. Fragment cleanup demonstrates why resource ownership must be modeled explicitly.
]
