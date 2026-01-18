import { createHighlighter } from 'shiki'

let highlighterInstance: Awaited<ReturnType<typeof createHighlighter>> | null = null

export const highlighter = {
	async init() {
		if (highlighterInstance) return

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
				'conf',
				'ini',
				'python',
				'rust',
			],
		})
	},

	async loadLanguage(lang: string) {
		if (!highlighterInstance) {
			await this.init()
		}

		if (!highlighterInstance!.getLoadedLanguages().includes(lang as any)) {
			try {
				await highlighterInstance!.loadLanguage(lang as any)
			} catch (error) {
				console.error(`Failed to load language ${lang}:`, error)
			}
		}
	},

	async codeToHtml(code: string, options: { lang: string; theme: string }) {
		if (!highlighterInstance) {
			await this.init()
		}

		return highlighterInstance!.codeToHtml(code, options)
	},
}
