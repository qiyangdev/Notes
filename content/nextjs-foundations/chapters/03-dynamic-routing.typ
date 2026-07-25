= Dynamic Routing

The `[slug]/page.tsx` pattern matches any value in that URL segment and exposes it through the route parameters.

In Next.js 16, `params` and `searchParams` are asynchronous and are exposed as `Promise` objects.

== Prerendering

The dynamic route are dynamic but can prerender with `generateStaticParams()` when at build time.

== Dynamic Route Patterns

Next.js has three dynamic segment patterns:

+ `[slug]`: Exactly match one path part.
+ `[...slug]`: Requires at least one segment.
+ `[[...slug]]`: Matches zero or more segments.
