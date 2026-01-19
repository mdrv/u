import { describe, it, expect, vi } from "vitest";
import { render } from "@testing-library/svelte";

const mockHighlighter = {
  loadLanguage: async () => Promise.resolve(),
  codeToHtml: async (code) => {
    const html = `<pre class="shiki github-dark" style="background-color:#24292e;color:#e1e4e8" tabindex="0"><code><span class="line"><span>${code.substring(0, 50)}</span></span></pre>`;
    console.log("[Test] HTML generated, length:", html.length);
    return html;
  },
};

describe("CodeViewer Shiki Rendering", () => {
  it("should render Shiki highlighted code", async () => {
    const file = {
      name: "test.conf",
      content: "# Test\nCode here",
      category: "test",
      language: "txt",
      isAnnotated: true,
      annotations: [
        {
          id: "ann-1",
          line: 8,
          explanation: "Test annotation",
        },
      ],
    };

    vi.stub("./lib/utils/syntaxHighlighter.js", () => mockHighlighter);

    const { container } = render("./lib/components/CodeViewer.svelte", {
      props: { file },
    });

    document.body.appendChild(container);
    console.log("[Test] Container rendered");

    await new Promise((resolve) => setTimeout(resolve, 500));

    console.log("[Test] After delay, Container HTML:", container.innerHTML);

    expect(container.innerHTML).toContain("shiki github-dark");
    expect(container.innerHTML).toContain("MOCKED SHIKI OUTPUT");

    const pre = container.querySelector("pre");
    expect(pre).toBeTruthy();

    expect(pre.textContent).toContain("# Test");

    document.body.removeChild(container);
  });

  it("should render file metadata", () => {
    const file = {
      name: "hyprland.conf",
      content: "# Test\nCode here",
      category: "compositor",
      language: "conf",
      isAnnotated: true,
    };

    vi.stub("./lib/utils/syntaxHighlighter.js", () => mockHighlighter);

    const { container } = render("./lib/components/CodeViewer.svelte", {
      props: { file },
    });

    document.body.appendChild(container);

    expect(container.innerHTML).toContain("hyprland.conf");
    expect(container.innerHTML).toContain("compositor");
    expect(container.innerHTML).toContain("conf");
    expect(container.innerHTML).contains("Annotated");

    document.body.removeChild(container);
  });

  it("should show annotated badge for annotated files", () => {
    const file = {
      name: "annotated.nu",
      content: "# Test",
      category: "test",
      language: "nu",
      isAnnotated: true,
    };

    vi.stub("./lib/utils/syntaxHighlighter.js", () => mockHighlighter);

    const { container } = render("./lib/components/CodeViewer.svelte", {
      props: { file },
    });

    document.body.appendChild(container);

    expect(container.innerHTML).toContain("Annotated");

    document.body.removeChild(container);
  });

  it("should NOT show annotated badge for non-annotated files", () => {
    const file = {
      name: "plain.nu",
      content: "# Test",
      category: "test",
      language: "nu",
      isAnnotated: false,
    };

    vi.stub("./lib/utils/syntaxHighlighter.js", () => mockHighlighter);

    const { container } = render("./lib/components/CodeViewer.svelte", {
      props: { file },
    });

    document.body.appendChild(container);

    expect(container.innerHTML).not.toContain("Annotated");

    document.body.removeChild(container);
  });
});
