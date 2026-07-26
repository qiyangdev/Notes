#import "@preview/ilm:2.1.1": *
#import "@preview/lovelace:0.3.1": *

#let reading-note = ilm.with(
  paper-size: "a4",
  chapter-pagebreak: true,
  external-link-circle: true,
  footer: "page-number-alternate-with-chapter",

  raw-text: (
    font: ("Iosevka", "DejaVu Sans Mono"),
    size: 9pt,
  ),

  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)