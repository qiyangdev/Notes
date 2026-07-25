= App Router Basics

The App Router uses the file-system hierarchy to define the routing structure. Each folder defines a route segment, which becomes part of the URL.

A route segment becomes publicly accessible only when it contains a `page.tsx` file. Without one, the segment can still be used to organize nested routes, layouts, and other files.

== Some Special files

Next.js define some file for sepcial usage:

- `page.tsx`: Renders the page content and makes the route publicly accessible.
- `layout.tsx`: Wraps pages with shared UI that persists across route navigation.
- `loading.tsx`: Displays fallback UI, such as a loading skeleton, while a route segment is loading.
- `error.tsx`: Catches runtime errors within a route segment and displays an error UI with a retry option.
- `not-found.tsx`: Displays a not-found UI when a resource cannot be found.
- `route.ts`: Defines an API endpoint and returns responses such as JSON.

`page.tsx` and `loading.tsx` are usually placed in the same route segment folder.

`error.tsx` usually is cilent component.

`not-found.tsx` usually placed at root.

== Metadata API

A web page needs a `title` and `description` for SEO. Next.js provides the Metadata API for defining this information and automatically generates the corresponding elements in the document’s `<head>`.

There are two ways to define metadata:

+ Static metadata: Use this for pages with fixed metadata by exporting a `metadata` object.
+ Dynamic metadata: Use this for pages whose metadata depends on route parameters, fetched data, or other dynamic values by exporting a `generateMetadata` function.

#figure(caption: "Export a metadata object")[
  ```ts
  import type { Metadata } from 'next'
  
  export const metadata: Metadata = {
    title: 'About Us',
    description: 'Learn about our mission and team',
  }
  
  export default function AboutPage() {
    return <div>About content</div>
  }
  
  // <title>About Us</title>
  // <meta name="description" content="Learn about our mission and team" />
  ```
]

#figure(caption: "Use generateMetadata")[
  ```ts
  import type { Metadata } from 'next'
   
  export async function generateMetadata({ 
    params 
  }: { 
    params: Promise<{ slug: string }> 
  }): Promise<Metadata> {
    const { slug } = await params
    const product = await fetchProduct(slug)
    
    return {
      title: product.name,
      description: product.description,
    }
  }
  ```
]

Metadata is inherited from parent route segments. Metadata defined in a child segment can override or extend the metadata inherited from its parent.

The Metadata API supports template syntax for dynamic data.

#figure(caption: "Sets title.template with %s")[
  ```ts
  export const metadata: Metadata = {
    title: {
      template: '%s | Next.js Foundations',
      default: 'Next.js Foundations',
    },
  };

  export const metadata: Metadata = {
    title: 'About Us', // Becomes "About Us | Next.js Foundations"
  };
  ```
]