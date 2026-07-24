#import "@preview/cetz:0.5.2": canvas, draw, tree

= What Is JavaScript?

== JavaScript Implementations

The JavaScript is made up of three components:
- ECMAScript
- DOM
- BOM

=== ECMAScript

ECMAScript is the specification for the JavaScript language, and JavaScript is an implementation of that specification.

ECMAScript 2015 (ES6), formally known as the 6th Edition of ECMA-262, was one of the most significant releases of the ECMAScript specification.

ECMAScript conformance specifies the minimum requirements that an implementation must satisfy to conform to the ECMAScript specification.

=== DOM

The DOM (Document Object Model) is an API that represents an HTML or XML document as a hierarchical tree of nodes. Each node contains information about a specific part of the document, allowing JavaScript to access and manipulate the document's structure, content, and styles.

#figure(
  canvas({
    import draw: *
    
    set-style(content: (padding: 0.5em))
    tree.tree(
      (
        "html",
        (
          "head",
          (
            "title",
            (
              "Sample Page"
            ),
          ),
        ),
        (
          "body",
          (
            "p",
            (
              "Hello, World!"
            ),
          ),
        ),
      ),
    )
  }),
  caption: "The hierarchy of node",
)

The DOM standardized how scripts interact with HTML and XML documents, preventing the Web from fragmenting into incompatible implementations.

The DOM Core defines the fundamental interfaces for representing and manipulating XML-based documents, while the HTML DOM extends those interfaces with HTML-specific objects and methods.

=== BOM

The Browser Object Model (BOM) provides APIs that allow developers to interact with the browser environment, including the browser window, navigation history, screen information, and dialogs.

There is no official standard for the BOM because browsers have historically implemented their own properties and methods. However, HTML5 standardized some browser APIs, making browser behavior more consistent across implementations.
