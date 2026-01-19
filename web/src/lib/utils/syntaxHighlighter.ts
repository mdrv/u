import { createHighlighter, type BundledLanguage, type BundledTheme } from 'shiki'

let highlighterInstance: Awaited<ReturnType<typeof createHighlighter>> | null = null

export const highlighter = {
	async init() {
		if (highlighterInstance) {
			console.log('Highlighter already initialized')
			return
		}

		console.log('Initializing highlighter...')
		highlighterInstance = await createHighlighter({
			themes: ['github-dark', 'github-light'],
			langs: [
				'lua',
				'javascript',
				'typescript',
				'bash',
				'shell',
				'nushell',
				'json',
				'yaml',
				'toml',
				'css',
				'html',
				'mdx',
				'markdown',
				'txt',
				'ini',
				'python',
				'rust',
			],
		})
		console.log('Highlighter initialized')
	},

	async loadLanguage(lang: string) {
		if (!highlighterInstance) {
			await this.init()
		}

		const loadedLanguages = highlighterInstance!.getLoadedLanguages()

		const normalizedLang = this.normalizeLanguage(lang)

		if (!loadedLanguages.includes(normalizedLang as any)) {
			try {
				await highlighterInstance!.loadLanguage(normalizedLang as any)
			} catch (error) {
				console.error(`Failed to load language ${normalizedLang}:`, error)
			}
		}
	},

	normalizeLanguage(lang: string): string {
		const langMap: Record<string, string> = {
			conf: 'ini',
			nu: 'bash',
		}
		return langMap[lang] || lang
	},

	async codeToHtml(code: string, options: { lang: string; theme: string }) {
		if (!highlighterInstance) {
			await this.init()
		}

		const normalizedLang = this.normalizeLanguage(options.lang)

		try {
			const html = highlighterInstance!.codeToHtml(code, {
				lang: normalizedLang as BundledLanguage,
				theme: options.theme as BundledTheme,
			})
			return html
		} catch (error) {
			console.error(`Failed to highlight code with lang ${normalizedLang}:`, error)
			return `<pre style="white-space: pre-wrap; background: #0d1117; color: #c9d1d9; padding: 16px;">${this.escapeHtml(code)}</pre>`
		}
	},

	escapeHtml(html: string): string {
		return html
			.replace(/&/g, '&amp;')
			.replace(/</g, '&lt;')
			.replace(/>/g, '&gt;')
			.replace(/"/g, '&quot;')
			.replace(/'/g, '&#039;')
	},
}
