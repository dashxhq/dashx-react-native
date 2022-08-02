import { NativeEventEmitter, NativeModules } from 'react-native'
import { parseFilterObject, toContentSingleton } from './utils'
import {
  prepareExternalAsset,
  queryExternalAsset,
  uploadExternalAsset,
} from './utils/RestAPIClient'

import ContentOptionsBuilder from './ContentOptionsBuilder'

const { DashX } = NativeModules
const dashXEventEmitter = new NativeEventEmitter(DashX)

//TODO Get connection config from Android layer as well
const { identify, track, fetchContent, searchContent, getConnectionConfig } =
  DashX

// Handle overloads at JS, because Native modules doesn't allow that
// https://github.com/facebook/react-native/issues/19116
DashX.identify = (options) => {
  if (typeof options === 'string') {
    return identify(options, null) // options is a string ie. uid
  } else {
    return identify(null, options)
  }
}

DashX.track = (event, data) => track(event, data || null)

DashX.getConnectionConfig = () => {
  return getConnectionConfig()
}

DashX.searchContent = (contentType, options) => {
  if (!options) {
    return new ContentOptionsBuilder((wrappedOptions) =>
      searchContent(contentType, wrappedOptions)
    )
  }

  const filter = parseFilterObject(options.filter)

  const result = searchContent(contentType, { ...options, filter })

  if (options.returnType === 'all') {
    return result
  }

  return result.then(toContentSingleton)
}

DashX.fetchContent = (contentType, options) => {
  return fetchContent(contentType, options)
}

DashX.uploadExternalAsset = async (file, externalColumnId) => {
  const connectionConfig = await getConnectionConfig()

  return new Promise((resolve, reject) => {
    uploadExternalAsset(
      file,
      externalColumnId,
      connectionConfig,
      resolve,
      reject
    )
  })
}

DashX.prepareExternalAsset = async (externalColumnId) => {
  const connectionConfig = await getConnectionConfig()

  return new Promise((resolve, reject) => {
    prepareExternalAsset(externalColumnId, connectionConfig, resolve, reject)
  })
}

DashX.externalAsset = async (assetId) => {
  const connectionConfig = await getConnectionConfig()

  return new Promise((resolve, reject) => {
    queryExternalAsset(assetId, connectionConfig, resolve, reject)
  })
}

DashX.onMessageReceived = (callback) =>
  dashXEventEmitter.addListener('messageReceived', callback)

export default DashX
