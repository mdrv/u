import { getFileByPath } from '$lib/utils/scanRepo.js'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ params }) => {
	const { parent } = await import('./$types.js')
	const parentData = await parent()
	const filePath = decodeURIComponent(params.path)

	const file = getFileByPath(filePath, parentData.data.repoData)

	if (!file) {
		throw new Error('File not found')
	}

	return {
		file,
	}
}
