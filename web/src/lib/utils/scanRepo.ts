import { readFileSync, readdirSync, statSync, existsSync } from 'fs'
import { join, relative, dirname, basename } from 'path'
import { AnnotationParser } from '$lib/parsers/AnnotationParser.js'
import { remark } from 'remark'
import remarkHtml from 'remark-html'
import type { ConfigFile, CategoryGroup, MarkdownFile, TreeNode } from '$lib/types.js'

const parser = new AnnotationParser()

export interface RepoData {
  files: ConfigFile[]
  categories: CategoryGroup[]
  annotatedFiles: ConfigFile[]
  readmeFiles: MarkdownFile[]
  fileTree: TreeNode[]
}

export function scanRepo(repoRoot: string): RepoData {
  const files = parser.scanDirectory(repoRoot, repoRoot)
  const categories = Array.from(parser.groupByCategory(files).entries()).map(([category, files]) => ({
    category,
    files
  }))
  const annotatedFiles = parser.getAnnotatedFiles(files)
  const readmeFiles = scanReadmeFiles(repoRoot)
  const fileTree = buildFileTree(files, readmeFiles)

  return {
    files,
    categories,
    annotatedFiles,
    readmeFiles,
    fileTree
  }
}

function scanReadmeFiles(repoRoot: string): MarkdownFile[] {
  const readmeFiles: MarkdownFile[] = []

  const scan = (dir: string, relativePath = '') => {
    try {
      const entries = readdirSync(dir, { withFileTypes: true })

      for (const entry of entries) {
        if (entry.name.startsWith('.') || entry.name === 'node_modules') continue

        const fullPath = join(dir, entry.name)
        const currentRelativePath = relativePath ? join(relativePath, entry.name) : entry.name

        if (entry.isDirectory()) {
          scan(fullPath, currentRelativePath)
        } else if (entry.name.toLowerCase() === 'readme.md') {
          try {
            const content = readFileSync(fullPath, 'utf-8')
            const html = remark().use(remarkHtml).processSync(content).toString()

            readmeFiles.push({
              path: currentRelativePath,
              name: entry.name,
              category: parser.getCategory(currentRelativePath),
              content,
              html
            })
          } catch (error) {
            console.error(`Failed to parse README ${fullPath}:`, error)
          }
        }
      }
    } catch (error) {
      console.error(`Error scanning directory ${dir}:`, error)
    }
  }

  scan(repoRoot)
  return readmeFiles
}

function buildFileTree(files: ConfigFile[], readmeFiles: MarkdownFile[]): TreeNode[] {
  const root: TreeNode[] = []
  const nodeMap = new Map<string, TreeNode>()

  const getOrAddNode = (path: string, isDir: boolean = false): TreeNode => {
    if (nodeMap.has(path)) {
      return nodeMap.get(path)!
    }

    const parts = path.split('/')
    const name = basename(path)
    const node: TreeNode = {
      name,
      path,
      type: isDir ? 'directory' : 'file',
      children: []
    }

    nodeMap.set(path, node)

    if (parts.length > 1) {
      const parentPath = parts.slice(0, -1).join('/')
      const parentNode = getOrAddNode(parentPath, true)
      if (!parentNode.children) parentNode.children = []
      parentNode.children.push(node)
    } else {
      root.push(node)
    }

    return node
  }

  files.forEach((file) => {
    const node = getOrAddNode(file.path)
    node.isAnnotated = file.isAnnotated
  })

  readmeFiles.forEach((readme) => {
    const node = getOrAddNode(readme.path)
    node.type = 'file'
  })

  return root
}

export function getCategoryFiles(category: string, repoData: RepoData): ConfigFile[] {
  const categoryGroup = repoData.categories.find((c) => c.category === category)
  return categoryGroup?.files || []
}

export function getFileByPath(path: string, repoData: RepoData): ConfigFile | undefined {
  return repoData.files.find((f) => f.path === path)
}

export function getReadmeByPath(path: string, repoData: RepoData): MarkdownFile | undefined {
  return repoData.readmeFiles.find((f) => f.path === path)
}
