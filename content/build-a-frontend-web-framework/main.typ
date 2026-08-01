#import "/common/reading-note.typ": reading-note
#import "@preview/cetz:0.5.2": canvas, draw, tree

#set text(lang: "en")

#show: reading-note.with(
  title: [Reading Notes on\ Build a Frontend Web Framework (From Scratch)],
  authors: "Qiyang Wang",
  preface: [
    = Preface

    These notes accompany my study of Ángel Sola Orbaiceta's
    _Build a Frontend Web Framework (From Scratch)_ @solaorbaiceta2024frontend,
    published by Manning in 2024. They record my own explanations of the
    concepts and implementation techniques involved in building a frontend
    framework from first principles.

    This is a selective study companion, not a chapter-by-chapter reproduction
    or a substitute for the book. Readers should consult the original work for
    its complete discussions, examples, exercises, and source code.

    These notes are independently written and are not affiliated with or
    endorsed by the author or publisher. Copyright in quoted passages,
    figures, code, and other attributed material remains with the respective
    rights holders. Unless otherwise credited, the commentary, explanations,
    organization, and examples are © 2026 Qiyang Wang. All rights reserved.

    Any errors or misinterpretations are my own.
  ],
  bibliography: bibliography("refs.bib"),
)

#include "chapters/01-are-frontend-frameworks-magic-to-you.typ"
#include "chapters/03-rendering-and-the-virtual-dom.typ"
#include "chapters/04-mounting-and-destroying-the-virtual-dom.typ"
