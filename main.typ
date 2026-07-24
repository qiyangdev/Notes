#import "@preview/ilm:2.1.1": *
#import "@preview/cetz:0.5.2": canvas, draw, tree

#set text(lang: "en")

#show: ilm.with(
  title: [Reading Notes on\ Professional JavaScript® for Web Developers],
  authors: "Qiyang Wang",
  preface: [
    = Preface
    
    This document is an independent collection of personal reading notes
    on _Professional JavaScript for Web Developers, 5th Edition_ @frisbie2023,
    written by Matt Frisbie and published by Wiley.
    
    These notes are not an authorized reproduction, translation, or
    substitute for the original book. They are not affiliated with or
    endorsed by the author, the publisher, or Oracle.
    
    Copyright in the original book, quoted passages, figures, and other
    third-party material remains with the respective copyright holders.
    Limited excerpts are included only where necessary for commentary,
    criticism, study, and research, with their sources identified wherever
    practicable. Readers should consult and purchase the original book for
    the complete material.
    
    Except for material attributed to third parties, the original
    commentary, explanations, organization, and examples in these notes
    are © 2026 Qiyang Wang. All rights reserved.
    
    JavaScript® is a trademark or registered trademark of Oracle and/or
    its affiliates in the United States and other countries. All other
    trademarks belong to their respective owners.
    
    Any errors or interpretations in these notes are solely those of the
    note author.
  ],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

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
