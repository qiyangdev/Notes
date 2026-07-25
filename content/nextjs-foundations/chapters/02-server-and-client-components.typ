= Server and Client Components

In the App Router, components are Server Components by default unless they are marked with the `"use client"` directive.

Use the `"use client"` directive only when you need interactivity, browser APIs, or React client-side features such as state and effects.

== How Directive Works

The `"use client"` directive defines a boundary between the server and client module graphs. Once it is added to a file, that file and all of its imported dependencies become part of the client bundle and are executed in the browser.

Because every module within this boundary contributes to the client bundle, client boundaries should be kept as small as possible.

The child components of a client component will automatically client-side.

== Environment Variables

Environment variables prefixed with `NEXT_PUBLIC_` are inlined into the client-side JavaScript bundle at build time. As a result, their values are exposed to the browser and cannot change after the application has been built.

== Composition Pattern

You can pass Server Components to Client Components as props, such as through the `children` prop. This allows parts of the UI to remain server-rendered while being composed inside a Client Component.
