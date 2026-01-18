<script lang='ts'>
	import type { Annotation, CodeLine, ConfigFile } from '$lib/types.js'
	import { highlighter } from '$lib/utils/syntaxHighlighter.js'
	import { onMount } from 'svelte'

	let { file, showAnnotations = true }: {
		file: ConfigFile
		showAnnotations?: boolean
	} = $props()

	let container: HTMLDivElement
	let activeAnnotation: string | null = null
	let tooltipPosition = { x: 0, y: 0 }
	let tooltipAnnotation: Annotation | null = null

	let annotationsMap = $derived.by(() => {
		const map = new Map<string, Annotation>()
		file.annotations.forEach((a) => map.set(a.id, a))
		return map
	})

	onMount(async () => {
		await highlighter.loadLanguage(file.language)
		await renderCode()
	})

	async function renderCode() {
		if (!container) return

		const html = await highlighter.codeToHtml(file.content, {
			lang: file.language,
			theme: 'github-dark',
		})

		container.innerHTML = html

		const lines = container.querySelectorAll('pre code > span')
		lines.forEach((lineElement, index) => {
			if (index < file.lines.length) {
				const line = file.lines[index]
				if (line.annotations.length > 0 && showAnnotations) {
					const marker = document.createElement('span')
					marker.className = 'annotation-marker'
					marker.textContent = `①${line.annotations.length > 1 ? '...' : ''}`
					marker.setAttribute('data-annotation', line.annotations[0])
					marker.addEventListener(
						'mouseenter',
						(e) => showTooltip(e, line.annotations[0]),
					)
					marker.addEventListener('mouseleave', hideTooltip)
					lineElement.appendChild(marker)
				}
			}
		})
	}

	function showTooltip(event: MouseEvent, annotationId: string) {
		const annotation = annotationsMap.get(annotationId)
		if (!annotation) return

		const rect = (event.target as HTMLElement).getBoundingClientRect()
		tooltipPosition = { x: rect.left, y: rect.bottom + 8 }
		tooltipAnnotation = annotation
		activeAnnotation = annotationId
	}

	function hideTooltip() {
		tooltipAnnotation = null
		activeAnnotation = null
	}
</script>

<div class='code-viewer'>
	<div class='code-header'>
		<span class='file-name'>{file.name}</span>
		<span class='file-category'>{file.category}</span>
		{#if file.isAnnotated}
			<span class='annotated-badge'>Annotated</span>
		{/if}
	</div>
	<div bind:this={container} class='code-container'></div>

	{#if tooltipAnnotation}
		<div
			class='tooltip'
			style='left: {tooltipPosition.x}px; top: {tooltipPosition.y}px'
			role='tooltip'
		>
			<div class='tooltip-content'>
				<div class='tooltip-line'>Line {tooltipAnnotation.line}</div>
				<div class='tooltip-explanation' class:markdown={true}>
					{@html tooltipAnnotation.explanation}
				</div>
			</div>
			<div class='tooltip-arrow'></div>
		</div>
	{/if}
</div>

<style>
	.code-viewer {
	  position: relative;
	  width: 100%;
	}

	.code-header {
	  display: flex;
	  align-items: center;
	  gap: 8px;
	  padding: 8px 12px;
	  background: #0d1117;
	  border-bottom: 1px solid #30363d;
	  font-size: 14px;
	}

	.file-name {
	  color: #c9d1d9;
	  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
	}

	.file-category {
	  color: #8b949e;
	  font-size: 12px;
	}

	.annotated-badge {
	  padding: 2px 8px;
	  background: #238636;
	  color: white;
	  border-radius: 9999px;
	  font-size: 10px;
	  font-weight: 600;
	}

	.code-container {
	  background: #0d1117;
	  overflow-x: auto;
	  padding: 16px;
	}

	.code-container :global(pre) {
	  margin: 0;
	  font-family: 'Fira Code', 'JetBrains Mono', monospace;
	  font-size: 13px;
	  line-height: 1.6;
	}

	.annotation-marker {
	  display: inline-flex;
	  align-items: center;
	  justify-content: center;
	  width: 18px;
	  height: 18px;
	  margin-left: 8px;
	  background: #1f6feb;
	  color: white;
	  border-radius: 9999px;
	  font-size: 10px;
	  font-weight: 600;
	  cursor: help;
	  transition: all 0.2s ease;
	}

	.annotation-marker:hover {
	  transform: scale(1.2);
	  box-shadow: 0 0 8px rgba(31, 111, 235, 0.5);
	}

	.tooltip {
	  position: fixed;
	  z-index: 1000;
	  min-width: 280px;
	  max-width: 400px;
	  pointer-events: none;
	}

	.tooltip-content {
	  padding: 12px;
	  background: #1c2128;
	  border: 1px solid #30363d;
	  border-radius: 6px;
	  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.5);
	}

	.tooltip-line {
	  color: #8b949e;
	  font-size: 11px;
	  font-weight: 600;
	  margin-bottom: 4px;
	}

	.tooltip-explanation {
	  color: #c9d1d9;
	  font-size: 13px;
	  line-height: 1.5;
	}

	.tooltip-explanation :global(p) {
	  margin: 0;
	}

	.tooltip-explanation :global(code) {
	  padding: 2px 4px;
	  background: #21262d;
	  border: 1px solid #30363d;
	  border-radius: 3px;
	  font-size: 12px;
	}

	.tooltip-arrow {
	  width: 0;
	  height: 0;
	  margin-left: 20px;
	  border-left: 6px solid transparent;
	  border-right: 6px solid transparent;
	  border-bottom: 6px solid #30363d;
	}
</style>
