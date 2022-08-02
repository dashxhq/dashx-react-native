import { Platform } from 'react-native'
import RNFetchBlob from 'rn-fetch-blob'
import axios from 'axios'

/** Prepare headers headers for the authenticated calls */
const getNetworkHeaders = (config, customHeaders) => {
  return {
    'X-Public-Key': `${config.publicKey}`,
    //TODO Include identity token as well in the request in future. Currently backend returns "incorrect format" error
    // "X-Identity-Token": `${config.identityToken}`,
    'X-Target-Environment': `${config.targetEnvironment}`,
    Accept: '*/*',
    ...customHeaders,
  }
}

const getNetworkRequestData = (config, customHeaders = {}) => {
  return {
    url: config.baseUri,
    headers: getNetworkHeaders(config, customHeaders),
  }
}

export const prepareExternalAsset = async (externalColumnId, config) => {
  const request = {
    ...getNetworkRequestData(config),
    method: 'POST',
    data: {
      query: `mutation PrepareExternalAsset($input: PrepareExternalAssetInput!) {
                prepareExternalAsset(input: $input) {
                  id
                  installationId
                  externalColumnId
                  storageProviderId
                  status
                  data
                  createdAt
                  updatedAt
                }
              }`,
      variables: {
        input: {
          externalColumnId,
        },
      },
    },
  }

  const response = await axios.request(request)

  return response?.data?.data?.prepareExternalAsset
}

export const queryExternalAsset = async (assetId, config) => {
  const response = await axios.request({
    ...getNetworkRequestData(config),
    method: 'POST',
    data: {
      query: `query ExternalAsset($id: ID!) {
                externalAsset(id: $id) {
                  id
                  status
                  data
                }
              }`,
      variables: {
        id: assetId,
      },
    },
  })

  return response?.data?.data?.externalAsset
}

export const uploadFile = async (url, file, config) => {
  if (!file || Object.keys(file).length === 0) {
    throw new Error('File is empty')
  }

  let { uri, path, type } = file
  const uriTransformer = Platform.select({
    ios: () => (uri || path).replace('file://', ''),
    android: () => {
      return uri || path
    },
  })

  const fileName =
    file.filename || file.name || `${(uri || path).split('/').pop()}`

  const transformedFile = {
    filename: fileName,
    name: fileName,
    uri: uriTransformer(),
    type,
  }

  const response = await RNFetchBlob.fetch(
    'PUT',
    config.baseUri,
    getNetworkHeaders(config, { type }),
    RNFetchBlob.wrap(transformedFile.uri)
  )
  return response.data?.data
}

const pollTillAssetIsReady = async (assetId, config, retryCount) => {
  return new Promise(function (resolve, reject) {
    const retryWindowMillis = 3000

    function queryAssetWithRetryTimeout(retry) {
      if (retry === 0) {
        return resolve({ id: assetId })
      }

      queryExternalAsset(assetId, config)
        .then((assetResponse) => {
          if (assetResponse?.status === 'ready') {
            resolve(assetResponse)
          } else {
            setTimeout(function () {
              queryAssetWithRetryTimeout(retry - 1)
            }, retryWindowMillis)
          }
        })
        .catch(reject)
    }

    queryAssetWithRetryTimeout(retryCount)
  })
}

export const uploadExternalAsset = async (
  file,
  externalColumnId,
  config,
  onSuccess,
  onFailure
) => {
  try {
    const preparedAsset = await prepareExternalAsset(externalColumnId, config)

    const uploadUrl = preparedAsset?.data?.upload?.url,
      assetId = preparedAsset?.id

    await uploadFile(uploadUrl, file, config)

    const response = await pollTillAssetIsReady(assetId, config, 10)

    onSuccess(response)
  } catch (error) {
    onFailure(error)
  }
}
