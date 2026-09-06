'use client';

import { useEffect, useRef, useState } from 'react';

interface MermaidProps {
  chart: string;
}

// Unique ID counter for multiple diagrams on the same page
let idCounter = 0;

export function Mermaid({ chart }: MermaidProps) {
  const id = useRef(`mermaid-${++idCounter}`);
  const containerRef = useRef<HTMLDivElement>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function render() {
      try {
        const mermaid = (await import('mermaid')).default;

        mermaid.initialize({
          startOnLoad: false,
          theme: 'default',
          flowchart: {
            curve: 'basis',
            padding: 16,
            htmlLabels: true,
          },
          securityLevel: 'loose',
        });

        const { svg } = await mermaid.render(id.current, chart);

        if (!cancelled && containerRef.current) {
          containerRef.current.innerHTML = svg;
          // Make SVG responsive
          const svgEl = containerRef.current.querySelector('svg');
          if (svgEl) {
            svgEl.removeAttribute('width');
            svgEl.removeAttribute('height');
            svgEl.style.width = '100%';
            svgEl.style.height = 'auto';
          }
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : String(err));
        }
      }
    }

    render();
    return () => {
      cancelled = true;
    };
  }, [chart]);

  if (error) {
    return (
      <div className="rounded-lg border border-red-900 bg-red-950 p-4 text-sm text-red-300">
        <strong>Diagram error:</strong>
        <pre className="mt-1 overflow-auto text-xs">{error}</pre>
      </div>
    );
  }

  return (
    <div
      ref={containerRef}
      className="my-6 overflow-x-auto rounded-xl border border-slate-200 bg-white p-4"
      style={{ minHeight: '160px' }}
    />
  );
}
