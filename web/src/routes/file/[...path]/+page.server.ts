import { getFileByPath } from '$lib/utils/scanRepo.js'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ params, parent }) => {
	const parentData = await parent()
	const filePath = decodeURIComponent(params.path)

	const repoData = parentData.repoData
	const file = getFileByPath(filePath, repoData)

	if (!file) {
		throw new Error('File not found')
	}

	return {
		file,
	}
}
