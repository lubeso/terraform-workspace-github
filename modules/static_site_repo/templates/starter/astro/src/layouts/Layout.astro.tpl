---
interface Props {
  title?: string;
  description?: string;
  image?: string;
  type?: string;
}

const {
  title = "${site_title}",
  description = "${site_description}",
  image = "/icon-512.png",
  type = "website",
} = Astro.props;

const canonicalURL = new URL(Astro.url.pathname, Astro.site);
const ogImageURL = new URL(image, Astro.site);
---

<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>{title}</title>
    <meta name="description" content={description} />
    <link rel="canonical" href={canonicalURL} />

    <!-- Favicons -->
    <link rel="icon" href="/favicon.ico" />
    <link rel="icon" type="image/svg+xml" href="/favicon.svg" />
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon.png" />
    <link rel="icon" type="image/png" sizes="192x192" href="/icon-192.png" />
    <link rel="icon" type="image/png" sizes="512x512" href="/icon-512.png" />

    <!-- OpenGraph Metadata -->
    <meta property="og:title" content={title} />
    <meta property="og:description" content={description} />
    <meta property="og:url" content={canonicalURL} />
    <meta property="og:image" content={ogImageURL} />
    <meta property="og:type" content={type} />

    <!-- Twitter Card Metadata -->
    <meta name="twitter:card" content="summary" />
    <meta name="twitter:title" content={title} />
    <meta name="twitter:description" content={description} />
    <meta name="twitter:image" content={ogImageURL} />
  </head>
  <body>
    <slot />
  </body>
</html>

<style is:global>
  :root {
    --font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
      Oxygen, Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
  }
  html {
    font-family: var(--font-family);
    background-color: #0f172a;
    color: #f8fafc;
  }
  body {
    margin: 0;
    padding: 0;
    min-height: 100vh;
  }
</style>
