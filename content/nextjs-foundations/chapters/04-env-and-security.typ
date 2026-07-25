= Environment and Security

Next.js provides multiple safeguards to prevent private environment variables from being exposed to the client.

== Precedence

Next.js loads environment variables in a specific order. The first matching value found is used.

+ `process.env`
+ `.env.$(NODE_ENV).local`
+ `.env.local`
+ `.env.$(NODE_ENV)`
+ `.env`

== The `NEXT_PUBLIC_`

Variables prefixed with `NEXT_PUBLIC_` are inlined into the JavaScript bundle at build time.

== Defense in depth

=== Build-time protection

The `server-only` package helps enforce the server boundary by throwing an error when server-only code is imported into a Client Component.


=== DTOs

Use DTOs (Data Transfer Objects) to control the data exposed to Client Components and ensure data safety.

=== Environment variable hygiene

- Never use `NEXT_PUBLIC_` for secrets.
- Use `.env.local` for local secrets.
- Use `.env.example` to document.
