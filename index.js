import { NativeEventEmitter, NativeModules } from "react-native";
import { parseFilterObject, toContentSingleton } from "./utils";
import { getRealPathFromURI } from "react-native-get-real-path";

import ContentOptionsBuilder from "./ContentOptionsBuilder";

const { DashXReactNative: DashX } = NativeModules;

const dashXEventEmitter = new NativeEventEmitter(DashX);

const {
	identify,
	setIdentity,
	track,
	fetchContent,
	searchContent,
	uploadExternalAsset,
	prepareExternalAsset,
	externalAsset,
	fetchStoredPreferences,
	saveStoredPreferences,
	subscribe
} = DashX;

DashX.identify = (options) => {
	return identify(options);
};

DashX.setIdentity = (uid, token) => {
	return setIdentity(uid, token);
};

DashX.subscribe = () => {
	return subscribe();
}

DashX.track = (event, data) => track(event, data || null);

DashX.searchContent = (contentType, options) => {
	if (!options) {
		return new ContentOptionsBuilder((wrappedOptions) =>
			searchContent(contentType, wrappedOptions)
		);
	}

	const filter = parseFilterObject(options.filter);

	const result = searchContent(contentType, { ...options, filter });

	if (options.returnType === "all") {
		return result;
	}

	return result.then(toContentSingleton);
};

DashX.fetchContent = (contentType, options) => {
	return fetchContent(contentType, options);
};

DashX.uploadExternalAsset = async (file, externalColumnId) => {
  // Convert content uri to file uri
  if (file.uri.startsWith("content://")) {
    file.uri = `file://${await getRealPathFromURI(file.uri)}`;
  }

  return uploadExternalAsset(file, externalColumnId);
};

DashX.prepareExternalAsset = (externalColumnId) => {
	return prepareExternalAsset(externalColumnId);
};

DashX.externalAsset = (assetId) => {
	return externalAsset(assetId);
};

DashX.fetchStoredPreferences = () => {
	return fetchStoredPreferences();
};

DashX.saveStoredPreferences = (preferenceData) => {
	return saveStoredPreferences(preferenceData);
};

DashX.onMessageReceived = (callback) => {
	dashXEventEmitter.addListener("messageReceived", callback);
};

export default DashX;
