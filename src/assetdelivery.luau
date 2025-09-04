local net = require("@lune/net")
local serde = require("@lune/serde")
local shared = require("./shared")

local AssetDelivery = {}

AssetDelivery.Interface = {}
AssetDelivery.Prototype = {}

function AssetDelivery.Prototype.fetchAssetUrl<T>(self: ClientFunc<T>, assetId: number)
	local req = net.request({
		url = `{shared.Url.ASSET_DELIVERY_URL}/{assetId}`,
		headers = {
			["User-Agent"] = "RobloxStudio/WinInet",
			["x-api-key"] = self.api_key,
		},
	})

	if not req.ok then
		return {
			code = req.statusCode,
			message = `{req.statusMessage}\n{req.body}`,
			data = req.body,
			success = false,
		}
	end
	return {
		code = req.statusCode,
		message = req.statusMessage,
		data = serde.decode("json", req.body).location,
		success = true,
	}
end

function AssetDelivery.Prototype.fetchAsset<T>(self: ClientFunc<T>, assetId: number)
	local req = net.request({
		url = shared.Url.ASSET_DELIVERY,
		headers = {
			["User-Agent"] = "RobloxStudio/WinInet",
			["Cookie"] = self.cookie,
		},
		query = {
			id = assetId,
		},
	})

	if not req.ok then
		return {
			code = req.statusCode,
			message = `{req.statusMessage}\n{req.body}`,
			data = req.body,
			success = false,
		}
	end
	return {
		code = req.statusCode,
		message = req.statusMessage,
		data = req.body,
		success = true,
	}
end

function AssetDelivery.Prototype.fetchAssetInfo<T>(self: ClientFunc<T>, assetId: number)
	local req = net.request({
		url = `{shared.Url.ASSET_DELIVERY_INFO}/{assetId}`,
		headers = {
			["User-Agent"] = "RobloxStudio/WinInet",
			["Cookie"] = self.cookie,
		},
	})
	if not req.ok then
		return {
			code = req.statusCode,
			message = `{req.statusMessage}`,
			data = req.body,
			success = false,
		}
	end
	local result = serde.decode("json", req.body)
	return {
		code = req.statusCode,
		message = req.statusMessage,
		data = result,
		success = true,
	}
end

function AssetDelivery.Interface.inheritMethods(class: any)
	for key, value in AssetDelivery.Prototype do
		class[key] = value
	end
end

export type ClientFunc<T> = T & AssetDeliveryBehaviour & {
	cookie: string,
	api_key: string,
}

export type AssetDeliveryBehaviour = typeof(AssetDelivery.Prototype) & {}

return AssetDelivery.Interface
