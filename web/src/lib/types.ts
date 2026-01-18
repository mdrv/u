export interface Annotation {
	id: string
	line: number
	explanation: string
	codeLine: number
}

export interface CodeLine {
	number: number
	content: string
	annotations: string[]
}

export interface ConfigFile {
	path: string
	name: string
	category: string
	language: string
	content: string
	lines: CodeLine[]
	annotations: Annotation[]
	isAnnotated: boolean
}

export interface CategoryGroup {
	category: string
	files: ConfigFile[]
}

export interface MarkdownFile {
	path: string
	name: string
	category: string
	content: string
	html?: string
}

export interface TreeNode {
	name: string
	path: string
	type: 'file' | 'directory'
	children?: TreeNode[]
	isAnnotated?: boolean
	expanded?: boolean
}
