---
import Layout from "../layouts/Layout.astro";
---

<Layout title="${site_title}" description="${site_description}">
  <main>
    <h1>${site_title}</h1>
    <p>${site_description}</p>
  </main>
</Layout>

<style>
  main {
    margin: auto;
    padding: 2rem;
    max-width: 60ch;
    text-align: center;
    min-height: 80vh;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }
  h1 {
    font-size: 2.5rem;
    font-weight: 700;
    line-height: 1.2;
    margin-bottom: 1rem;
    background: linear-gradient(135deg, #38bdf8, #818cf8);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }
  p {
    font-size: 1.125rem;
    color: #94a3b8;
  }
</style>
