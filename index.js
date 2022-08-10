import { NativeEventEmitter, NativeModules } from 'react-native'
import { parseFilterObject, toContentSingleton } from './utils'

import ContentOptionsBuilder from './ContentOptionsBuilder'

const { DashXReactNative: DashX } = NativeModules

const dashXEventEmitter = new NativeEventEmitter(DashX)

const {
  identify,
  track,
  fetchContent,
  searchContent,
  uploadExternalAsset,
  prepareExternalAsset,
  externalAsset,
} = DashX;

// Handle overloads at JS, because Native modules doesn't allow that
// https://github.com/facebook/react-native/issues/19116
DashX.identify = (options) => {
  return identify(options)
}

DashX.track = (event, data) => track(event, data || null)

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

DashX.uploadExternalAsset = (file, externalColumnId) => {
  return new Promise((resolve, reject) => {
    uploadExternalAsset(file, externalColumnId, resolve, reject)
  })
}

DashX.prepareExternalAsset = async (externalColumnId) => {
  return new Promise((resolve, reject) => {
    prepareExternalAsset(externalColumnId, resolve, reject)
  })
}

DashX.externalAsset = async (assetId) => {
  return new Promise((resolve, reject) => {
    externalAsset(assetId, resolve, reject)
  })
}

DashX.onMessageReceived = (callback) =>
  dashXEventEmitter.addListener('messageReceived', callback)

export default DashX
