#import "/common/reading-note.typ": reading-note
#import "@preview/cetz:0.5.2": canvas, draw, tree

#set text(lang: "en")

#show: reading-note.with(
  title: [Reading Notes on\ The Algorithm Design Manual],
  authors: "Qiyang Wang",
  preface: [
    = Preface

    These notes accompany my study of Steven S. Skiena's
    _The Algorithm Design Manual, 3rd Edition_ @skiena2020algorithm,
    published by Springer. They distill the ideas I found most useful,
    record my own explanations, and emphasize the habits of reasoning that
    make algorithms easier to design, analyze, and implement.

    This is a selective study companion, not a chapter-by-chapter reproduction
    or a substitute for the book. Readers should consult the original work for
    its complete discussions, examples, exercises, and references.

    These notes are independently written and are not affiliated with or
    endorsed by the author or publisher. Copyright in quoted passages,
    figures, and other attributed material remains with the respective rights
    holders. Unless otherwise credited, the commentary, explanations,
    organization, and examples are © 2026 Qiyang Wang. All rights reserved.

    Any errors or misinterpretations are my own.
  ],
  bibliography: bibliography("refs.bib"),
)

#include "chapters/01-introduction-to-algorithm-design.typ"
