#import "/common/reading-note.typ": reading-note
#import "@preview/cetz:0.5.2": canvas, draw, tree

#set text(lang: "en")

#show: reading-note.with(
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
)

#include "chapters/01-what-is-javascript.typ"