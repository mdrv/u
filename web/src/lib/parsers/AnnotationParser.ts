import { readFileSync, readdirSync, statSync } from 'fs'
import { join, relative, extname, basename } from 'path'
import type { ConfigFile, Annotation, CodeLine } from '$lib/types.js'

export class AnnotationParser {
  private annotationPatterns = {
    lua: /--\s*#?ANNOTATION:\s*(.*)$/i,
    nu: /#\s*ANNOTATION:\s*(.*)$/i,
    conf: /#\s*ANNOTATION:\s*(.*)$/i,
    sh: /#\s*ANNOTATION:\s*(.*)$/i,
    default: /#?ANNOTATION:\s*(.*)$/i
  }

  getLanguage(file: string): string {
    const ext = extname(file).toLowerCase()
    const name = basename(file).toLowerCase()

    if (ext === '.lua') return 'lua'
    if (ext === '.nu') return 'nu'
    if (ext === '.conf') return 'conf'
    if (ext === '.sh') return 'sh'
    if (ext === '.js') return 'javascript'
    if (ext === '.ts') return 'typescript'
    if (name === 'makepkg.conf') return 'conf'
    if (name.includes('kitty') || name.includes('hypr')) return 'conf'

    return ext.slice(1) || 'text'
  }

  parseAnnotations(file: string, content: string): Annotation[] {
    const lines = content.split('\n')
    const annotations: Annotation[] = []
    const language = this.getLanguage(file)
    const pattern = this.annotationPatterns[language as keyof typeof this.annotationPatterns] || this.annotationPatterns.default

    lines.forEach((line, index) => {
      const match = line.match(pattern)
      if (match) {
        const explanation = match[1].trim()
        if (explanation) {
          annotations.push({
            id: `${basename(file)}-${index}`,
            line: index + 1,
            explanation,
            codeLine: index + 1
          })
        }
      }
    })

    return annotations
  }

  parseConfigFile(filePath: string, repoRoot: string): ConfigFile {
    try {
      const content = readFileSync(filePath, 'utf-8')
      const relativePath = relative(repoRoot, filePath)
      const name = basename(filePath)
      const language = this.getLanguage(filePath)
      const annotations = this.parseAnnotations(filePath, content)

      const lines = content.split('\n').map((line, index) => {
        const lineNum = index + 1
        const lineAnnotations = annotations.filter((a) => a.codeLine === lineNum)
        return {
          number: lineNum,
          content: line,
          annotations: lineAnnotations.map((a) => a.id)
        } as CodeLine
      })

      return {
        path: relativePath,
        name,
        category: this.getCategory(relativePath),
        language,
        content,
        lines,
        annotations,
        isAnnotated: annotations.length > 0
      }
    } catch (error) {
      console.error(`Error parsing ${filePath}:`, error)
      throw error
    }
  }

  getCategory(filePath: string): string {
    const parts = filePath.split('/')
    if (parts.includes('nvim')) return 'nvim'
    if (parts.includes('nushell')) return 'nushell'
    if (parts.includes('kitty') || parts.includes('foot')) return 'terminal'
    if (parts.includes('hypr')) return 'compositor'
    if (parts.includes('waybar') || parts.includes('dunst') || parts.includes('tofi') || parts.includes('yazi')) return 'desktop'
    if (parts.includes('home')) return 'system'
    if (parts.includes('etc')) return 'system'
    if (parts.includes('fastfetch')) return 'system'
    if (parts.includes('otd')) return 'theme'
    if (parts.includes('zellij')) return 'terminal'
    if (parts.includes('quickshell')) return 'shell'
    return 'misc'
  }

  scanDirectory(dir: string, repoRoot: string, excludePatterns: string[] = ['.git', 'node_modules', '__gen', '.opencode']): ConfigFile[] {
    const files: ConfigFile[] = []

    const scan = (currentDir: string) => {
      const entries = readdirSync(currentDir, { withFileTypes: true })

      for (const entry of entries) {
        if (excludePatterns.includes(entry.name)) continue

        const fullPath = join(currentDir, entry.name)

        if (entry.isDirectory()) {
          scan(fullPath)
        } else if (entry.isFile()) {
          const ext = extname(entry.name).toLowerCase()
          const validExtensions = ['.lua', '.nu', '.conf', '.sh', '.js', '.ts']
          const name = entry.name.toLowerCase()

          if (validExtensions.includes(ext) || name === 'makepkg.conf' || name.includes('kitty') || name.includes('hypr')) {
            try {
              files.push(this.parseConfigFile(fullPath, repoRoot))
            } catch (error) {
              console.error(`Failed to parse ${fullPath}:`, error)
            }
          }
        }
      }
    }

    scan(dir)
    return files
  }

  groupByCategory(files: ConfigFile[]): Map<string, ConfigFile[]> {
    const groups = new Map<string, ConfigFile[]>()

    files.forEach((file) => {
      const category = file.category
      if (!groups.has(category)) {
        groups.set(category, [])
      }
      groups.get(category)!.push(file)
    })

    return groups
  }

  getAnnotatedFiles(files: ConfigFile[]): ConfigFile[] {
    return files.filter((file) => file.isAnnotated)
  }
}
