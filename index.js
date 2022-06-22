import { NativeEventEmitter, NativeModules } from 'react-native'

import ContentOptionsBuilder from './ContentOptionsBuilder'
import { parseFilterObject, toContentSingleton } from './utils'

const { DashX } = NativeModules
const dashXEventEmitter = new NativeEventEmitter(DashX)

const { identify, track, fetchContent, searchContent } = DashX

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

DashX.searchContent = (contentType, options) => {
  if (!options) {
    return new ContentOptionsBuilder(
      (wrappedOptions) => searchContent(contentType, wrappedOptions)
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

DashX.onMessageReceived = (callback) =>
  dashXEventEmitter.addListener('messageReceived', callback)

export default DashX
