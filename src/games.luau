local net = require("@lune/net")
local serde = require("@lune/serde")
local shared = require("./shared")

local Games = {}

Games.Interface = {}
Games.Prototype = {}

function Games.Prototype.GameInfo<T>(self: ClientFunc<T>, placeId: number)
	-- Get place details
	local placeUrl = string.format("https://apis.roblox.com/universes/v1/places/%d/universe", placeId)

	local placeResp = net.request({
		url = placeUrl,
		method = "GET",
		headers = {
			["Content-Type"] = "application/json",
		},
	})

	if not placeResp.ok then
		return {
			code = placeResp.statusCode,
			message = placeResp.statusMessage,
			data = placeResp.body,
			success = false,
		}
	end

	local placeData = serde.decode("json", placeResp.body)

	if not placeData or not placeData.universeId then
		return {
			code = 404,
			message = `Place doesn't have universe Id`,
			data = "",
			success = false,
		}
	end

	local universeId = placeData.universeId

	local universeUrl = string.format("%s?universeIds=%d", shared.Url.GAMES, universeId)
	local universeResp = net.request({
		url = universeUrl,
		method = "GET",
		headers = {
			["Content-Type"] = "application/json",
			["Cookie"] = self.cookie,
		},
	})

	if not universeResp.ok then
		return {
			code = universeResp.statusCode,
			message = universeResp.statusMessage,
			data = universeResp.body,
			success = false,
		}
	end

	local universeData = serde.decode("json", universeResp.body)
	if not universeData or not universeData.data or #universeData.data == 0 then
		return {
			code = 404,
			message = "No universe data found",
			data = "",
			success = false,
		}
	end

	local data = universeData.data[1]

	local thumbnailUrl = string.format(
		"%s/icons?universeIds=%d&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false",
		shared.Url.THUMBNAILS,
		universeId
	)

	local thumbnailResp = net.request({
		url = thumbnailUrl,
		headers = {
			["Content-Type"] = "application/json",
			["Cookie"] = self.cookie,
		},
	})

	if thumbnailResp.ok then
		local thumbnailData = serde.decode("json", thumbnailResp.body)
		data["icon"] = thumbnailData.data[1].imageUrl
	end

	return data
end

function Games.Interface.inheritMethods(class: any)
	for key, value in Games.Prototype do
		class[key] = value
	end
end

export type ClientFunc<T> = T & GamesBehaviour & {
	cookie: string,
}

export type GamesBehaviour = typeof(Games.Prototype) & {}

return Games.Interface
