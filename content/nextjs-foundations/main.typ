#import "/common/reading-note.typ": reading-note
#import "@preview/cetz:0.5.2": canvas, draw, tree

#set text(lang: "en")

#show: reading-note.with(
  title: [Course Notes on\ Next.js Foundations],
  authors: "Qiyang Wang",
  preface: [
    = Preface

    These course notes document my progress through
    #link("https://vercel.com/academy/nextjs-foundations")[_Next.js Foundations_],
    a self-paced, hands-on workshop from Vercel Academy by Joel Hooks. The
    course develops production-oriented Next.js practices by incrementally
    building and deploying two applications in a Turborepo monorepo.

    My aim is to capture the underlying mental models, trade-offs, and
    reusable patterns rather than reproduce each lesson. In particular, the
    notes emphasize the App Router, Server and Client Component boundaries,
    routing, data flow, performance, security, and deployment.

    This is an independent set of course notes and is not affiliated with or
    endorsed by Joel Hooks or Vercel. Because both the course and Next.js
    continue to evolve, consult the original lessons and official
    documentation for the most current guidance.

    Copyright in quoted passages, figures, code, and other attributed material
    remains with the respective rights holders. Unless otherwise credited,
    the commentary, explanations, organization, and examples are © 2026
    Qiyang Wang. All rights reserved. Any errors or misinterpretations are my
    own.
  ],
  bibliography: bibliography("refs.bib"),
)

#include "chapters/01-app-router-basics.typ"
#include "chapters/02-server-and-client-components.typ"
#include "chapters/03-dynamic-routing.typ"
#include "chapters/04-env-and-security.typ"
